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

  /// Read data from CelikFile
  Future<Map<CelikTag, String>> readData(CelikFile file) async {
    CelikAPDUBase celik = createCelikAPDU();
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    APDUResponse selectFileResponse = await celik.selectFile(file);
    if (!selectFileResponse.isOk()) throw Exception("Selecting file failed.");

    APDUResponse dataResponse = await celik.readFile();
    if (!dataResponse.isOk()) throw Exception("Reading data error!");

    return transformData(dataResponse.data());
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
