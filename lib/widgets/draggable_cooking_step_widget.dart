import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReorderableCookingStepsList extends StatelessWidget {
  final List<String> cookingSteps;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onRemove;

  const ReorderableCookingStepsList({
    Key? key,
    required this.cookingSteps,
    required this.onReorder,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            onReorder(oldIndex, newIndex);
          },
          itemCount: cookingSteps.length,
          itemBuilder: (context, index) {
            return Container(
              key: ValueKey('cooking_step_$index'),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Color(0xFFFDF8F4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Color(0xFFDEB887),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      // 드래그 핸들
                      Icon(
                        Icons.drag_indicator,
                        color: Color(0xFF999999),
                        size: 24.w,
                      ),
                      SizedBox(width: 12.w),
                      
                      // 단계 번호
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8C00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      
                      // 단계 내용
                      Expanded(
                        child: Text(
                          cookingSteps[index],
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      
                      // 삭제 버튼
                      GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5722),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF5722).withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 60.h), // 하단 패딩
      ],
    );
  }
}