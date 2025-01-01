import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../funcs/_funcs.dart';
import '../models/_models.dart';

class FoodStatus extends ChangeNotifier {
  FoodStatus() {
    loadFoods();
  }

  List<Food> _userFood = [];
  List<Food> get userFood => List.unmodifiable(_userFood);

  Future<void> loadFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? foodListString = prefs.getString('foodList');
      if (foodListString != null) {
        final List<dynamic> jsonList = json.decode(foodListString) as List<dynamic>;
        _userFood = jsonList.map((jsonItem) => Food.fromJson(jsonItem as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading foods: $e');
    }
  }

  Future<void> saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonList = json.encode(_userFood.map((food) => food.toJson()).toList());
      await prefs.setString('foodList', jsonList);
    } catch (e) {
      print('Error saving foods: $e');
    }
  }

  Future<void> addFoods(List<Food> value) async {
    final Set<Food> uniqueFoods = Set.from(_userFood);
    uniqueFoods.addAll(value);
    _userFood = uniqueFoods.toList();
    await saveFoods();
    notifyListeners();
  }

  Future<void> removeFoods(List<Food> value) async {
    final Set<Food> foodsToRemove = Set.from(value);
    _userFood.removeWhere((food) => foodsToRemove.contains(food));
    await saveFoods();
    notifyListeners();
  }

  Future<void> clearFoods() async {
    _userFood.clear();
    await saveFoods();
    notifyListeners();
  }

  int calculateMatchRate(List<Ingredient> ingredients) {
    if (ingredients.isEmpty || _userFood.isEmpty) return 0;

    int matchCount = 0;

    for (var ingredient in ingredients) {
      // 각 레시피 재료에 대해 사용자의 식재료와 매칭 여부 확인
      for (var userFood in _userFood) {
        // 1. 직접적인 이름 매칭
        if (isIngredientMatched(ingredient.food, userFood.name)) {
          matchCount++;
          break;
        }

        // 2. similarNames와의 매칭 확인
        bool matchedWithSimilarName = false;
        for (var similarName in userFood.similarNames) {
          if (isIngredientMatched(ingredient.food, similarName)) {
            matchCount++;
            matchedWithSimilarName = true;
            break;
          }
        }
        if (matchedWithSimilarName) break;
      }
    }

    // 매치율 계산 (정수로 반환)
    return ((matchCount / ingredients.length) * 100).round();
  }
}