import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/models/data.dart';

import '../status/_status.dart';
import '../widgets/_widgets.dart';

class MyPageComponent extends StatelessWidget {
  const MyPageComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final userStatus = context.watch<UserStatus>();
    final recipeStatus = context.watch<RecipeStatus>();
    final ongoingCooking = userStatus.ongoingCooking;
    final recentHistory = userStatus.cookingHistory.take(3).toList();

    final cookHistoryDays = userStatus.getConsecutiveCookingDays();

    return Column(
      children: [
        HeaderWidget(
          title: '마이페이지',
        ),
        SizedBox(
          height: 10.h,
        ),
        DottedBarWidget(),
        SizedBox(
          width: 8.h,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     InkWell(
        //         onTap: () {
        //           userStatus.reset();
        //           recipeStatus.clearAllFavorites();
        //         },
        //         child: Image.asset('assets/imgs/icons/setting.png')),
        //   ],
        // ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 26.h),
                Column(
                  children: [
                    userStatus.profileImage != null
                        ? Image.network(userStatus.profileImage!)
                        : Image.asset(
                            'assets/imgs/items/baseProfile.png',
                            width: 100.w,
                          ),
                    SizedBox(
                      height: 4.h,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.push('/profileSet');
                      },
                      child: Text(
                        "냉털이 설정하기",
                        style: TextStyle(color: Color(0xFF7D674B)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                        textStyle: TextStyle(fontFamily: 'Mapo', fontSize: 12.sp),
                        side: BorderSide(color: Color(0xFF7D674B)),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                    Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -1,
                          child: FractionallySizedBox(
                            widthFactor: 1.2,
                            child: Container(
                              height: 18.h,
                              color: Color(0xFFFFD8A8),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 0, bottom: 4.h),
                          child: Text(
                            userStatus.nickname,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                            color: Color(0xFF505050),
                            fontSize: 12.sp,
                            fontFamily: 'Mapo'),
                        children: <TextSpan>[
                          TextSpan(text: '요리왕 '),
                          TextSpan(
                              text: '${userStatus.nickname}',
                              style: TextStyle(color: Colors.black)),
                          TextSpan(text: '님!\n'),
                          if (cookHistoryDays != 0) ...[
                            TextSpan(
                              text: '$cookHistoryDays일 연속',
                              style:
                                  TextStyle(color: Color(0xFFDC0000), fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '으로 직접 요리했어요!'),
                          ] else
                            TextSpan(text: '요리를 시작해보세요!'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '진행 중인 요리',
                          style: TextStyle(color: Color(0xFF3B3B3B)),
                        ),
                        InkWell(
                          onTap: () {
                            userStatus.clearOngoingCooking();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 12.w,
                                color: ongoingCooking.length == 0
                                    ? Color(0xFF707070)
                                    : Color(0xFFDB2222),
                              ),
                              Text(
                                '초기화',
                                style: TextStyle(
                                    color: ongoingCooking.length == 0
                                        ? Color(0xFF707070)
                                        : Color(0xFFDB2222),
                                    fontSize: 12.sp),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    ongoingCooking.length == 0
                        ? MypageShrinkWidget(
                            child: Text(
                            '진행 중인 요리가 없어요.\n요리를 시작해보세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC)),
                          ))
                        : InkWell(
                            onTap: () {
                              context.push('/cookingStart', extra: ongoingCooking[0].recipe);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFBB885E)),
                                borderRadius: BorderRadius.circular(8.r),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 6,
                                    offset: Offset(0, 2), // x축은 0, y축은 5만큼 이동
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 8,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/icons/history_icon1.png',
                                              width: 20.w,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(ongoingCooking[0].recipe.title),
                                                Text(
                                                  "요리 시작 일시 : ${ongoingCooking[0].startTime.year}. ${ongoingCooking[0].startTime.month.toString().padLeft(2, '0')}. ${ongoingCooking[0].startTime.day.toString().padLeft(2, '0')}. (${_getKoreanWeekday(ongoingCooking[0].startTime.weekday)}) ${ongoingCooking[0].startTime.hour.toString().padLeft(2, '0')}:${ongoingCooking[0].startTime.minute.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                      color: Color(0xFF707070), fontSize: 12.sp),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(8.r), // 우측 상단
                                            bottomRight: Radius.circular(8.r), // 우측 하단
                                          ),
                                          child: Image.network(ongoingCooking[0].recipe.thumbnail)))
                                ],
                              ),
                            ),
                          )
                  ],
                ),
                SizedBox(
                  height: 24.h,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '레시피 위시리스트',
                          style: TextStyle(color: Color(0xFF3B3B3B)),
                        ),
                        InkWell(
                          onTap: () {
                            context.push('/recipeWishList');
                          },
                          child: Text(
                            '전체보기',
                            style: TextStyle(
                                color: recipeStatus.favoriteRecipes.isEmpty
                                    ? Color(0xFF707070)
                                    : Color(0xFFFF8B27),
                                fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    recipeStatus.favoriteRecipes.isEmpty
                        ? MypageShrinkWidget(
                            child: Column(
                            children: [
                              SizedBox(
                                height: 6.h,
                              ),
                              Image.asset(
                                'assets/imgs/items/cookLoading.png',
                                width: 42.w,
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              Text(
                                '레시피 위시리스트가 없어요.\n마음에 드는 요리를 추가해보세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC)),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  context.push('/', extra: 3);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFFF8B27), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r), // radius 값을 조절할 수
                                    // 있습니다
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h), //
                                  // 패딩을 0으로 설정
                                  minimumSize: Size.zero, // 버튼의 최소 크기를 0으로 설정
                                ),
                                child: InkWell(
                                  onTap: () {
                                    context.read<TabStatus>().setIndex(3);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    // 텍스트 주변에 최소한의 패딩
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '레시피 보러가기',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF8B27),
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(width: 4), // 텍스트와 아이콘 사이의 간격
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12.sp,
                                          color: Color(0xFFFF8B27),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ))
                        : RecipeWishListWidget(recipes: recipeStatus.favoriteRecipes)
                  ],
                ),
                SizedBox(
                  height: 24.h,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '요리 히스토리',
                          style: TextStyle(color: Color(0xFF3B3B3B)),
                        ),
                        InkWell(
                          onTap: () {
                            context.push('/cookHistory');
                          },
                          child: Text(
                            '달력보기',
                            style: TextStyle(color: Color(0xFFFF8B27), fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    recentHistory.isEmpty
                        ? MypageShrinkWidget(
                            child: Column(
                            children: [
                              SizedBox(
                                height: 8.h,
                              ),
                              Text(
                                '요리 히스토리가 없어요.\n요리를 시작해보세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC)),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                            ],
                          ))
                        : Column(
                            children: recentHistory.asMap().entries.map((entry) {
                              final index = entry.key;
                              final history = entry.value;
                              final recipe = history.recipe;
                              final dateTime = history.dateTime;

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context.push('/recipeInfo', extra: recipe);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Color(index == 0
                                            ? 0xFFFFDD9E
                                            : index == 1
                                                ? 0xFFFFD1A9
                                                : 0xFFFFB4A9),
                                        borderRadius: BorderRadius.circular(10.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 0,
                                            blurRadius: 1,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/imgs/icons/history_icon${index + 1}.png',
                                            width: 20.w,
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(child: Text(recipe.title)),
                                          Text(
                                            '${dateTime.year.toString().substring(2)}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}. ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                                color: Color(0xFF707070), fontSize: 10.sp),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index < recentHistory.length - 1) SizedBox(height: 6.h),
                                ],
                              );
                            }).toList(),
                          )
                  ],
                ),
                SizedBox(
                  height: 40.h,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

String _getKoreanWeekday(int weekday) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return weekdays[weekday - 1];
}
