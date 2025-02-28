import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

import '../status/_status.dart';

class AddDirectlySelected_component extends StatelessWidget {
  const AddDirectlySelected_component({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedFoodProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            SizedBox(height: 8.h,),
            FoodListWidget(
              partCount: 5,
              categoryIndex: 0,
              foodList: provider.selectedFoods,
              islabel: false,  // 라벨 제거
              isCategory: false,  // 카테고리 구분 없이 표시
              selectionMode: true,
            ),
          ],
        );
      },
    );
  }
}