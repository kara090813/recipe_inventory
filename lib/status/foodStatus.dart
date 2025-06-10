import 'package:flutter/foundation.dart';
import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';

class FoodStatus extends ChangeNotifier {
  List<Food> _userFood = [];

  // 퀘스트 업데이트를 위한 콜백 함수
  Future<void> Function()? _questUpdateCallback;
  Future<void> Function()? _badgeUpdateCallback;

  List<Food> get userFood => List.unmodifiable(_userFood);

  FoodStatus() {
    loadFoods();
  }

  /// 퀘스트 업데이트 콜백 설정
  void setQuestUpdateCallback(Future<void> Function()? callback) {
    _questUpdateCallback = callback;
    print('FoodStatus: Quest update callback set');
  }
  void setBadgeUpdateCallback(Future<void> Function()? callback) {
    _badgeUpdateCallback = callback;
    print('BadgeStatus: Badge update callback set');
  }

  /// 퀘스트 업데이트 트리거
  Future<void> _triggerQuestUpdate() async {
    if (_questUpdateCallback != null) {
      try {
        await _questUpdateCallback!();
        print('FoodStatus: Quest update triggered successfully');
      } catch (e) {
        print('FoodStatus: Error triggering quest update: $e');
      }
    }
  }

  Future<void> loadFoods() async {
    try {
      _userFood = HiveService.getFoods();
      notifyListeners();

      // 🆕 초기화 완료 후 퀘스트 업데이트 트리거 (약간의 지연)
      Future.delayed(Duration(milliseconds: 200), () async {
        await _triggerQuestUpdate();
      });

      print("✅ FoodStatus initialization completed (${_userFood.length} foods)");
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

  // ⭐ 수정된 부분: 식재료 추가 시 퀘스트 업데이트 트리거
  Future<void> addFoods(List<Food> value) async {
    try {
      final Set<Food> uniqueFoods = Set.from(_userFood);
      final int initialCount = uniqueFoods.length;

      uniqueFoods.addAll(value);
      _userFood = uniqueFoods.toList();

      await saveFoods();
      notifyListeners();

      // 실제로 새로운 식재료가 추가된 경우에만 퀘스트 업데이트 트리거
      final int finalCount = _userFood.length;
      if (finalCount > initialCount) {
        print('FoodStatus: ${finalCount - initialCount} new foods added');
        // 🎯 퀘스트 진행도 업데이트 트리거
        await _triggerQuestUpdate();
      }
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