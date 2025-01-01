import 'dart:convert';

import 'package:flutter/services.dart';

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



Recipe sampleRecipeOne = Recipe(

    title: "볶음우동",
    sub_title: "집에서 간단하게 만들 수 있는 맛있는 볶음우동",
    thumbnail: "https://i.ytimg.com/vi/zRg4nxIv3j8/hqdefault.jpg",
    recipe_type: "일식",
    difficulty: "보통",
    ingredients_cnt: 11,
    ingredients: [],
    recipe_method: [],
    recipe_tags: ['test','test','test','test'], id: 'adsf');