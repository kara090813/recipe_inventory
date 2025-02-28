import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import '../models/_models.dart';

class RecipeWishListWidget extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipeWishListWidget({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 최대 4개의 레시피만 표시
    final displayRecipes = recipes.take(4).toList();

    return SizedBox(
      height: isTablet(context) ? 200.h : 170.h, // 카드의 높이에 맞게 조정
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayRecipes.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap:(){
              context.push('/recipeInfo', extra: displayRecipes[index]);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: RecipeWishCard(recipe: displayRecipes[index]),
            ),
          );
        },
      ),
    );
  }
}

class RecipeWishCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeWishCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color:Color(0xFFBB885E)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9.r),
              topRight: Radius.circular(9.r),
            ),
            child: Image.network(
              recipe.thumbnail,
              height: 100.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: recipe.recipe_tags
                        ?.take(3).map((tag) => Row(
                          children: [
                            Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(fontSize: 10.sp, color: Colors.black87),
                                  ),
                                ),
                            SizedBox(width: 4.w,)
                          ],
                        ))
                        .toList() ??
                    [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
