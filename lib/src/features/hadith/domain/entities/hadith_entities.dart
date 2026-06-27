class HadithBook {
  final int id;
  final String title;
  final String author;
  final String description;

  HadithBook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
  });
}

class HadithCategory {
  final int id;
  final String title;

  HadithCategory({
    required this.id,
    required this.title,
  });
}

class HadithVocab {
  final String word;
  final String translation;

  HadithVocab({
    required this.word,
    required this.translation,
  });

  factory HadithVocab.fromJson(Map<String, dynamic> json) {
    return HadithVocab(
      word: json['word'] as String? ?? json['arabic'] as String? ?? '',
      translation: json['translation'] as String? ?? json['meaning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'translation': translation,
    };
  }
}

class Hadith {
  final int id;
  final int bookId;
  final int categoryId;
  final String narrator;
  final String text;
  final String source;
  final String explanation;
  final List<HadithVocab> vocabulary;
  final List<String> lifeApplications;

  Hadith({
    required this.id,
    required this.bookId,
    required this.categoryId,
    required this.narrator,
    required this.text,
    required this.source,
    required this.explanation,
    required this.vocabulary,
    required this.lifeApplications,
  });
}
