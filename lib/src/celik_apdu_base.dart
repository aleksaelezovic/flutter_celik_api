import 'dart:math';
import 'dart:typed_data';

import './apdu.dart';
import './constants.dart';

/// Base class that defines APDU commands used by CelikAPI
///
/// One may override transmit method with a custom imiplementation
abstract class CelikAPDUBase {
  static const int defaultFileOffset = 4;
  dynamic selectedFileLength;
  CelikAPDUBase();

  Future<List<int>> transmit(List<int> bytes);

  Future<APDUResponse> init() =>
      transmit(APDUCommands.initAID(CelikConstants.lkAID))
          .then((b) => APDUResponse(b));

  Future<APDUResponse> selectFile(CelikFile file) =>
      transmit(APDUCommands.selectFile(CelikConstants.getFile(file))).then((b) {
        selectedFileLength = b[3]; // Approximation
        return APDUResponse(b);
      });

  Future<APDUResponse> verifyPIN(List<int> pin) =>
      transmit(APDUCommands.verify(pin)).then((b) => APDUResponse(b));

  Future<bool> _setPreciseFileLength() async {
    APDUResponse res = APDUResponse(await transmit(
      APDUCommands.readByteData(2, 2),
    ));

    if (!res.isOk()) return false;

    selectedFileLength = Uint8List.fromList(res.data())
            .buffer
            .asByteData()
            .getUint16(0, Endian.little) +
        defaultFileOffset;

    return true;
  }

  Future<APDUResponse> readFile({int startOffset = defaultFileOffset}) async {
    if (selectedFileLength == null) return APDUResponse([103, 1]);

    List<int> data = [];
    List<int> statusCode = APDUStandard.successCode;

    if (!await _setPreciseFileLength()) {
      return APDUResponse([103, 1]);
    }

    int bytesOffset = startOffset;
    while (bytesOffset < selectedFileLength) {
      int bytesLength =
          min(selectedFileLength - bytesOffset, APDUStandard.maxReadBytes);

      APDUResponse res = APDUResponse(await transmit(
        APDUCommands.readByteData(bytesOffset, bytesLength),
      ));
      if (!res.isOk()) {
        statusCode = res.statusCode;
        break;
      }
      data.addAll(res.data());

      bytesOffset += bytesLength;
    }

    return APDUResponse([...data, ...statusCode]);
  }
}
