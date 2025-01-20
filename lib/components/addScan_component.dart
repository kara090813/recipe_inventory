import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:recipe_inventory/models/data.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

import '../status/_status.dart';

class AddScanComponent extends StatefulWidget {
  const AddScanComponent({super.key});

  @override
  State<AddScanComponent> createState() => _AddScanComponentState();
}

class _AddScanComponentState extends State<AddScanComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: isTablet(context) ? 240.h : 180.h,
          decoration: BoxDecoration(
              color: Color(0xFFF6E7DB),
              border: Border.all(width: 2, color: Color(0xFFA8927F)),
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: InkWell(
              onTap: (){
                context.push('/foodAdd/refrigeratorScan');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/items/camera.png',
                    width: 60.w,
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Text(
                    "여기를 눌러 냉장고 스캔을 시작하세요",
                    style: TextStyle(color: Color(0xFF6C3311), fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Text(
                    "카메라로 냉장고 속 식재료들을 스캔하면\nAI가 자동으로 인식하여 추가합니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF898989), fontSize: 12.sp),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "인식된 식재료",
              style: TextStyle(fontSize: 16.sp),
            )),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            ' *인식되지 않은 식재료는 [직접 추가]를 통해 추가해주세요',
            style:
            TextStyle(color: Color(0xFFFF8B27), fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        // FoodListWidget(foodList: hardCopyFoodList(FOOD_LIST.sublist(0,10)),isCategory: false,),
        Consumer<SelectedFoodProvider>(
          builder: (context, provider, child) {
            return FoodListWidget(
              foodList:provider.selectedFoods,
              isCategory: false,
              selectionMode: true,
            );
          },
        ),
        Consumer<SelectedFoodProvider>(
            builder: (context, provider, child) {
              return provider.selectedFoods.isEmpty ? SizedBox.shrink() : RoundedButtonPairWidget(
                  onLeftButtonPressed: () {
                    resetFoodFunc(context);
                  },
                  onRightButtonPressed: () {
                    addFoodFunc(provider.selectedFoods, context);
                  }
              );
            }
        ),
        SizedBox(height: 16.h,)
      ],
    );
  }
}
