extension ArabicNumbersExtension on String {
  String toArabicNumbers() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

extension ArabicIntExtension on int {
  String toArabicNumbers() {
    return toString().toArabicNumbers();
  }
}

extension ArabicDoubleExtension on double {
  String toArabicNumbers({int fractionDigits = 1}) {
    return toStringAsFixed(fractionDigits).toArabicNumbers();
  }
}
