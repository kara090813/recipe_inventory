import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/models/data.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import 'package:recipe_inventory/widgets/filterButtons_widget.dart';
import '../widgets/filterPopup_widget.dart';
import '../models/_models.dart';
import '../status/_status.dart';

class SearchRecipeComponent extends StatefulWidget {
  const SearchRecipeComponent({super.key});

  @override
  State<SearchRecipeComponent> createState() => _SearchRecipeComponentState();
}

class _SearchRecipeComponentState extends State<SearchRecipeComponent> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FilterStatus, RecipeStatus>(
      builder: (context, filterStatus, recipeStatus, child) {
        if (recipeStatus.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // FilterStatus의 필터 정보를 기반으로 레시피 필터링
        final filteredRecipes = recipeStatus.getFilteredRecipes(
          searchQuery: recipeStatus.searchQuery,
          recipeType: filterStatus.getFilter('음식 종류')?.selectedValues.contains('전체') == true
              ? null
              : filterStatus.getFilter('음식 종류')?.selectedValues.join(','),
          difficulty: filterStatus.getFilter('조리 난이도')?.selectedValues.contains('전체') == true
              ? null
              : filterStatus.getFilter('조리 난이도')?.selectedValues.join(','),
          ingredientCount: filterStatus.getFilter('재료 개수')?.rangeValues,
        );

        return Column(
          children: [
            HeaderWidget(title: '레시피 탐색'),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 12.h),
            Column(
              children: [
                Container(
                  height: 37.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(width: 1, color: Color(0xFF707070)),
                  ),
                  child: TextField(
                    controller: searchController,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      print(value);
                      recipeStatus.updateSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: '레시피 검색',
                      hintStyle: TextStyle(color:Colors.grey,fontFamily: 'Mapo'),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF5E3009),
                        size: 30.w,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.h),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFEAE5DF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 34.h,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/recipeFilter');
                          },
                          child: Image.asset(
                            'assets/imgs/icons/controlpanel.png',
                            width: 20.w,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FilterButtonsWidget(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: filteredRecipes.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 100.h,
                        ),
                        Image.asset('assets/imgs/items/empty_logo.png',width: 110.w,),
                        SizedBox(
                          height: 14.h,
                        ),
                        Text(
                          "조건에 맞는 레시피가 없어요!\n조건을 다시 설정해보세요",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF707070)),
                        )
                      ],
                    )
                  : RecipeListWidget(
                      recipes: filteredRecipes,
                    ),
            ),
          ],
        );
      },
    );
  }
}
