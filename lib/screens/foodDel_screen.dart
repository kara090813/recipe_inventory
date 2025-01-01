import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

import '../models/freezed/food_model.dart';
import '../status/_status.dart';

class FoodDelScreen extends StatefulWidget {
  const FoodDelScreen({super.key});

  @override
  State<FoodDelScreen> createState() => _FoodDelScreenState();
}

class _FoodDelScreenState extends State<FoodDelScreen> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userFoodList = context.watch<FoodStatus>().userFood;
    return ChangeNotifierProvider(
      create: (context) => SelectedFoodProvider(),
      child: Scaffold(
        body: ScaffoldPaddingWidget(
          child: Column(
            children: [
              HeaderWidget(),
              SizedBox(
                height: 6.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "식재료 종류",
                    style: TextStyle(color: Color(0xFF6C3311), fontSize: 16.sp),
                  ),
                  InkWell(
                      onTap: () {
                        context.pop();
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/imgs/icons/back_orange.png',
                            width: 10.w,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            '나가기',
                            style: TextStyle(color: Color(0xFFFF8B27)),
                          )
                        ],
                      ))
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              DottedBarWidget(),
              CategoryWidget(onTabSelected: _onTabSelected),
              FoodListWidget(
                categoryIndex: _selectedTabIndex,
                foodList: userFoodList,
                // 사용자의 식재료 리스트를 전달
                bkgColor: 0xFFBFBFBF,
                checkColor: Colors.red,
                selectionMode: true,
              ),
              SizedBox(height: 10.h,),
              Consumer<SelectedFoodProvider>(builder: (context, provider, child) {
                return Column(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFF3D1D1),
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    height: 110.h,
                    child: Column(
                      children: [
                        Expanded(
                            flex:58,
                            child: Container(
                              padding: EdgeInsets.only(left: 16.w, top: 4.w, right: 16.w),
                              child: Row(
                                children: List.generate(provider.selectedFoods.length, (index) {
                                  Food clickItem = provider.selectedFoods[index];

                                  return [
                                    Stack(
                                      children: [
                                        Positioned(
                                            top: 4.h,
                                            child: InkWell(
                                              onTap: () {
                                                provider.toggleFood(clickItem);
                                              },
                                              child: Image.asset(
                                                'assets/imgs/icons/red_x.png',
                                                width: 12.w,
                                              ),
                                            )),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 4.h,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  provider.toggleFood(clickItem);
                                                },
                                                child: Image.asset(
                                                  clickItem.img,
                                                  width: 30.w,
                                                ),
                                              ),
                                              Text(
                                                clickItem.name,
                                                style: TextStyle(fontSize: 12.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 12.w,
                                    )
                                  ];
                                }).expand((element) => element).toList(),
                              ),
                            )),
                        Expanded(
                            flex: 42,
                            child: InkWell(
                              onTap: (){
                                Provider.of<FoodStatus>(context,listen: false).removeFoods(provider.selectedFoods);
                                provider.clearSelection();
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Color(0xFFDB2222), borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: provider.selectedFoods.length == 0
                                      ? Text(
                                    "삭제할 식재료를 선택해주세요",
                                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                                  )
                                      : Text("총 " + provider.selectedFoods.length.toString() + "개 삭제하기",
                                      style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ],);
              }),
              SizedBox(height: 16.h,),
            ],
          ),
        ),
      ),
    );
  }
}
