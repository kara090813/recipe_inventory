import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DottedBarWidget extends StatelessWidget {
  double paddingSize;
  Color lineColor;

  DottedBarWidget({this.paddingSize = 0, this.lineColor = const Color(0xFFA8927F)});

  @override
  Widget build(BuildContext context) {
    paddingSize = paddingSize == 0 ? 40.w : paddingSize;
    double screenWidth = MediaQuery.of(context).size.width - paddingSize;

    return Row(
      children: [
        Container(height: 1.5.h, width: screenWidth * 0.1, color: lineColor),
        Container(height: 1.5.h, width: screenWidth * 0.02, color: Colors.transparent),
        Container(height: 1.5.h, width: screenWidth * 0.56, color: lineColor),
        Container(height: 1.5.h, width: screenWidth * 0.02, color: Colors.transparent),
        Container(height: 1.5.h, width: screenWidth * 0.3, color: lineColor),
      ],
    );
  }
}
