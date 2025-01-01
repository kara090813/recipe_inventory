import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import '../components/_components.dart';

class FoodAddScreen extends StatefulWidget {
  const FoodAddScreen({super.key});

  @override
  State<FoodAddScreen> createState() => _FoodAddScreenState();
}

class _FoodAddScreenState extends State<FoodAddScreen> with SingleTickerProviderStateMixin {
  int _tabIndex = 2;
  bool _isInitialLoad = true;
  final double _indicatorHeight = 4.0;
  final Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _loadLastTab();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tabIndex = prefs.getInt('lastFoodAddTab') ?? 1;
      _isInitialLoad = true;
    });
  }

  Future<void> _saveLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastFoodAddTab', index);
  }

  void _clickIndex(int num) {
    setState(() {
      _tabIndex = num;
      _isInitialLoad = false;
    });
    _saveLastTab(num);
  }

  final List<Widget> _widgetOptions = <Widget>[
    AddScanComponent(),
    AddReceiptComponent(),
    AddDirectlyComponent(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40;

    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            Row(
              children: [
                BackButtonWidget(context),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  '식재료 추가',
                  style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                )
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            _buildTabs(screenWidth),
            SizedBox(
              height: 12.h,
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: _widgetOptions,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(double screenWidth) {
    return Container(
      height: 40.h, // 탭의 전체 높이 조정
      child: Stack(
        children: [
          Row(
            children: [
              _buildTabButton(0, "냉장고 스캔", screenWidth),
              _buildTabButton(1, "영수증 촬영", screenWidth),
              _buildTabButton(2, "직접 추가", screenWidth),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _indicatorHeight,
              color: Color(0xFFE4E4E4),
            ),
          ),
          AnimatedPositioned(
            duration: _isInitialLoad ? Duration.zero : _animationDuration,
            curve: Curves.ease,
            left: screenWidth * 0.333 * _tabIndex,
            bottom: 0,
            child: Container(
              width: screenWidth * 0.333,
              height: _indicatorHeight,
              color: Color(0xFF6C3311),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, double screenWidth) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _clickIndex(index),
        child: Container(
          color: Colors.transparent, // 터치 영역을 위해 투명한 배경 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _tabIndex == index ? Color(0xFF6C3311) : Color(0xFF919191),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h), // 텍스트와 바 사이의 간격
            ],
          ),
        ),
      ),
    );
  }
}
