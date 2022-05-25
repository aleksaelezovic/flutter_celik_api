library celik_api;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_pcsc/flutter_pcsc.dart';

import './src/apdu.dart';
import './src/celik_apdu_base.dart';
import './src/constants.dart';

export './src/constants.dart' show CelikFile, CelikTag;
export './src/celik_apdu_base.dart' show CelikAPDUBase;

class CelikAPDU extends CelikAPDUBase {
  final CardStruct card;
  CelikAPDU(this.card) : super();

  @override
  Future<List<int>> transmit(List<int> bytes) => Pcsc.transmit(card, bytes);
}

Map<CelikTag, String> transformData(List<int> data) {
  Map<CelikTag, String> transformed = {};
  ByteBuffer buf = Uint8List.fromList(data).buffer;

  int i = 0;
  while (i < data.length) {
    int tagId = buf.asByteData(i, 2).getUint16(0, Endian.little);

    int len = min(
      buf.asByteData(i + 2, 2).getUint16(0, Endian.little),
      data.length - i - 4, // Safe
    );

    String val = utf8.decode(buf.asUint8List(i + 4, len));
    CelikTag tag = CelikConstants.tagFromInt(tagId);
    if (tag != CelikTag.error) {
      transformed[tag] = val;
    } else {
      print("Cant find tag for $tagId");
    }

    i += len + 4;
  }

  return transformed;
}

/// Main user-friendly class.
/// Communication with card-reader is done through flutter_pcsc package.
///
/// Simple usage: await CelikAPI().readAllData()
class CelikAPI {
  int? ctx;
  CardStruct? card;

  checkInit() {
    if (ctx == null) {
      throw Exception("No context detected. Please run start()");
    }
  }

  checkCard() {
    if (card == null) {
      throw Exception("No card detected! Init a card.");
    }
  }

  /// Called to initialize the PCSC Context. Initiates the connection to a card.
  /// Must be called before any other methods.
  Future<void> start() async {
    await end();

    int ctx = await Pcsc.establishContext(PcscSCope.user);
    this.ctx = ctx;
  }

  /// Get list of all readers.
  ///
  /// Throws if start() was not called before.
  Future<List<String>> getReaders() async {
    checkInit();

    return await Pcsc.listReaders(ctx!);
  }

  /// Connect a card inserted in a specific reader.
  ///
  /// Throws if start() was not called before.
  Future<void> connectCard(String reader) async {
    checkInit();

    card = await Pcsc.cardConnect(
      ctx!,
      reader,
      PcscShare.shared,
      PcscProtocol.any,
    );
  }

  /// Reads data from specified File on card.
  ///
  /// Throws if start() was not called before.
  /// Throws if connectCard() was not called.
  Future<Map<CelikTag, String>> readData(CelikFile file) async {
    checkInit();
    checkCard();

    CelikAPDU celik = CelikAPDU(card!);
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    APDUResponse selectFileResponse = await celik.selectFile(file);
    if (!selectFileResponse.isOk()) throw Exception("Selecting file failed.");

    APDUResponse dataResponse = await celik.readFile();
    if (!dataResponse.isOk()) throw Exception("Reading data error!");

    return transformData(dataResponse.data());
  }

  /// Reads image data.
  ///
  /// Throws if start() was not called before.
  /// Throws if connectCard() was not called.
  Future<String> readImageData() async {
    checkInit();
    checkCard();

    CelikAPDU celik = CelikAPDU(card!);
    APDUResponse initResponse = await celik.init();
    if (!initResponse.isOk()) throw Exception("Init failed.");

    APDUResponse selectFileResponse =
        await celik.selectFile(CelikFile.photoFile);
    if (!selectFileResponse.isOk()) throw Exception("Selecting file failed.");

    APDUResponse dataResponse = await celik.readFile(startOffset: 8);
    if (!dataResponse.isOk()) throw Exception("Reading image data error!");

    return base64.encode(dataResponse.data());
  }

  /// Called to terminate the connection to a card and PCSC Context.
  /// Must be called before any other methods.
  Future<void> end() async {
    if (ctx != null) {
      if (card != null) {
        await Pcsc.cardDisconnect(card!.hCard, PcscDisposition.resetCard);
        card = null;
      }
      await Pcsc.releaseContext(ctx!);
      ctx = null;
    }
  }

  /// Automatically reads all data on card.
  /// Maximally user friendly.
  /// start() or end() does not have to be called.
  ///
  /// Returns always, no error throwing. (Prints errors in kDebugMode)
  Future<CelikAPIAllData> readAllData() async {
    Map<CelikTag, String> data = {};
    String image = "";
    try {
      await start();

      List<String> devices = await getReaders();
      if (devices.isEmpty) {
        throw Exception("No devices found.");
      } else {
        await connectCard(devices[0]);
        data.addAll(await readData(CelikFile.documentFile));
        data.addAll(await readData(CelikFile.personalFile));
        data.addAll(await readData(CelikFile.residenceFile));

        image = await readImageData();
      }

      await end();
    } catch (e) {
      if (kDebugMode) {
        print("Error has occured:");
        print(e);
      }
    } finally {
      await end();
    }
    return CelikAPIAllData(data, image);
  }
}

class CelikAPIAllData {
  final Map<CelikTag, String> data;
  final String image;
  CelikAPIAllData(this.data, this.image);
}
