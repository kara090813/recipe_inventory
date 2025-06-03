import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '_widgets.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, this.title = '냉장고 털이'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 4.h,
        ),
        Row(
          children: [
            Image.asset('assets/imgs/items/logo_d.png',width: 40.w,),
            SizedBox(
              width: 8.w,
            ),
            Text(
              title,
              style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
            ),
          ],
        ),
      ],
    );
  }
}
