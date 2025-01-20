import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import '../status/_status.dart';
import '../models/_models.dart';

import '_widgets.dart';

class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;
  final FocusNode node;

  const RecipeCardWidget({super.key, required this.recipe, required this.node});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '매우 쉬움':
        return const Color(0xFF6ECB63);
      case '쉬움':
        return const Color(0xFFFAD643);
      case '보통':
        return const Color(0xFFFF8B27);
      case '어려움':
        return const Color(0xFFE84855);
      case '매우 어려움':
        return const Color(0xFFC22557);
      default:
      // 혹시라도 예외가 있을 경우 대비
        return const Color(0xFFFF8B27);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        node.unfocus();
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
                            scale: isTablet(context) ? 1 : 0.5,
                            child: CachedNetworkImage(
                              imageUrl: recipe.thumbnail,
                              memCacheWidth: 800,
                              memCacheHeight: 600,
                              maxWidthDiskCache: 800,
                              maxHeightDiskCache: 600,
                              fadeOutDuration: Duration(milliseconds: 300),
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 48.w,
                                  height: 48.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Image Error: $error');
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
                            children: [
                              // map으로 생성된 위젯 리스트를 전개
                              ...(recipe.recipe_tags?.map((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList() ?? []),

                              // 여기서부터는 직접 추가할 위젯
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(recipe.difficulty),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "난이도 : " + recipe.difficulty,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
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
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r))),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 좋아요 버튼 부분을 Selector로 감쌉니다.
                  Selector<RecipeStatus, bool>(
                    selector: (_, status) => status.isFavorite(recipe.id),
                    builder: (context, isFavorite, child) {
                      return GestureDetector(
                        onTap: () {
                          context.read<RecipeStatus>().toggleFavorite(recipe.id);
                        },
                        child: Row(
                          children: [
                            Icon(
                              size: 20.w,
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : Color(0xFF8A634C),
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
                      );
                    },
                  ),
                  // 다른 상태는 기존대로 유지합니다.
                  Consumer<FoodStatus>(
                    builder: (context, foodStatus, child) {
                      final matchRate =
                      foodStatus.calculateMatchRate(recipe.ingredients);
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
  }
}
