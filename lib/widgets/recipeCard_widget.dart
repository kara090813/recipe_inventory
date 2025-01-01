import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../status/_status.dart';
import '../models/_models.dart';
import 'package:dotted_line/dotted_line.dart';

import '_widgets.dart';

class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardWidget({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeStatus>(builder: (context, recipeStatus, child) {
      return GestureDetector(
        onTap: () {
          context.push('/recipeInfo', extra: recipe);
        },
        child: Card(
          margin: EdgeInsets.only(bottom: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(color: Color(0xFFBB885E), width: 1.w),
          ),
          elevation: 5,
          shadowColor: Colors.grey.withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.r),
                        ),
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: FractionalTranslation(
                            translation: Offset(0, 0),
                            child: Transform.scale(
                              scale: 0.5,
                              child: Image.network(
                                recipe.thumbnail,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.error));
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 55,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                recipe.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8B27),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              recipe.sub_title,
                              style: TextStyle(fontSize: 12.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 4.w,
                              runSpacing: 4.h,
                              children: recipe.recipe_tags
                                  ?.map((tag) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  tag,
                                  style:
                                  TextStyle(fontSize: 10.sp, color: Colors.black87),
                                ),
                              ))
                                  .toList() ??
                                  [],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFF3E6),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r),
                      bottomRight:Radius.circular(12.r))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            recipeStatus.toggleFavorite(recipe.id);
                          },
                          child: Icon(
                            size: 20.w,
                            recipeStatus.isFavorite(recipe.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: recipeStatus.isFavorite(recipe.id)
                                ? Colors.red
                                : Color(0xFF8A634C),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '좋아요',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF8A634C),
                          ),
                        ),
                      ],
                    ),
                    Consumer<FoodStatus>(
                      builder: (context, foodStatus, child) {
                        final matchRate =  foodStatus.calculateMatchRate(recipe
                            .ingredients);
                        return MatchRateIndicator(matchRate: matchRate);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}