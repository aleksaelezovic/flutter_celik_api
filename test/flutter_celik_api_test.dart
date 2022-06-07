import 'package:flutter_celik_api/flutter_celik_api.dart';
import 'package:test/test.dart';

const pin = const String.fromEnvironment("pin");

void main() {
  test("CelikAPI - readAllData()", () async {
    final response = await CelikAPI().readAllData();

    expect(response.data, isNot(equals({})));
    expect(response.image, isNot(equals("")));
    expect(response.data[CelikTag.iss], equals("SRB"));
  });

  group("CelikAPI - Single tests", () {
    final celik = CelikAPI();
    setUpAll(() async {
      await celik.start();
      final readers = await celik.getReaders();
      if (readers.isEmpty) throw "No readers available.";
      await celik.connectCard(readers[0]);
    });
    tearDownAll(() async {
      await celik.end();
    });

    /*
    test("- sign & verify", () async {
      if (pin == "")
        throw "No pin specified. Specify with --dart-define=\"pin=[PIN]\" argument.";

      const testStr = "Hello World!";
      final signature = await celik.signData(
        utf8.encode(testStr),
        pin,
      );
      final isOk = await celik.verifySignature(
        signature,
        utf8.encode(testStr),
      );

      expect(isOk, isTrue);
    }); 
    */
  });
}
