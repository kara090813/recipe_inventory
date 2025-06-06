import 'dart:math';
import 'package:recipe_inventory/models/data.dart';
import '../models/_models.dart';

// Levenshtein 거리 계산 함수
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
  // 엄격한 매칭 시도
  if (isStrictMatched(recipeIngredient, userIngredient)) {
    return true;
  }

  // 느슨한 매칭 시도
  if (isLooseMatched(recipeIngredient, userIngredient)) {
    return true;
  }

  return false;
}

// 엄격한 매칭 함수
bool isStrictMatched(String recipeIngredient, String userIngredient) {
  // 전처리
  recipeIngredient = recipeIngredient.trim().toLowerCase();
  userIngredient = userIngredient.trim().toLowerCase();
  // 정확히 일치
  if (recipeIngredient == userIngredient) return true;


  // 짧은 단어는 정확한 매칭만 허용
  if (recipeIngredient.length <= 1 || userIngredient.length <= 1) {
    return recipeIngredient == userIngredient;
  }

  // Levenshtein 거리로 높은 유사도 체크 (90% 이상)
  int distance = levenshteinDistance(recipeIngredient, userIngredient);
  int maxLength = max(recipeIngredient.length, userIngredient.length);
  double similarity = 1 - (distance / maxLength);

  return similarity >= 0.9;  // 엄격한 임계값
}

// 느슨한 매칭 함수
bool isLooseMatched(String recipeIngredient, String userIngredient) {
  recipeIngredient = recipeIngredient.trim().toLowerCase();
  userIngredient = userIngredient.trim().toLowerCase();

  // 기본 재료 이름이 포함되는지 체크
  if (recipeIngredient.contains(userIngredient) ||
      userIngredient.contains(recipeIngredient)) {
    // '물'과 '나물' 같은 경우를 방지하기 위한 길이 체크
    if (userIngredient.length <= 1 || recipeIngredient.length <= 1) {
      return recipeIngredient == userIngredient;
    }
    return true;
  }

  // 길이 차이가 너무 큰 경우는 매칭하지 않음
  if ((recipeIngredient.length - userIngredient.length).abs() > 3) {
    return false;
  }

  // 유사도 체크 (60% 이상)
  int distance = levenshteinDistance(recipeIngredient, userIngredient);
  int maxLength = max(recipeIngredient.length, userIngredient.length);
  double similarity = 1 - (distance / maxLength);

  return similarity >= 0.6;  // 느슨한 임계값
}

// 한글 문자 체크 함수
bool _isKoreanCharacter(String char) {
  return RegExp(r'[가-힣]').hasMatch(char);
}

// 메인 분류 함수
Map<String, List<Food>> classifyIngredients(Recipe recipe, List<Food> userFoods) {
  List<Food> availableIngredients = [];
  List<Food> missingIngredients = [];

  for (var ingredient in recipe.ingredients) {
    bool found = false;

    // 1단계: 전체 식재료 목록에서 100% 일치하는 것이 있는지 먼저 확인
    Food? exactMatch;
    for (var food in FOOD_LIST) {
      if (food.name == ingredient.food ||
          food.similarNames.contains(ingredient.food)) {
        exactMatch = food;
        break;
      }
    }

    if (exactMatch != null) {
      // 100% 일치하는 식재료가 있다면, 사용자가 가지고 있는지 확인
      bool userHasExactMatch = userFoods.any((food) =>
      food.name == exactMatch!.name ||
          food.similarNames.contains(exactMatch.name)
      );

      if (userHasExactMatch) {
        // 사용자가 정확히 일치하는 식재료를 가지고 있음
        availableIngredients.add(Food(
          name: ingredient.food,
          type: exactMatch.type,
          img: exactMatch.img,
        ));
        found = true;
      } else {
        // 정확히 일치하는 식재료가 있지만 사용자가 가지고 있지 않음
        missingIngredients.add(Food(
          name: ingredient.food,
          type: exactMatch.type,
          img: exactMatch.img,
        ));
        found = true;
      }
    }

    // 2단계: 정확히 일치하는 것이 없는 경우에만 유사도 매칭 시도
    if (!found) {
      // 먼저 사용자의 식재료에서 유사도 높은 매칭 시도
      for (var userFood in userFoods) {
        if (isStrictMatched(ingredient.food, userFood.name) ||
            userFood.similarNames.any((name) => isStrictMatched(ingredient.food, name))) {
          availableIngredients.add(Food(
            name: ingredient.food,
            type: userFood.type,
            img: userFood.img,
          ));
          found = true;
          break;
        }
      }

      // 엄격한 매칭 실패시 느슨한 매칭 시도
      if (!found) {
        for (var userFood in userFoods) {
          if (isLooseMatched(ingredient.food, userFood.name) ||
              userFood.similarNames.any((name) => isLooseMatched(ingredient.food, name))) {
            availableIngredients.add(Food(
              name: ingredient.food,
              type: userFood.type,
              img: userFood.img,
            ));
            found = true;
            break;
          }
        }
      }

      // 3단계: 사용자 식재료에서 매칭 실패시 전체 리스트에서 이미지 찾기
      if (!found) {
        bool matchedInList = false;

        // 전체 리스트에서 엄격한 매칭 시도
        for (var food in FOOD_LIST) {
          if (isStrictMatched(ingredient.food, food.name) ||
              food.similarNames.any((name) => isStrictMatched(ingredient.food, name))) {
            missingIngredients.add(Food(
              name: ingredient.food,
              type: food.type,
              img: food.img,
            ));
            matchedInList = true;
            break;
          }
        }

        // 엄격한 매칭 실패시 느슨한 매칭 시도
        if (!matchedInList) {
          for (var food in FOOD_LIST) {
            if (isLooseMatched(ingredient.food, food.name) ||
                food.similarNames.any((name) => isLooseMatched(ingredient.food, name))) {
              missingIngredients.add(Food(
                name: ingredient.food,
                type: food.type,
                img: food.img,
              ));
              matchedInList = true;
              break;
            }
          }

          // 매칭 실패시 기본 이미지로 추가
          if (!matchedInList) {
            missingIngredients.add(Food(
              name: ingredient.food,
              type: "기타",
              img: "assets/imgs/food/unknownFood.png",
            ));
          }
        }
      }
    }
  }

  return {
    'available': availableIngredients,
    'missing': missingIngredients,
  };
}