import 'package:flutter/material.dart';

bool isTablet(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final aspectRatio = mediaQuery.size.aspectRatio;
  final width = mediaQuery.size.width;

  // 가로 너비가 600dp 이상이고
  // 가로세로 비율이 0.65 이상인 경우 태블릿으로 판단
  return width >= 600 && aspectRatio >= 0.65;
}