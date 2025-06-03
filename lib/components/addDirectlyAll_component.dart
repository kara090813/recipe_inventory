import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';

import '../models/data.dart';
import '../widgets/_widgets.dart';

class AddDirectlyAllComponent extends StatefulWidget {
  const AddDirectlyAllComponent({super.key});

  @override
  State<AddDirectlyAllComponent> createState() => _AddDirectlyAllComponentState();
}

class _AddDirectlyAllComponentState extends State<AddDirectlyAllComponent> {
  int _selectedCategoryIndex = 0;

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryWidget(onTabSelected: _onCategorySelected),
        SizedBox(height: 2.h),
        if (isTablet(context))
          SizedBox(
            height: 10.h,
          ),
        Row(
          children: [
            Expanded(
              flex: 70,
              child: InkWell(
                onTap: () {
                  context.push('/foodSearch');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF5E3009)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        SizedBox(width: 14.w),
                        Image.asset(
                          'assets/imgs/icons/search.png',
                          width: 20.w,
                        ),
                        SizedBox(width: 30.w),
                        Text(
                          ' 클릭하여 식재료 검색',
                          style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w), // 컨테이너 사이 간격 추가
            Expanded(
                flex: 30,
                child: InkWell(
                  onTap: () {
                    context.push('/customFood');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6.h), // 패딩
                    // 추가하여
                    // 높이 통일
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8B27),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      // 텍스트 중앙 정렬
                      child: Text(
                        "커스텀 재료",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
        SizedBox(height: 4.h),
        if(isTablet(context))
          SizedBox(height: 10.h,),
        FoodListWidget(
          partCount: 5,
          categoryIndex: _selectedCategoryIndex,
          foodList: hardCopyFoodList(FOOD_LIST),
          bkgColor: 0xFFBDD8D8,
          partColor: 0xFFF5F5F5,
          islabel: true,
          selectionMode: true,
        )
      ],
    );
  }
}
