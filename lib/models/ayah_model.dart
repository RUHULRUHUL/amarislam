class Ayah {
  final int number;
  final String textArabic;
  final String textBangla;
  final String textEnglish;
  final int numberInSurah;
  final int juz;

  Ayah({
    required this.number,
    required this.textArabic,
    required this.textBangla,
    required this.textEnglish,
    required this.numberInSurah,
    required this.juz,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      textArabic: json['textArabic'] ?? '',
      textBangla: json['textBangla'] ?? '',
      textEnglish: json['textEnglish'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 0,
    );
  }
}
