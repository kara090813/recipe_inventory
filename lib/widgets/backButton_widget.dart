import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Widget BackButtonWidget(BuildContext context) {
  return GestureDetector(
    onTap: () {
      context.pop();
    },
    child: Container(
      padding: EdgeInsets.all(10.w), // 패딩을 추가하여 터치 영역 확대
      color: Colors.transparent, // 터치 영역을 위해 투명한 배경 추가
      child: Image.asset(
        'assets/imgs/icons/back_arrow.png',
        width: 26.w,
      ),
    ),
  );
}