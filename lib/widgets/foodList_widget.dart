import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

import '../models/_models.dart';
import '../models/data.dart';

class FoodListWidget extends StatelessWidget {
  const FoodListWidget({
    super.key,
    this.checkColor = Colors.green,
    this.islabel = false,
    this.categoryIndex = 0,
    this.isCategory = true,
    this.bkgColor = 0xFFD3E7E7,
    this.partColor = 0xFFFFFFFF,
    this.partCount = 7,
    this.bkgPattern = false,
    this.selectionMode = false,
    this.multi = false,
    required this.foodList,
  });

  final Color checkColor;
  final bool islabel;
  final bool isCategory;
  final bool bkgPattern;
  final int partCount;
  final int bkgColor;
  final int partColor;
  final int categoryIndex;
  final List<Food> foodList;
  final bool selectionMode;
  final bool multi;

  Widget FoodContainer(String foodContainerTitle, List<Food> foods, int index) {
    int containerCount = foods.isEmpty ? 1 : (foods.length / partCount).ceil();

    List<String> titleParts = foodContainerTitle.split('/');

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (islabel)
              Expanded(
                flex: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8.h,
                    ),
                    Column(
                      children: [
                        Image.asset(
                          LABEL_IMAGE[index % LABEL_IMAGE.length],
                          width: 40.w,
                          height: 40.w,
                        ),
                        SizedBox(height: 2.h),
                        Column(
                          children: titleParts
                              .map((part) => Text(
                                    part.trim(),
                                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF3E3E3E)),
                                    textAlign: TextAlign.center,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              flex: islabel ? 85 : 100,
              child: Container(
                decoration: BoxDecoration(
                  color: bkgPattern ? null : Color(bkgColor),
                  image: bkgPattern
                      ? DecorationImage(
                          image: AssetImage('assets/imgs/background/part_pattern.png'),
                          fit: BoxFit.fitWidth,
                          repeat: ImageRepeat.repeatY,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 6.h),
                        if (isCategory && !islabel)
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                foodContainerTitle,
                                style: TextStyle(color: Color(0xFF3E3E3E), fontSize: 12.sp),
                              ),
                            ],
                          ),
                        for (int i = 0; i < containerCount; i++)
                          FoodPartWidget(
                            foods: foods.isEmpty
                                ? []
                                : foods.skip(i * partCount).take(partCount).toList(),
                            partCount: partCount,
                            partColor: Color(partColor),
                            checkColor: checkColor,
                            selectionMode: selectionMode,
                          ),
                      ],
                    ),
                    foods.isEmpty
                        ? SizedBox(
                            height: 10.h,
                          )
                        : SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  List<Widget> _buildFoodListWidgets() {
    if (!isCategory) {
      // 카테고리 구분 없이 전체 리스트 출력
      return [FoodContainer('선택된 식재료', foodList, 0)];
    } else if (categoryIndex == 0) {
      // '전체' 카테고리가 선택된 경우
      return FOOD_CATEGORY.skip(1).toList().asMap().entries.map((entry) {
        int index = entry.key;
        String category = entry.value;
        List<Food> categoryFoods = foodList.where((food) => food.type == category).toList();
          return FoodContainer(category, categoryFoods, index);

      }).toList();
    } else {
      // 특정 카테고리가 선택된 경우
      String category = FOOD_CATEGORY[categoryIndex];
      List<Food> categoryFoods = foodList.where((food) => food.type == category).toList();
      return [FoodContainer(category, categoryFoods, categoryIndex - 1)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return multi
        ? Container(
            child: Column(
              children: _buildFoodListWidgets(),
            ),
          )
        : Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
              children: _buildFoodListWidgets(),
            ),
          );
  }
}
