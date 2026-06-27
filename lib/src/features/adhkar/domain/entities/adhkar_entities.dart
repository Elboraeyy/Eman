class AdhkarCategory {
  final int id;
  final String title;
  final String description;

  AdhkarCategory({
    required this.id,
    required this.title,
    required this.description,
  });
}

class AdhkarItem {
  final int id;
  final int categoryId;
  final String text;
  final int targetCount;
  final String reference;

  AdhkarItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.targetCount,
    required this.reference,
  });
}

class AdhkarProgress {
  final int id;
  final int itemId;
  final int count;
  final String date;

  AdhkarProgress({
    required this.id,
    required this.itemId,
    required this.count,
    required this.date,
  });
}

class Tasbih {
  final int id;
  final String phrase;
  final int count;
  final int target;
  final DateTime updatedAt;

  Tasbih({
    required this.id,
    required this.phrase,
    required this.count,
    required this.target,
    required this.updatedAt,
  });
}
