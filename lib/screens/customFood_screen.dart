import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '_screens.dart';
import '../widgets/_widgets.dart';

class CustomFoodScreen extends StatefulWidget {
  @override
  _CustomFoodScreenState createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _widgetOptions = <Widget>[
    CustomFoodAddTabScreen(),  // 커스텀 식재료 추가 탭
    CustomFoodDeleteTabScreen(),  // 커스텀 식재료 삭제 탭
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (index == 0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Widget _buildTab(String text, int index, double width) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        width: width,
        height: 48.h,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF5E3009),
            fontSize: 13.sp,
            fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double tabWidth = (MediaQuery.of(context).size.width - 44.w) / 2;

    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/imgs/icons/back_arrow.png',
                      width: 26.w,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '커스텀 식재료',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 40.w),
              ],
            ),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 20.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFEAE5DF),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: 4.w + (tabWidth - 8.w) * _animation.value,
                        top: 4.h,
                        child: Container(
                          width: tabWidth - 8.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      _buildTab('커스텀 식재료 추가', 0, tabWidth),
                      _buildTab('커스텀 식재료 삭제', 1, tabWidth),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _widgetOptions[_selectedTabIndex],
            ),
          ],
        ),
      ),
    );
  }
}