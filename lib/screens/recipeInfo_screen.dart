import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import '../models/_models.dart';
import '../funcs/_funcs.dart';

class RecipeInfoScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeInfoScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final userFoods = context.watch<FoodStatus>().userFood;
    final classifiedIngredients = classifyIngredients(recipe, userFoods);
    final combinedFoods = [
      ...classifiedIngredients['available']!,
      ...classifiedIngredients['missing']!,
    ];
    // 각 Ingredient에 대해, 이름이 일치하는 Food를 찾아서 DisplayIngredient 생성
    List<DisplayIngredient> displayIngredients = recipe.ingredients.map((ingredient) {
      // Food의 name은 ingredient.food와 같게 설정되어 있음
      final matchedFood = combinedFoods.firstWhere(
        (food) => food.name == ingredient.food,
        orElse: () => Food(
          name: ingredient.food,
          type: '기타',
          img: 'assets/imgs/food/unknownFood.png',
        ),
      );
      return DisplayIngredient(
        food: ingredient.food,
        cnt: ingredient.cnt,
        img: matchedFood.img,
        type: matchedFood.type,
      );
    }).toList();
    const List<String> customOrder = [
      '육류',
      '수산물',
      '과일',
      '채소',
      '가공/유제품',
      '조미료/향신료',
      '기타',
    ];

// displayIngredients는 List<DisplayIngredient>라고 가정
    displayIngredients.sort((a, b) {
      final aIndex = customOrder.indexOf(a.type);
      final bIndex = customOrder.indexOf(b.type);
      return aIndex.compareTo(bIndex);
    });

    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                BackButtonWidget(context),
                SizedBox(width: 10.w),
                Text(
                  '레시피 정보',
                  style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                )
              ],
            ),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -1,
                            child: Container(
                              height: 14.h,
                              color: Color(0xFFFFD8A8),
                            ),
                          ),
                          Text(
                            recipe.title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        recipe.thumbnail,
                        fit: BoxFit.cover,
                        height: 200.h,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error));
                        },
                      ),
                    ),
                    if (isTablet(context))
                      SizedBox(
                        height: 8.h,
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: recipe.recipe_tags
                            .map((tag) => Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: Color(0xFF5E3009),
                                        fontSize: 12.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFFEAE5DF),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    if (isTablet(context))
                      SizedBox(
                        height: 4.h,
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          recipe.sub_title,
                          style: TextStyle(color: Color(0xFF707070), fontSize: 12.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    IngredientListWidget(ingredients: displayIngredients),
                    SizedBox(
                      height: 16.h,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("있는 식재료",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Color(0xFF149700),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    FoodListWidget(
                      foodList: classifiedIngredients['available']!,
                      isCategory: false,
                      multi: true,
                      partCount: 7,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("없는 식재료",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Color(0xFFFF0000),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    FoodListWidget(
                      foodList: classifiedIngredients['missing']!,
                      isCategory: false,
                      multi: true,
                      partCount: 7,
                      bkgColor: 0xFFBFBFBF,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // 가로, 세로 방향의 거리
              ),
            ],
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 6.h),
          child: Row(
            children: [
              Expanded(
                flex: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<RecipeStatus>(builder: (context, recipeStatus, child) {
                      return IconButton(
                        icon: Icon(
                          recipeStatus.isFavorite(recipe.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 32.sp,
                        ),
                        onPressed: () {
                          recipeStatus.toggleFavorite(recipe.id);
                        },
                      );
                    }),
                    SizedBox(
                      height: 5.h,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isTablet(context) ? 6.h : 0),
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFFF8B27),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r), // 버튼의 모서리를 둥글게
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/icons/cook.png',
                              width: 22.w,
                            ),
                            SizedBox(
                              width: isTablet(context) ? 6.w : 10.w,
                            ),
                            Text(
                              '요리 시작하기',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onPressed: () {
                          context.read<UserStatus>().startCooking(recipe);
                          context.push('/cookingStart', extra: recipe);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
