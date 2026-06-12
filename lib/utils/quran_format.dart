const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabicDigits(int n) {
  return n
      .toString()
      .split('')
      .map((d) => _arabicDigits[int.parse(d)])
      .join();
}

bool surahShowsBismillah(int surahId) {
  return surahId != 1 && surahId != 9;
}
