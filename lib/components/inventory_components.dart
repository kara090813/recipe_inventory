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
