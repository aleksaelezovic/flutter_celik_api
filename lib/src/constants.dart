class CelikConstants {
  static const List<int> lkAID = [
    0xF3,
    0x81,
    0x00,
    0x00,
    0x02,
    0x53,
    0x45,
    0x52,
    0x49,
    0x44,
    0x01
  ];

  static List<int> getFile(CelikFile f) {
    switch (f) {
      case CelikFile.documentFile:
        return [0x0F, 0x02];
      case CelikFile.personalFile:
        return [0x0F, 0x03];
      case CelikFile.residenceFile:
        return [0x0F, 0x04];
      case CelikFile.photoFile:
        return [0x0F, 0x06];
      case CelikFile.authCertificate:
        return [0x0F, 0x08];
      case CelikFile.qualifiedCertificate:
        return [0x0F, 0x10];
      case CelikFile.intermCertificate:
        return [0x0F, 0x11];
      case CelikFile.encryptedPrivateKey:
        return [0x0F, 0x09];
      case CelikFile.encryptedPinAndSecret:
        return [0x0F, 0x13];
      case CelikFile.encryptionXOR:
        return [0x0F, 0xA1];
      case CelikFile.firstUnknown:
        return [0x0F, 0xA3];
      case CelikFile.test:
        return [0x0F, 0x12];
    }
  }

  static const Map<CelikTag, String> tags = {
    CelikTag.error: "ERR!",
    CelikTag.iss: "ISS",
    CelikTag.docRegNo: "DOC_REG_NO",
    CelikTag.id: "ID",
    CelikTag.idDocRegNo: "ID<DOC_REG_NO>",
    CelikTag.issDate: "ISSUING_DATE",
    CelikTag.expDate: "EXPIRY_DATE",
    CelikTag.issAuthority: "ISSUING_AUTHORITY",
    CelikTag.sc1: "SC",
    CelikTag.sc2: "SC",
  };

  static CelikTag tagFromInt(int tag) {
    int index = tag - _tagIndexStart;
    if (index >= CelikTag.values.length) {
      return CelikTag.error;
    }
    return CelikTag.values[index];
  }

  static String tagToString(CelikTag tag) {
    return tags[tag] ?? "-";
  }
}

enum CelikFile {
  documentFile,
  personalFile,
  residenceFile,
  photoFile,
  qualifiedCertificate,
  authCertificate,
  firstUnknown,
  encryptedPrivateKey,
  encryptedPinAndSecret,
  encryptionXOR,
  intermCertificate,
  test
}

const _tagIndexStart = 1545 - 1; // 1543 = error

extension CelikTagId on CelikTag {
  int get id => index + _tagIndexStart;
}

enum CelikTag {
  error, // = 1543
  iss,
  docRegNo,
  id,
  idDocRegNo,
  issDate,
  expDate,
  issAuthority,
  sc1,
  sc2,
  n1,
  n2,
  n3,
  n4,
  personalNumber,
  surname,
  givenName,
  parentGivenName,
  sex,
  placeOfBirth,
  communityOfBirth,
  stateOfBirth,
  dateOfBirth,
  countryOfBirth,
  state,
  community,
  place,
  street,
  houseNumber,
  houseLetter,
  entrance,
  floor,
  n5,
  n6,
  apartmentNumber,
  n7,
  addressDate,
  addressType,
}
