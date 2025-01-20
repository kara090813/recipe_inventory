import 'dart:convert';

import 'package:flutter/services.dart';

import '../funcs/onboardingGuideFunc.dart';
import 'foodJson.dart';
import 'freezed/_freezed.dart';

const List<String> FOOD_CATEGORY = ['전체', '채소', '과일', '육류', '수산물', '조미료/향신료', '가공/유제품', '기타'];
const List<String> LABEL_IMAGE = [
  "assets/imgs/food/vegetable.png",
  "assets/imgs/food/fruit.png",
  "assets/imgs/food/meat.png",
  "assets/imgs/food/seafood.png",
  "assets/imgs/food/condiment.png",
  "assets/imgs/food/processed food.png",
  "assets/imgs/food/unknownFood.png"
];
final List<Food> FOOD_LIST = FOOD_JSON.map((e) => Food.fromJson(e)).toList();

final guideContents = [
  GuideContent(
    title: '냉장고 관리하기',
    imagePath: 'assets/imgs/guide/guide1.png',
  ),
  GuideContent(
    title: '직접 식재료 추가하기',
    imagePath: 'assets/imgs/guide/guide2.png',
  ),
  GuideContent(
    title: '영수증으로 식재료 추가하기',
    imagePath: 'assets/imgs/guide/guide3.png',
  ),
  GuideContent(
    title: '레시피 추천받기',
    imagePath: 'assets/imgs/guide/guide4.png',
  ),
  GuideContent(
    title: '조건에 맞는 레시피 찾기',
    imagePath: 'assets/imgs/guide/guide5.png',
  ),
  GuideContent(
    title: '요리 시작하기',
    imagePath: 'assets/imgs/guide/guide6.png',
  ),
  GuideContent(
    title: '나의 요리 여정 기록하기',
    imagePath: 'assets/imgs/guide/guide7.png',
  )
];

Recipe sampleRecipeOne = Recipe(
    title: "볶음우동",
    link: 'test',
    sub_title: "집에서 간단하게 만들 수 있는 맛있는 볶음우동",
    thumbnail: "https://i.ytimg.com/vi/zRg4nxIv3j8/hqdefault.jpg",
    recipe_type: "일식",
    difficulty: "보통",
    ingredients_cnt: 11,
    ingredients: [],
    recipe_method: [],
    recipe_tags: ['test', 'test', 'test', 'test'],
    id: 'adsf');
