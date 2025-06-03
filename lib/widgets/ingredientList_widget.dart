import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/_models.dart';

/// 점선을 그려주는 Painter (변경 없음)
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DottedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 3,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// IngredientListWidget: DisplayIngredient 목록을 표시
class IngredientListWidget extends StatelessWidget {
  final List<DisplayIngredient> ingredients;

  const IngredientListWidget({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 컨테이너 디자인
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E8), // 배경색
        border: Border.all(
          color: const Color(0x405E3009), // #5E3009 (25% 투명도)
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
      ),
      padding: const EdgeInsets.all(16.0), // 내부 패딩
      child: Column(
        children: ingredients.map((di) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildDisplayIngredientRow(di),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisplayIngredientRow(DisplayIngredient di) {
    const textColor = Color(0xFF5E3009);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 왼쪽에 이미지 표시 (불릿 아이콘 대신)
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            di.img,
            width: 28.w,
            height: 28.w,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 8.w),
        // 식재료 이름
        Text(
          di.food,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: 8.w),
        // 가운데 점선 (디자인 요소)
        Expanded(
          child: CustomPaint(
            painter: DottedLinePainter(
              color: textColor.withOpacity(0.5), // 점선 색 (투명도 적용)
              dashWidth: 4,
              dashSpace: 3,
              strokeWidth: 1,
            ),
            size: const Size(double.infinity, 1),
          ),
        ),
        SizedBox(width: 8.w),
        // 오른쪽에 수량 표시 (원래 Ingredient의 cnt)
        Text(
          di.cnt,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
