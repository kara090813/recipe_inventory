import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class CookingStartScreen extends StatelessWidget {
  final Recipe recipe;

  const CookingStartScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _endCooking(BuildContext context) {
      context.read<UserStatus>().endCooking(recipe);
      Provider.of<TabStatus>(context, listen: false).setIndex(4);
      context.push('/');
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final result = await _showExitConfirmationDialog(context);
        if (result == null) {
          return; // 계속 요리하기를 선택한 경우
        }
        if (result) {
          _endCooking(context);
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color(0xFFFF8B27),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(120),
                    bottomRight: Radius.circular(120),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]),
              child: ScaffoldPaddingWidget(
                child: Column(children: [
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await _showExitConfirmationDialog(context);
                          if (result == null) {
                            return; // 계속 요리하기를 선택한 경우
                          }
                          if (result) {
                            _endCooking(context);
                          } else {
                            context.pop();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.w), // 패딩을 추가하여 터치 영역 확대
                          color: Colors.transparent, // 터치 영역을 위해 투명한 배경 추가
                          child: Image.asset(
                            'assets/imgs/icons/back_arrow.png',
                            width: 26.w,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '요리 시작',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20.sp),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final result = await _showExitConfirmationDialog(context);
                          if (result == null) {
                            return; // 계속 요리하기를 선택한 경우
                          }
                          if (result) {
                            _endCooking(context);
                          } else {
                            context.pop();
                          }
                        },
                        child: Text(
                          '요리 종료',
                          style: TextStyle(color: Colors.black, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  DottedBarWidget(
                    lineColor: Colors.white,
                  ),
                  SizedBox(height: 14.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/imgs/items/thumbnailBack.png'),
                      Positioned(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            recipe.thumbnail,
                            fit: BoxFit.cover,
                            width: 300.w,
                            height: 170.h,
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
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 6.h, bottom: 10.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: -1,
                                    child: Container(
                                      height: 14,
                                      color: Color(0xFFFFD8A8),
                                    ),
                                  ),
                                  Text(
                                    recipe.title,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 12.w,
                              ),
                              Icon(
                                Icons.favorite,
                                color: Color(0xFFEC3030),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                ]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Text(
                            '재료',
                            style: TextStyle(color: Color(0xFF707070)),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          DottedBarWidget(
                            paddingSize: 80.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // TwoColumnTextWidget(
                      //   columns: buildIngredientColumns(recipe.ingredients),
                      //   bkgColor: Color(0xFFEAE5DF),
                      // ),
                      IngredientTableWidget(ingredients: recipe.ingredients),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            '요리과정',
                            style: TextStyle(color: Color(0xFF707070)),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          DottedBarWidget(
                            paddingSize: 110.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      NumberListWidget(
                        items: recipe.recipe_method,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16.h,
              ),
              Image.asset(
                'assets/imgs/items/cookExit.png', // 시계 아이콘 이미지
                width: 60.w,
                height: 60.w,
              ),
              SizedBox(height: 20.h),
              Text(
                '요리를 종료할까요?',
                style: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.bold, color: Color(0xFF7D674B)),
              ),
              Text(
                '진행 중인 요리를 완료하셨나요?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF969696),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE8E8E8),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  '아니오, 중단합니다.',
                  style: TextStyle(
                    color: Color(0xFF7D674B),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF8B27),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  '예, 완료했습니다!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  '계속 요리하기',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFFA7B1C),
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFA7B1C),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
