import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';
import 'package:dotted_line/dotted_line.dart';

class IngredientTableWidget extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientTableWidget({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(ingredients.length);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Color(0xFFF6F0E8),
        borderRadius: BorderRadius.circular(10.r),
        border:Border.all(width: 1,color:Color(0xFFBB8F6A)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildColumn(ingredients, 0)),
            SizedBox(width: 8.w),
            CustomPaint(
                size: Size(1, double.infinity),
                painter: DashedLineVerticalPainter()
            ),
            SizedBox(width: 8.w),
            Expanded(child: _buildColumn(ingredients, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<Ingredient> ingredients, int startIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = startIndex; i < ingredients.length; i += 2)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h,horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ingredients[i].food,
                      style: TextStyle(fontSize: 12.sp, color: Color(0xFF5E3009)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      ingredients[i].cnt,
                      style: TextStyle(fontSize: 12.sp, color: Color(0xFF5E3009)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 10, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Color(0xFFBB8F6A)
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}