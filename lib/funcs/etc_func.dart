String getKoreanWeekday(int weekday) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return weekdays[weekday - 1];
}