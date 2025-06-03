import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../funcs/_funcs.dart';
import '../models/data.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class AddReceiptComponent extends StatefulWidget {
  const AddReceiptComponent({super.key});

  @override
  State<AddReceiptComponent> createState() => _AddReceiptComponentState();
}

class _AddReceiptComponentState extends State<AddReceiptComponent> {
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
                context.push('/foodAdd/receiptScan');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/items/receipt.png',
                    width: 49.w,
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Text(
                    "여기를 눌러 영수증 촬영을 시작하세요",
                    style: TextStyle(color: Color(0xFF6C3311), fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Text(
                    "카메라로 영수증을 촬영하면\nAI가 자동으로 인식하여 추가합니다.",
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

        Consumer<SelectedFoodProvider>(
          builder: (context, provider, child) {
            return FoodListWidget(
              foodList:provider.selectedFoods,
              isCategory: false,
              bkgPattern: true,
              selectionMode: true,
              partColor: 0xFF626262,
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
