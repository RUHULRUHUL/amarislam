class Surah {
  final int number;
  final String nameArabic;
  final String nameBangla;
  final String nameEnglish;
  final String revelationType;
  final int numberOfAyahs;
  final List<String> searchKeywords;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameBangla,
    required this.nameEnglish,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.searchKeywords,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      nameArabic: json['nameArabic'],
      nameBangla: json['nameBangla'],
      nameEnglish: json['nameEnglish'],
      revelationType: json['revelationType'],
      numberOfAyahs: json['numberOfAyahs'],
      searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
    );
  }
}
