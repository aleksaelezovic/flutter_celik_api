import 'dart:convert';

import './apdu.dart';
import './celik_apdu_base.dart';
import './constants.dart';
import './util.dart';

export './celik_apdu_base.dart' show CelikAPDUBase;

/// Class that defines the methods for reading data
/// Extend and override createCelikAPDU()
abstract class CelikDataAPI {
  /// Should be overriden with your custom PCSC logic
  CelikAPDUBase createCelikAPDU();

  /// Read binary data from CelikFile
  Future<List<int>> readBinaryData(CelikFile file) async {
    CelikAPDUBase celik = createCelikAPDU();
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    APDUResponse selectFileResponse = await celik.selectFile(file);
    if (!selectFileResponse.isOk()) throw Exception("Selecting file failed.");

    APDUResponse dataResponse = await celik.readFile();
    if (!dataResponse.isOk()) throw Exception("Reading data error!");

    return dataResponse.data();
  }

  /// Verify PIN
  Future<void> verify(List<int> pin) async {
    CelikAPDUBase celik = createCelikAPDU();
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    await celik.verifyPIN(pin);
    if (!initResponse.isOk()) throw Exception("Pin not correct.");
  }

  /// Read data (structured) from CelikFile
  Future<Map<CelikTag, String>> readData(CelikFile file) async {
    return transformData(await readBinaryData(file));
  }

  /// Reads image data
  Future<String> readImageData() async {
    CelikAPDUBase celik = createCelikAPDU();
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    APDUResponse selectFileResponse =
        await celik.selectFile(CelikFile.photoFile);
    if (!selectFileResponse.isOk()) throw Exception("Selecting file failed.");

    APDUResponse dataResponse = await celik.readFile(startOffset: 8);
    if (!dataResponse.isOk()) throw Exception("Reading image data error!");

    return base64.encode(dataResponse.data());
  }

  /// Returns all data on a card in a single call
  Future<CelikAPIAllData> readAllData() async => CelikAPIAllData({
        ...await readData(CelikFile.documentFile),
        ...await readData(CelikFile.residenceFile),
        ...await readData(CelikFile.personalFile),
      }, await readImageData());
}

class CelikAPIAllData {
  final Map<CelikTag, String> data;
  final String image;
  CelikAPIAllData(this.data, this.image);
}
