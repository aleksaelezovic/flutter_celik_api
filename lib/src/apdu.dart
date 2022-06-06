class APDUStandard {
  static const List<int> successCode = [0x90, 0];
  static const int maxReadBytes = 32;
}

class APDUCommands {
  static List<int> initAID(List<int> aid) => [
        ...[0x00, 0xA4, 0x04, 0x00],
        aid.length,
        ...aid
      ];

  static List<int> selectFile(List<int> name) => [
        ...[0x00, 0xA4, 0x08, 0x00],
        name.length,
        ...name
      ];

  static List<int> readByteData(int bytesOffset, int bytesLength) => [
        ...[0x00, 0xB0],
        bytesOffset >> 8, // or 0
        bytesOffset & 0xFF,
        bytesLength
      ];

  static List<int> verify(List<int> pin) => [
        ...[0x00, 0x20, 0x00, 0x01],
        0x08,
        ...pin.sublist(0, 8),
        0x00
      ];
}

class APDUResponse {
  final List<int> _raw;
  late List<int> _statusCode;

  APDUResponse(this._raw) {
    _statusCode = _raw.getRange(_raw.length - 2, _raw.length).toList();
  }

  bool isOk() {
    return _statusCode[0] == APDUStandard.successCode[0] &&
        _statusCode[1] == APDUStandard.successCode[1];
  }

  List<int> data() => _raw.getRange(0, _raw.length - 2).toList();

  get statusCode => _statusCode;
}
