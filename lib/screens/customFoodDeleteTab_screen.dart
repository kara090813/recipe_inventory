import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../models/data.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class CustomFoodDeleteTabScreen extends StatefulWidget {
  const CustomFoodDeleteTabScreen({super.key});

  @override
  State<CustomFoodDeleteTabScreen> createState() => _CustomFoodDeleteTabScreenState();
}

class _CustomFoodDeleteTabScreenState extends State<CustomFoodDeleteTabScreen> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // FOOD_LIST에서 커스텀 식재료만 필터링
    final customFoodList = FOOD_LIST.where((food) => food.isCustom).toList();

    return ChangeNotifierProvider(
      create: (context) => SelectedFoodProvider(),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          FoodListWidget(
            islabel: true,
            categoryIndex: _selectedTabIndex,
            foodList: customFoodList,
            bkgColor: 0xFFBFBFBF,
            checkColor: Colors.red,
            selectionMode: true,
          ),
          SizedBox(height: 10.h,),
          Consumer<SelectedFoodProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF3D1D1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      height: 110.h,
                      child: Column(
                        children: [
                          Expanded(
                              flex: 58,
                              child: Container(
                                padding: EdgeInsets.only(left: 16.w, top: 4.w, right: 16.w),
                                child: Row(
                                  children: List.generate(provider.selectedFoods.length, (index) {
                                    Food clickItem = provider.selectedFoods[index];
                                    return [
                                      Stack(
                                        children: [

                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 4.h),
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
                                              )
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 12.w)
                                    ];
                                  }).expand((element) => element).toList(),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 42,
                              child: InkWell(
                                onTap: () async {
                                  if (provider.selectedFoods.isEmpty) return;

                                  // 1. FOOD_LIST에서 삭제
                                  for (var food in provider.selectedFoods) {
                                    FOOD_LIST.removeWhere((f) => f.name == food.name && f.isCustom);
                                  }

                                  // 2. CustomFoodService를 통해 변경사항 저장
                                  final customFoodService = CustomFoodService();
                                  final remainingCustomFoods = FOOD_LIST.where((f) => f.isCustom).toList();
                                  await customFoodService.saveCustomFoods(remainingCustomFoods);

                                  // 3. 사용자 보유 식재료에서도 삭제
                                  Provider.of<FoodStatus>(context, listen: false)
                                      .removeFoods(provider.selectedFoods);

                                  // 4. 선택 상태 초기화
                                  provider.clearSelection();

                                  // 5. 상태 업데이트를 위해 setState 호출
                                  setState(() {});

                                  Navigator.pop(context);
                                  // foodAdd 화면도 닫아서 메인으로 돌아간 다음
                                  Navigator.pop(context);
                                  // 다시 foodAdd로 push
                                  context.push('/foodAdd');
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFDB2222),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(
                                    child: Text(
                                      provider.selectedFoods.isEmpty
                                          ? "삭제할 커스텀 식재료를 선택해주세요"
                                          : "총 ${provider.selectedFoods.length}개 삭제하기",
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}