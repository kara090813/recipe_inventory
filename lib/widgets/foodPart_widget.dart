import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../funcs/isTablet_func.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '_widgets.dart';

class FoodPartWidget extends StatelessWidget {
  const FoodPartWidget({
    Key? key,
    required this.foods,
    required this.partCount,
    required this.partColor,
    required this.islabel,
    this.checkColor = Colors.green,
    this.selectionMode = false,
  }) : super(key: key);

  final List<Food> foods;
  final int partCount;
  final Color partColor;
  final bool selectionMode;
  final Color checkColor;
  final bool islabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double availableWidth = constraints.maxWidth;
        final double baseImageSize = 40.w;
        final double itemWidth = (availableWidth - 8.w) / partCount;
        final double imageSize = (itemWidth * 0.8).clamp(baseImageSize * 0.8, baseImageSize * 1.2);
        final double partPadding = islabel ? 20.h : 12.h;

        return Column(
          children: [
            SizedBox(height: 4.h,),
            Stack(
              children: [
                if (!isTablet(context))
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06), // 그림자 색상과 투명도
                          blurRadius: 10.0, // 그림자 흐림 정도
                          offset: Offset(0, 12), // 그림자 위치 (x, y)
                          spreadRadius: 0, // 그림자 확산 정도
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: partPadding,),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(partColor, BlendMode.srcATop),
                          child: Image.asset('assets/imgs/background/part.png'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var food in foods)
                        GestureDetector(
                          onTap: selectionMode
                              ? () {
                                  Provider.of<SelectedFoodProvider>(context, listen: false)
                                      .toggleFood(food);
                                }
                              : null,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: itemWidth,
                                child: Center(
                                  child: SizedBox(
                                    width: imageSize,
                                    height: imageSize,
                                    child: Image.asset(
                                      food.img,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              if (selectionMode)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Consumer<SelectedFoodProvider>(
                                    builder: (context, provider, child) {
                                      return provider.isSelected(food)
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: checkColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white, // 체크 표시 색상을 흰색으로 설정
                                                size: 16.w,
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      for (int i = 0; i < partCount - foods.length; i++) SizedBox(width: itemWidth),
                    ],
                  ),
                ),
                SizedBox(height: 54.h,)
              ],
            ),
            if (foods.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var food in foods)
                      GestureDetector(
                        onTap: selectionMode
                            ? () {
                          Provider.of<SelectedFoodProvider>(context, listen: false)
                              .toggleFood(food);
                        }
                            : null,
                        child: !selectionMode
                            ? SizedBox(
                          width: itemWidth,
                          child: AutoSizeText(
                            food.name,
                            style: TextStyle(fontSize: 12.sp, color: Color(0xFF3E3E3E)),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 6,
                            stepGranularity: 0.5,
                          ),
                        )
                            : Consumer<SelectedFoodProvider>(
                          builder: (context, provider, child) {
                            final isSelected = provider.isSelected(food);
                            return SizedBox(
                              width: itemWidth,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isSelected)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          // 하이라이트 바
                                          Container(
                                            width: 5.w,
                                            height: 18.h,
                                            decoration: BoxDecoration(
                                              color: checkColor.withOpacity(0.8),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(2.r),
                                                bottomLeft: Radius.circular(2.r),
                                              ),
                                            ),
                                          ),
                                          // 텍스트
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                                            child: Center(
                                              child: AutoSizeText(
                                                food.name,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: checkColor,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                minFontSize: 6,
                                                stepGranularity: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    AutoSizeText(
                                      food.name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      minFontSize: 6,
                                      stepGranularity: 0.5,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    for (int i = 0; i < partCount - foods.length; i++) SizedBox(width: itemWidth),
                  ],
                ),
              ),
              SizedBox(height: 10.h)
            ]
          ],
        );
      },
    );
  }
}
