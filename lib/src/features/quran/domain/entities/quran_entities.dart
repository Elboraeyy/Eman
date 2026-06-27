class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final String nameEnglish;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameEnglish,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });
}

class Ayah {
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String text;
  final String textUthmani;
  final int juz;
  final int page;
  final bool sajda;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.text,
    required this.textUthmani,
    required this.juz,
    required this.page,
    required this.sajda,
  });
}

class QcfLine {
  final int lineNumber;
  final String text;
  final int? surahNumber;
  final bool isBismillah;

  QcfLine({
    required this.lineNumber,
    required this.text,
    this.surahNumber,
    this.isBismillah = false,
  });
}

class QcfVerse {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String codeV1;
  final int page;

  QcfVerse({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.codeV1,
    required this.page,
  });
}

class QcfPage {
  final int pageNumber;
  final List<QcfLine> lines;
  final List<QcfVerse> verses;

  QcfPage({
    required this.pageNumber,
    required this.lines,
    required this.verses,
  });
}

class AyahRef {
  final int surahNumber;
  final int ayahNumber;

  AyahRef({
    required this.surahNumber,
    required this.ayahNumber,
  });
}

class CustomBookmark {
  final String id;
  final String name;
  final int colorValue;
  final int page;
  final DateTime createdAt;

  CustomBookmark({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.page,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'page': page,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomBookmark.fromJson(Map<String, dynamic> json) => CustomBookmark(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
        page: json['page'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
