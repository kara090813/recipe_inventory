import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:recipe_inventory/models/data.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import 'package:recipe_inventory/widgets/filterButtons_widget.dart';
import 'package:recipe_inventory/widgets/filterPopup_widget.dart';
import '../models/_models.dart';
import '../status/_status.dart';

class SearchRecipeComponent extends StatefulWidget {
  const SearchRecipeComponent({super.key});

  @override
  State<SearchRecipeComponent> createState() => _SearchRecipeComponentState();
}

class _SearchRecipeComponentState extends State<SearchRecipeComponent> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode(); // FocusNode 추가

  @override
  void initState() {
    super.initState();
    // 컴포넌트 진입 시 레시피 섞기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeStatus>().shuffleRecipes();
      searchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    // 컨트롤러 정리
    searchController.dispose();
    searchFocusNode.dispose();
    
    // 추천 서비스 캐시 정리 (메모리 절약)
    RecipeRecommendationService.reduceCacheSize();
    
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchFocusNode.unfocus();
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<FilterStatus, RecipeStatus, ({bool isLoading, String searchQuery, List<Recipe> recipes, Map<String, dynamic> filters})>(
      selector: (context, filterStatus, recipeStatus) => (
        isLoading: recipeStatus.isLoading,
        searchQuery: recipeStatus.searchQuery,
        recipes: recipeStatus.recipes,
        filters: filterStatus.getAllFilters(),
      ),
      builder: (context, data, child) {
        if (data.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final filterStatus = context.read<FilterStatus>();
        final recipeStatus = context.read<RecipeStatus>();

        // FilterStatus의 필터 정보를 기반으로 레시피 필터링
        final filteredRecipes = recipeStatus.getFilteredRecipes(
          context,
          searchQuery: recipeStatus.searchQuery,
          recipeType: filterStatus
              .getFilter('음식 종류')
              ?.selectedValues
              .contains('전체') == true
              ? null
              : filterStatus
              .getFilter('음식 종류')
              ?.selectedValues
              .join(','),
          difficulty: filterStatus
              .getFilter('조리 난이도')
              ?.selectedValues
              .contains('전체') == true
              ? null
              : filterStatus
              .getFilter('조리 난이도')
              ?.selectedValues
              .join(','),
          ingredientCount: filterStatus
              .getFilter('재료 개수')
              ?.rangeValues,
          matchRate: filterStatus
              .getFilter('내 식재료 매치도')
              ?.selectedValues
              .contains('제한없음') == true
              ? null
              : filterStatus
              .getFilter('내 식재료 매치도')
              ?.rangeValues,
        );

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeaderWidget(title: '레시피 탐색'),
                  IconButton(
                    onPressed: () {
                      context.push('/custom');
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF5E3009),
                      size: 28.w,
                    ),
                  ),
                ],
              ),
          SizedBox(height: 10.h),
          DottedBarWidget(),
          SizedBox(height: 12.h),
          Column(
            children: [
              TextField(
                autofocus: false,
                focusNode: searchFocusNode,
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  recipeStatus.updateSearchQuery(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: '레시피 검색',
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Mapo',
                      fontSize: isTablet(context) ? 12.sp : 15.5.sp),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF5E3009),
                    size: isTablet(context) ? 20.w : 30.w,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Color(0xFF707070)),),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Color(0xFF5E3009)))
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: isTablet(context) ? 50.h : 46.h,
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
                            FocusScope.of(context).unfocus();
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
              SizedBox(height: 6.h),
              Expanded(
                child: CustomRefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(Duration(milliseconds: 50));
                    recipeStatus.shuffleRecipes();
                  },
                  builder: (context, child, controller) {
                    return Stack(
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(0.0, 55.0 * controller.value),
                          child: child,
                        ),
                        if (controller.value > 0)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 55.0 * controller.value,
                              child: Center(
                                child: Transform.rotate(
                                  angle: controller.value * 2 * 3.14,
                                  child: Icon(
                                    Icons.refresh,
                                    color: Color(0xFFFF8B27),
                                    size: 30 * controller.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  offsetToArmed: 55.0,
                  child: filteredRecipes.isEmpty
                      ? Column(
                    children: [
                      SizedBox(height: 100.h),
                      Image.asset(
                        'assets/imgs/items/empty_logo.png',
                        width: 110.w,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        "조건에 맞는 레시피가 없어요!\n조건을 다시 설정해보세요",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF707070)),
                      )
                    ],
                  )
                      : GestureDetector(
                      onTap: () {
                        searchFocusNode.unfocus();
                      },
                      child:AdSupportedRecipeListWidget(
                        recipes: filteredRecipes,
                        node: searchFocusNode,
                        adFrequency: 4, // 5개의 레시피마다 광고 표시 (필요에 따라 조정)
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
