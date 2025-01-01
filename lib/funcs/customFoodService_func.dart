import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';

class CustomFoodService {
  static const String CUSTOM_FOODS_KEY = 'custom_foods';

  // 커스텀 식재료 저장
  Future<void> saveCustomFoods(List<Food> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = json.encode(
        foods.map((food) => food.toJson()).toList()
    );
    await prefs.setString(CUSTOM_FOODS_KEY, jsonData);
  }

  // 저장된 커스텀 식재료 로드
  Future<List<Food>> loadCustomFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(CUSTOM_FOODS_KEY);
    if (jsonData != null) {
      final List<dynamic> decodedData = json.decode(jsonData);
      return decodedData.map((item) => Food.fromJson(item)).toList();
    }
    return [];
  }

  // 새로운 커스텀 식재료 추가
  Future<void> addCustomFood(Food newFood) async {
    final currentFoods = await loadCustomFoods();
    currentFoods.add(newFood);
    await saveCustomFoods(currentFoods);
  }
}