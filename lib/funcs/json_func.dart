import '../models/freezed/food_model.dart';

List<Food> hardCopyFoodList(List<Food> originalList) {
  return originalList.map((food) => food.copyWith()).toList();
}