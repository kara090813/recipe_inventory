import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/freezed/badge_model.dart' as BadgeModel;

class BadgeUnlockPopupWidget extends StatelessWidget {
  final BadgeModel.Badge badge;
  final VoidCallback? onConfirm;

  const BadgeUnlockPopupWidget({
    Key? key,
    required this.badge,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉 새로운 뱃지 획득! 🎉',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8B27),
              ),
            ),
            SizedBox(height: 16.h),
            Image.asset(
              badge.imagePath,
              width: 80.w,
              height: 80.w,
            ),
            SizedBox(height: 16.h),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D674B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF969696),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8B27),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 정적 메소드로 팝업 표시
  static Future<void> show(
    BuildContext context,
    BadgeModel.Badge badge, {
    VoidCallback? onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 비활성화
      builder: (context) => BadgeUnlockPopupWidget(
        badge: badge,
        onConfirm: onConfirm,
      ),
    );
  }
}