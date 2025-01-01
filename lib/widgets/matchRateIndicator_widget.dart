import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchRateIndicator extends StatelessWidget {
  final int matchRate;

  const MatchRateIndicator({
    Key? key,
    required this.matchRate,
  }) : super(key: key);

  // 매치율에 따른 색상 및 텍스트 색상 반환
  (Color, Color) _getColors() {
    // 매치율을 10단계로 구분 (0-10%, 11-20%, ..., 91-100%)
    int level = (matchRate / 10).ceil();

    switch (level) {
      case 0:
      case 1:
        // 매우 낮음 (0-10%) - 연한 회색
        return (Color(0xFFEEEEEE), Color(0xFF666666));
      case 2:
      case 3:
        // 낮음 (11-30%) - 연한 주황빛 회색
        return (Color(0xFFF5ECE5), Color(0xFF996633));
      case 4:
        // 보통 낮음 (31-40%) - 연한 주황색
        return (Color(0xFFFFE5CC), Color(0xFFCC6600));
      case 5:
        // 중간 (41-50%) - 밝은 주황색
        return (Color(0xFFFFD6B3), Color(0xFFB35900));
      case 6:
        // 보통 높음 (51-60%) - 주황색
        return (Color(0xFFFFC299), Color(0xFFB35900));
      case 7:
        // 높음 (61-70%) - 진한 주황색
        return (Color(0xFFFFAD80), Color(0xFF803300));
      case 8:
        // 매우 높음 (71-80%) - 밝은 주황-빨간색
        return (Color(0xFFFF9966), Color(0xFF662200));
      case 9:
        // 최상 (81-90%) - 진한 주황-빨간색
        return (Color(0xFFFF794D), Color(0xFF4D1A00));
      case 10:
        // 완벽 (91-100%) - 강조 주황-빨간색
        return (Color(0xFFFF5C33), Colors.white);
      default:
        return (Color(0xFFEEEEEE), Color(0xFF666666));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          if (matchRate >= 70)
            BoxShadow(
              color: backgroundColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (matchRate >= 80)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Icon(
                Icons.check_circle_outline,
                color: textColor,
                size: 14.w,
              ),
            ),
          Text(
            '식재료 매치도 $matchRate%',
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
              fontWeight: matchRate >= 70 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
