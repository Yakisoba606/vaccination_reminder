class VaccinationModel {
  int? id;
  String personName;
  String vaccineName;
  String vaccinationDate;
  String nextDate;

  VaccinationModel({
    this.id,
    required this.personName,
    required this.vaccineName,
    required this.vaccinationDate,
    required this.nextDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'vaccineName': vaccineName,
      'vaccinationDate': vaccinationDate,
      'nextDate': nextDate,
    };
  }

  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id'],
      personName: map['personName'],
      vaccineName: map['vaccineName'],
      vaccinationDate: map['vaccinationDate'],
      nextDate: map['nextDate'],
    );
  }
}
