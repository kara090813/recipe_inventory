import '../models/_models.dart';
import '../services/hive_service.dart';

class CustomFoodService {
  static const String CUSTOM_FOODS_KEY = 'custom_foods';

  // 커스텀 식재료 저장 (Hive 사용)
  Future<void> saveCustomFoods(List<Food> foods) async {
    try {
      // 커스텀 식재료만 필터링해서 저장
      final customFoods = foods.where((food) => food.isCustom).toList();

      // HiveService의 app settings에 저장 (커스텀 식재료는 별도 관리)
      final customFoodsJson = customFoods.map((food) => food.toJson()).toList();
      await HiveService.setStringList('custom_foods_list',
          customFoodsJson.map((json) => json.toString()).toList());

    } catch (e) {
      print('Error saving custom foods: $e');
    }
  }

  // 저장된 커스텀 식재료 로드 (Hive 사용)
  Future<List<Food>> loadCustomFoods() async {
    try {
      // 메인 Food Box에서 커스텀 식재료 필터링해서 반환
      final allFoods = HiveService.getFoods();
      return allFoods.where((food) => food.isCustom).toList();
    } catch (e) {
      print('Error loading custom foods: $e');
      return [];
    }
  }

  // 새로운 커스텀 식재료 추가 (Hive 사용)
  Future<void> addCustomFood(Food newFood) async {
    try {
      // 커스텀 플래그 설정
      final customFood = newFood.copyWith(isCustom: true);

      // 기존 식재료 목록에 추가
      final currentFoods = HiveService.getFoods();
      final updatedFoods = [...currentFoods, customFood];

      await HiveService.saveFoods(updatedFoods);
    } catch (e) {
      print('Error adding custom food: $e');
    }
  }

  // 커스텀 식재료 삭제
  Future<void> removeCustomFood(Food foodToRemove) async {
    try {
      final currentFoods = HiveService.getFoods();
      final filteredFoods = currentFoods.where((food) =>
      !(food.isCustom && food.name == foodToRemove.name)
      ).toList();

      await HiveService.saveFoods(filteredFoods);
    } catch (e) {
      print('Error removing custom food: $e');
    }
  }

  // 모든 커스텀 식재료 삭제
  Future<void> clearAllCustomFoods() async {
    try {
      final currentFoods = HiveService.getFoods();
      final nonCustomFoods = currentFoods.where((food) => !food.isCustom).toList();

      await HiveService.saveFoods(nonCustomFoods);
    } catch (e) {
      print('Error clearing custom foods: $e');
    }
  }
}