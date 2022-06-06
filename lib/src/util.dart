import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import './constants.dart';

Map<int, List<int>> parseTLV(List<int> bytes) {
  Map<int, List<int>> out = {};

  int i = 0;
  while (i + 3 < bytes.length) {
    var indexStart = i;
    var valueLength = bytes[i + 2];
    var indexEnd = i + 4 + valueLength;

    if (bytes[i + 1] != 0x06 ||
        bytes[i + 3] != 0x00 ||
        indexEnd >= bytes.length) break;

    out[bytes[i]] = bytes.sublist(indexStart, indexEnd);
    i = indexEnd;
  }

  return out;
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

/// Transforms errors thrown by `flutter_pcsc` package to readable string.
String transformPCSCError(String errorMessage) {
  final errorCode = errorMessage.substring(
    errorMessage.indexOf("Reason:") + "Reason: ".length,
  );
  return _transformPCSCErrorCode(errorCode);
}

String _transformPCSCErrorCode(String errorCode) {
  switch (errorCode) {
    case "SCARD_F_INTERNAL_ERROR":
      return 'Internal error.';
    case "SCARD_E_CANCELLED":
      return 'Cancelled.';
    case "SCARD_E_INVALID_HANDLE":
      return 'Invalid card handle.';
    case "SCARD_E_INVALID_PARAMETER":
      return 'Invalid parameter.';
    case "SCARD_E_INVALID_TARGET":
      return 'Invalid target.';
    case "SCARD_E_NO_MEMORY":
      return 'No memory.';
    case "SCARD_F_WAITED_TOO_LONG":
      return 'Waited for too long.';
    case "SCARD_E_INSUFFICIENT_BUFFER":
      return 'Insufficient buffer.';
    case "SCARD_E_UNKNOWN_READER":
      return 'Unknown reader device.';
    case "SCARD_E_TIMEOUT":
      return 'Timeout error!';
    case "SCARD_E_SHARING_VIOLATION":
      return 'Sharing violation!';
    case "SCARD_E_NO_SMARTCARD":
      return 'No smartcard present.';
    case "SCARD_E_UNKNOWN_CARD":
      return 'Unknown card.';
    case "SCARD_E_CANT_DISPOSE":
      return 'Error - Cannot dispose.';
    case "SCARD_E_PROTO_MISMATCH":
      return 'Error - Proto mismatch!';
    case "SCARD_E_NOT_READY":
      return 'Error - Not ready!';
    case "SCARD_E_INVALID_VALUE":
      return 'Invalid value!';
    case "SCARD_E_SYSTEM_CANCELLED":
      return 'Error - System cancelled.';
    case "SCARD_F_COMM_ERROR":
      return 'Communication error.';
    case "SCARD_F_UNKNOWN_ERROR":
      return 'Unknown error occurred.';
    case "SCARD_E_INVALID_ATR":
      return 'Invalid card ATR!';
    case "SCARD_E_NOT_TRANSACTED":
      return 'Error - Not transacted.';
    case "SCARD_E_READER_UNAVAILABLE":
      return 'Reader not available.';
    case "SCARD_P_SHUTDOWN":
      return 'Error - Shutdown.';
    case "SCARD_E_PCI_TOO_SMALL":
      return 'Error - PCI Too small.';
    case "SCARD_E_READER_UNSUPPORTED":
      return 'Reader not supported.';
    case "SCARD_E_DUPLICATE_READER":
      return 'Error - Duplicate reader.';
    case "SCARD_E_CARD_UNSUPPORTED":
      return 'Card is not supported.';
    case "SCARD_E_NO_SERVICE":
      return 'Error - No service.';
    case "SCARD_E_SERVICE_STOPPED":
      return 'Error - Service stopped.';
    case "SCARD_E_UNEXPECTED":
      return 'Unexpected error occurred.';
    case "SCARD_E_ICC_INSTALLATION":
      return 'Error - ICC Installation';
    case "SCARD_E_ICC_CREATEORDER":
      return 'Error - ICC Create Order';
    case "SCARD_E_UNSUPPORTED_FEATURE":
      return 'Error - Feature not supported.';
    case "SCARD_E_DIR_NOT_FOUND":
      return 'Error - Directory not found.';
    case "SCARD_E_FILE_NOT_FOUND":
      return 'Error - File not found.';
    case "SCARD_E_NO_DIR":
      return 'Error - No directory.';
    case "SCARD_E_NO_FILE":
      return 'Error - No file.';
    case "SCARD_E_NO_ACCESS":
      return 'Error - No access!';
    case "SCARD_E_WRITE_TOO_MANY":
      return 'Error - Too many writes!';
    case "SCARD_E_BAD_SEEK":
      return 'Error - Bad seek.';
    case "SCARD_E_INVALID_CHV":
      return 'Error - Invalid CHV!';
    case "SCARD_E_UNKNOWN_RES_MNG":
      return 'Error - Unknown res mng.';
    case "SCARD_E_NO_SUCH_CERTIFICATE":
      return 'Error - No such certificate!';
    case "SCARD_E_CERTIFICATE_UNAVAILABLE":
      return 'Error - Certificate not available!';
    case "SCARD_E_NO_READERS_AVAILABLE":
      return 'No readers available!';
    case "SCARD_E_COMM_DATA_LOST":
      return 'Error - Communication data lost!';
    case "SCARD_E_NO_KEY_CONTAINER":
      return 'Error - No key container.';
    case "SCARD_E_SERVER_TOO_BUSY":
      return 'Error - Server too busy!';
    case "SCARD_W_UNSUPPORTED_CARD":
      return 'Unsupported card.';
    case "SCARD_W_UNRESPONSIVE_CARD":
      return 'Non-responsive card.';
    case "SCARD_W_UNPOWERED_CARD":
      return 'Unpowered card.';
    case "SCARD_W_RESET_CARD":
      return 'Warning - Card was reset.';
    case "SCARD_W_REMOVED_CARD":
      return 'Warning - Card was removed.';
    case "SCARD_W_SECURITY_VIOLATION":
      return 'Card security violation!';
    case "SCARD_W_WRONG_CHV":
      return 'Wrong card CHV!';
    case "SCARD_W_CHV_BLOCKED":
      return 'Card CHV Blocked!';
    case "SCARD_W_EOF":
      return 'Card EOF!';
    case "SCARD_W_CANCELLED_BY_USER":
      return 'Cancelled by User.';
    case "SCARD_W_CARD_NOT_AUTHENTICATED":
      return 'Card not authenticated!';

    default:
      return 'Unknown error.';
  }
}
