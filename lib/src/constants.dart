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

  static const List<int> documentFile = [0x0F, 0x02];
  static const List<int> personalFile = [0x0F, 0x03];
  static const List<int> residenceFile = [0x0F, 0x04];
  static const List<int> photoFile = [0x0F, 0x06];

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

  static List<int> getFile(CelikFile f) {
    switch (f) {
      case CelikFile.documentFile:
        return documentFile;
      case CelikFile.personalFile:
        return personalFile;
      case CelikFile.residenceFile:
        return residenceFile;
      case CelikFile.photoFile:
        return photoFile;
    }
  }
}

enum CelikFile { documentFile, personalFile, residenceFile, photoFile }

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
