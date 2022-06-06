library flutter_celik_api;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_pcsc/flutter_pcsc.dart';

import './src/constants.dart';
import './src/celik_api.dart';
import './src/util.dart' show transformPCSCError;

export './src/constants.dart' show CelikFile, CelikTag;
export './src/celik_api.dart' show CelikAPDUBase, CelikDataAPI, CelikAPIAllData;

/// CelikAPDUBase, based on flutter_pcsc
class CelikAPDU extends CelikAPDUBase {
  final CardStruct card;
  CelikAPDU(this.card) : super();

  @override
  Future<List<int>> transmit(List<int> bytes) async {
    try {
      return await Pcsc.transmit(card, bytes, newIsolate: true);
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }
}

/// Main user-friendly class.
/// * Implementation of CelikDataAPI.
/// * Communication with card-reader is done through flutter_pcsc package.
///
/// Simple usage: ```
/// await CelikAPI().readAllData()
/// ```
class CelikAPI extends CelikDataAPI {
  /// flutter_pcsc Context
  int? ctx;

  /// flutter_pcsc Card object
  CardStruct? card;

  /// Creates CelikAPDUBase based on `flutter_pcsc` package
  @override
  CelikAPDUBase createCelikAPDU() => CelikAPDU(card!);

  /// Check if context is initiated - or throw!
  checkInit() {
    if (ctx == null) {
      throw "No context detected. Please run start()";
    }
  }

  /// Check if card is present - or throw!
  checkCard() {
    if (card == null) {
      throw "No card detected! Init a card.";
    }
  }

  /// Called to initialize the PCSC Context. Initiates the connection to a card
  ///
  /// * Must be called before any other methods
  Future<void> start() async {
    await end();

    try {
      int ctx = await Pcsc.establishContext(PcscSCope.user);
      this.ctx = ctx;
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }

  /// Get list of all readers
  ///
  /// * Throws if start() was not called before
  Future<List<String>> getReaders() async {
    checkInit();
    try {
      return await Pcsc.listReaders(ctx!);
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }

  /// Connect a card inserted in a specific reader
  ///
  /// * Throws if start() was not called before
  Future<void> connectCard(String reader) async {
    checkInit();

    try {
      card = await Pcsc.cardConnect(
        ctx!,
        reader,
        PcscShare.shared,
        PcscProtocol.any,
      );
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }

  /// Reads data from specified File on card
  ///
  /// * Throws if start() was not called before
  /// * Throws if connectCard() was not called
  @override
  Future<Map<CelikTag, String>> readData(CelikFile file) {
    checkInit();
    checkCard();

    return super.readData(file);
  }

  /// Reads image data.
  ///
  /// * Throws if start() was not called before
  /// * Throws if connectCard() was not called
  @override
  Future<String> readImageData() {
    checkInit();
    checkCard();

    return super.readImageData();
  }

  /// Automatically reads all data on card
  ///
  /// start() or end() does not have to be called!
  ///
  /// Returns always, no error throwing (Prints errors in kDebugMode)
  @override
  Future<CelikAPIAllData> readAllData() async {
    CelikAPIAllData data = CelikAPIAllData({}, "");
    try {
      await start();

      List<String> devices = await getReaders();
      if (devices.isEmpty) {
        throw "No devices found.";
      } else {
        await connectCard(devices[0]);
        data = await super.readAllData();
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
    return data;
  }

  /// Disconnect a connected card
  ///
  /// * Throws if start() was not called before
  /// * Throws if connectCard() was not called
  Future<void> disconnectCard() async {
    checkInit();
    checkCard();

    try {
      await Pcsc.cardDisconnect(card!.hCard, PcscDisposition.resetCard);
      card = null;
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }

  /// Called to terminate the connection to a card and PCSC Context
  ///
  /// Must be called after all the work is done to release context in memory
  Future<void> end() async {
    try {
      if (ctx != null) {
        if (card != null) {
          await Pcsc.cardDisconnect(card!.hCard, PcscDisposition.resetCard);
          card = null;
        }
        await Pcsc.releaseContext(ctx!);
        ctx = null;
      }
    } catch (error) {
      throw transformPCSCError(error.toString());
    }
  }
}
