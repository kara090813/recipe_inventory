import 'package:flutter/foundation.dart';
import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';

class FoodStatus extends ChangeNotifier {
  FoodStatus() {
    loadFoods();
  }

  List<Food> _userFood = [];
  List<Food> get userFood => List.unmodifiable(_userFood);

  Future<void> loadFoods() async {
    try {
      _userFood = HiveService.getFoods();
      notifyListeners();
    } catch (e) {
      print('Error loading foods from Hive: $e');
      notifyListeners();
    }
  }

  Future<void> saveFoods() async {
    try {
      await HiveService.saveFoods(_userFood);
    } catch (e) {
      print('Error saving foods to Hive: $e');
    }
  }

  Future<void> addFoods(List<Food> value) async {
    try {
      final Set<Food> uniqueFoods = Set.from(_userFood);
      uniqueFoods.addAll(value);
      _userFood = uniqueFoods.toList();
      await saveFoods();
      notifyListeners();
    } catch (e) {
      print('Error adding foods: $e');
    }
  }

  Future<void> removeFoods(List<Food> value) async {
    try {
      final Set<Food> foodsToRemove = Set.from(value);
      _userFood.removeWhere((food) => foodsToRemove.contains(food));
      await saveFoods();
      notifyListeners();
    } catch (e) {
      print('Error removing foods: $e');
    }
  }

  Future<void> clearFoods() async {
    try {
      _userFood.clear();
      await saveFoods();
      notifyListeners();
    } catch (e) {
      print('Error clearing foods: $e');
    }
  }

  int calculateMatchRate(List<Ingredient> ingredients) {
    if (ingredients.isEmpty || _userFood.isEmpty) return 0;

    int matchCount = 0;

    for (var ingredient in ingredients) {
      // 사용자의 식재료 중 하나라도 매칭되면 카운트
      if (_userFood.any((userFood) =>
      isIngredientMatched(ingredient.food, userFood.name) ||
          userFood.similarNames.any((similarName) =>
              isIngredientMatched(ingredient.food, similarName))
      )) {
        matchCount++;
      }
    }

    // 매치율 계산 (정수로 반환)
    return ((matchCount / ingredients.length) * 100).round();
  }
}