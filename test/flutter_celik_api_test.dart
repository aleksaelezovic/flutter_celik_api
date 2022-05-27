import 'package:flutter_celik_api/flutter_celik_api.dart';
import 'package:test/test.dart';

void main() {
  group("CelikAPI w/ flutter_pcsc", () {
    test("readAllData()", () async {
      final response = await CelikAPI().readAllData();

      expect(response.data, isNot(equals({})));
      expect(response.image, isNot(equals("")));
      expect(response.data[CelikTag.iss], equals("SRB"));
    });
  });
}
