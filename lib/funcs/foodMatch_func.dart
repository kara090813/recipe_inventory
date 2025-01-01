import 'dart:math';
import 'package:recipe_inventory/models/data.dart';  // FOOD_LIST를 가져오기 위해 추가
import '../models/_models.dart';

int levenshteinDistance(String a, String b) {
  List<List<int>> d = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));

  for (int i = 0; i <= a.length; i++) d[i][0] = i;
  for (int j = 0; j <= b.length; j++) d[0][j] = j;

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      int cost = a[i - 1] == b[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost
      ].reduce(min);
    }
  }

  return d[a.length][b.length];
}

bool isIngredientMatched(String recipeIngredient, String userIngredient, {double threshold = 0.7}) {
  if (recipeIngredient == userIngredient) return true;
  if (recipeIngredient.contains(userIngredient) || userIngredient.contains(recipeIngredient)) return true;

  int distance = levenshteinDistance(recipeIngredient, userIngredient);
  int maxLength = max(recipeIngredient.length, userIngredient.length);
  double similarity = 1 - (distance / maxLength);

  return similarity >= threshold;
}



Map<String, List<Food>> classifyIngredients(Recipe recipe, List<Food> userFoods) {
  List<Food> availableIngredients = [];
  List<Food> missingIngredients = [];

  for (var ingredient in recipe.ingredients) {
    bool found = false;

    // 사용자의 식재료와 매칭
    for (var userFood in userFoods) {
      if (isIngredientMatched(ingredient.food, userFood.name)) {
        availableIngredients.add(Food(  // orElse에 함수를 제공
            name: ingredient.food,
            type: "unknown",
            img: userFood.img
        ));
        found = true;
        break;
      }
    }

    if (!found) {
      // 전체 식재료 리스트에서 확인
      Food? matchedFood = FOOD_LIST.firstWhere(
            (food) => isIngredientMatched(ingredient.food, food.name),
        orElse: () => Food(  // orElse에 함수를 제공
            name: ingredient.food,
            type: "unknown",
            img: "assets/imgs/food/unknownFood.png"
        ),
      );

      missingIngredients.add(matchedFood);
    }
  }

  return {
    'available': availableIngredients,
    'missing': missingIngredients,
  };
}