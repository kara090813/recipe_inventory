import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../status/selectedFoodProvider.dart';

class RoundedButtonPairWidget extends StatelessWidget {
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;

  const RoundedButtonPairWidget({
    Key? key,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedFoodProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Expanded(
                flex: 46,
                child: ElevatedButton(
                  onPressed: onLeftButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5E3009),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                  child: Text(
                    '초기화',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 46,
                child: ElevatedButton(
                  onPressed: onRightButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8B27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                  child: Text(
                    '추가하기 (총 ${provider.selectedFoods.length}개)',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}