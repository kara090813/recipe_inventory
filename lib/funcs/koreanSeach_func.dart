// utils/korean_utils.dart

// 초성 리스트
const List<String> CHOSUNG_LIST = [
  'ㄱ',
  'ㄲ',
  'ㄴ',
  'ㄷ',
  'ㄸ',
  'ㄹ',
  'ㅁ',
  'ㅂ',
  'ㅃ',
  'ㅅ',
  'ㅆ',
  'ㅇ',
  'ㅈ',
  'ㅉ',
  'ㅊ',
  'ㅋ',
  'ㅌ',
  'ㅍ',
  'ㅎ'
];

// 문자열을 초성으로 변환
String getChosungString(String str) {
  return str.runes.map((rune) {
    final char = String.fromCharCode(rune);
    if (isKorean(char)) {
      final index = ((rune.toInt() - 0xAC00) ~/ 28 ~/ 21);
      return CHOSUNG_LIST[index];
    }
    return char;
  }).join();
}

// 한글인지 확인
bool isKorean(String char) {
  return RegExp(r'[가-힣]').hasMatch(char);
}

// 초성 매칭 확인
bool matchChosung(String query, String target) {
  final queryChosung = getChosungString(query);
  final targetChosung = getChosungString(target);
  return targetChosung.contains(queryChosung);
}

bool isChosungString(String str) {
  return str.runes.every((rune) {
    final char = String.fromCharCode(rune);
    return CHOSUNG_LIST.contains(char) || !isKorean(char);
  });
}

String decompose(String text) {
  return text.runes.map((rune) {
    final char = String.fromCharCode(rune);
    if (isKorean(char)) {
      final index = ((rune.toInt() - 0xAC00) ~/ 28 ~/ 21);
      return CHOSUNG_LIST[index];
    }
    return char;
  }).join();
}

bool isChosungOrMixedString(String str) {
  return str.runes.any((rune) {
    final char = String.fromCharCode(rune);
    return CHOSUNG_LIST.contains(char) || !isKorean(char);
  });
}

bool matchChosungOrMixed(String query, String target) {
  final decomposedQuery = decompose(query);
  final decomposedTarget = decompose(target);
  return decomposedTarget.contains(decomposedQuery);
}
