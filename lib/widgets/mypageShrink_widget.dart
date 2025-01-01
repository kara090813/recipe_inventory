import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MypageShrinkWidget extends StatelessWidget {
  final Widget child;

  const MypageShrinkWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 6,
                offset: Offset(0, 2), // x축은 0, y축은 5만큼 이동
              )
            ],
            border: Border.all(color: Color(0xFFBB885E), width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Center(child: child));
  }
}
