import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import './constants.dart';

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
