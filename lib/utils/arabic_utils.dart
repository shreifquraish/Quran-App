/// Normalize Arabic text for search (remove diacritics, unify alef forms).
String normalizeArabic(String input) {
  var text = input.trim();
  if (text.isEmpty) return text;

  final diacritics = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u0610-\u061A\u06D6-\u06ED]',
  );
  text = text.replaceAll(diacritics, '');
  text = text
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ٱ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');
  return text;
}

String stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();
}
