import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import '../funcs/_funcs.dart';
import '../main.dart';
import '../models/_models.dart';
import '../models/data.dart';
import '../status/_status.dart';

class InventoryComponents extends StatefulWidget {
  const InventoryComponents({super.key});

  @override
  State<InventoryComponents> createState() => _InventoryComponentsState();
}

class _InventoryComponentsState extends State<InventoryComponents> {
  int _selectedTabIndex = 0;
  bool _isNotificationInProgress = false;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  // 레시피 추천 알림 테스트 함수
  Future<void> _testRecipeNotification() async {
    // 중복 호출 방지
    if (_isNotificationInProgress) return;

    setState(() {
      _isNotificationInProgress = true;
    });

    try {
      // 즉시 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('20초 후에 레시피 추천 알림이 표시됩니다!')),
      );

      // 레시피 알림 예약
      await scheduleTestRecipeNotificationIn20Seconds();

      print('레시피 알림이 성공적으로 예약되었습니다');
    } catch (e) {
      print('알림 예약 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 예약에 실패했습니다: $e')),
      );
    } finally {
      setState(() {
        _isNotificationInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // FoodStatus에서 사용자의 식재료 리스트를 가져옵니다.
    final userFoodList = context.watch<FoodStatus>().userFood;

    return Column(
      children: [
        HeaderWidget(),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "식재료 종류",
              style: TextStyle(color: Color(0xFF6C3311), fontSize: 16.sp),
            ),
            // Row(
            //   children: [
            //     // 레시피 알림 테스트 버튼 추가
            //     TextButton(
            //       onPressed: _isNotificationInProgress ? null : _testRecipeNotification,
            //       style: TextButton.styleFrom(
            //         backgroundColor: _isNotificationInProgress ? Colors.grey : Color(0xFFFF8B27),
            //         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8.r),
            //         ),
            //       ),
            //       child: Text(
            //         _isNotificationInProgress ? "처리 중..." : "20초 후 레시피 알림",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 12.sp,
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 8.w),
            //     InkWell(
            //         onTap: () {
            //           context.push('/foodDel');
            //         },
            //         child: Image.asset('assets/imgs/icons/trash.png', width: 18.w)
            //     ),
            //   ],
            // ),
            InkWell(
                onTap: () {
                  context.push('/foodDel');
                },
                child: Image.asset('assets/imgs/icons/trash.png', width: 18.w)),
          ],
        ),
        SizedBox(height: 2.h),
        DottedBarWidget(),
        if (isTablet(context)) SizedBox(height: 10.h),
        CategoryWidget(onTabSelected: _onTabSelected),
        if (isTablet(context)) SizedBox(height: 10.h),
        FoodListWidget(
          partCount: 6,
          categoryIndex: _selectedTabIndex,
          bkgColor: 0xFFBDD8D8,
          foodList: userFoodList, // 사용자의 식재료 리스트를 전달
        ),
      ],
    );
  }
}
