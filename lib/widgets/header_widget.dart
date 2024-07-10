import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40.w;
    final mainTextColor = Color(0xFF6C3311);
    final subTextColor = Color(0xFF919191);

    return Column(
      children: [
        SizedBox(
          height: 4.h,
        ),
        Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 2)),
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              '재고떨이',
              style: TextStyle(color: Color(0xFF7D674B), fontSize: 18.sp),
            ),
            Spacer(),
            ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                child: Image.asset(
                  'assets/imgs/icons/bar_my.png',
                  width: 24.w,
                )),
            SizedBox(
              width: 8.w,
            )
          ],
        ),
        SizedBox(
          height: 12.h,
        ),
        Row(
          children: [
            Container(height: 1.3.h, width: screenWidth * 0.1, color: mainTextColor),
            Container(height: 1.3.h, width: screenWidth * 0.02, color: Colors.transparent),
            Container(height: 1.3.h, width: screenWidth * 0.56, color: mainTextColor),
            Container(height: 1.3.h, width: screenWidth * 0.02, color: Colors.transparent),
            Container(height: 1.3.h, width: screenWidth * 0.3, color: mainTextColor),
          ],
        ),
        SizedBox(
          height: 10.h,
        )
      ],
    );
  }
}
