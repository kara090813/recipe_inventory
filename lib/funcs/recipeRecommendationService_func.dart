import '../models/_models.dart';
import '../status/_status.dart';

class RecipeRecommendationService {
  // 각 요소별 가중치 설정
  static const double INGREDIENT_MATCH_WEIGHT = 0.35; // 식재료 매치도
  static const double HISTORY_WEIGHT = 0.25; // 조리 히스토리 기반
  static const double TIME_WEIGHT = 0.15; // 시간대 적합성
  static const double FAVORITE_WEIGHT = 0.25; // 좋아요 기반

  // 레시피 점수 계산
  double calculateRecipeScore(
      Recipe recipe, UserStatus userStatus, FoodStatus foodStatus, RecipeStatus recipeStatus) {
    double score = 0.0;

    // 1. 식재료 매치도 점수
    int matchRate = foodStatus.calculateMatchRate(recipe.ingredients);
    score += (matchRate / 100) * INGREDIENT_MATCH_WEIGHT;

    // 2. 조리 히스토리 기반 점수
    double historyScore = _calculateHistoryScore(recipe, userStatus);
    score += historyScore * HISTORY_WEIGHT;

    // 3. 시간대 적합성 점수
    double timeScore = _calculateTimeScore(recipe);
    score += timeScore * TIME_WEIGHT;

    // 4. 좋아요 기반 유사도 점수
    double favoriteScore = _calculateFavoriteScore(recipe, recipeStatus);
    score += favoriteScore * FAVORITE_WEIGHT;

    return score;
  }

  // 조리 히스토리 기반 점수 계산
  double _calculateHistoryScore(Recipe recipe, UserStatus userStatus) {
    var history = userStatus.cookingHistory;
    if (history.isEmpty) return 0.0;

    int typeMatch = 0;
    int tagMatch = 0;

    for (var cooked in history) {
      if (cooked.recipe.recipe_type == recipe.recipe_type) {
        typeMatch++;
      }

      for (var tag in recipe.recipe_tags) {
        if (cooked.recipe.recipe_tags.contains(tag)) {
          tagMatch++;
        }
      }
    }

    return (typeMatch / history.length * 0.6) +
        (tagMatch / (history.length * recipe.recipe_tags.length) * 0.4);
  }

  // 시간대 적합성 점수 계산
  double _calculateTimeScore(Recipe recipe) {
    final hour = DateTime.now().hour;

    // 아침 (5-10시), 점심 (11-15시), 저녁 (16-22시), 야식 (23-4시)
    bool isBreakfastTime = hour >= 5 && hour <= 10;
    bool isLunchTime = hour >= 11 && hour <= 15;
    bool isDinnerTime = hour >= 16 && hour <= 22;
    bool isNightTime = hour >= 23 || hour <= 4;

    // 태그 기반 시간대 적합성 판단
    bool isBreakfastMenu = recipe.recipe_tags
        .any((tag) => tag.contains('아침') || tag.contains('간단') || tag.contains('가벼운'));
    bool isLunchMenu = recipe.recipe_tags
        .any((tag) => tag.contains('점심') || tag.contains('식사') || tag.contains('간식'));
    bool isDinnerMenu = recipe.recipe_tags
        .any((tag) => tag.contains('저녁') || tag.contains('야식') || tag.contains('안주'));

    if ((isBreakfastTime && isBreakfastMenu) ||
        (isLunchTime && isLunchMenu) ||
        (isDinnerTime && isDinnerMenu) ||
        (isNightTime && isDinnerMenu)) {
      return 1.0;
    }

    return 0.5; // 시간대가 맞지 않는 경우 기본 점수
  }

  // 좋아요 기반 유사도 점수 계산
  double _calculateFavoriteScore(Recipe recipe, RecipeStatus recipeStatus) {
    var favoriteRecipes = recipeStatus.favoriteRecipes;
    if (favoriteRecipes.isEmpty) return 0.0;

    int typeMatch = 0;
    int tagMatch = 0;

    for (var favorite in favoriteRecipes) {
      if (favorite.recipe_type == recipe.recipe_type) {
        typeMatch++;
      }

      for (var tag in recipe.recipe_tags) {
        if (favorite.recipe_tags.contains(tag)) {
          tagMatch++;
        }
      }
    }

    return (typeMatch / favoriteRecipes.length * 0.6) +
        (tagMatch / (favoriteRecipes.length * recipe.recipe_tags.length) * 0.4);
  }

  List<Recipe> getRecommendedRecipes(UserStatus _userStatus,
      FoodStatus _foodStatus, RecipeStatus _recipeStatus) {
    // 레시피와 점수를 튜플로 만들어 리스트로 변환
    var scoredRecipes = _recipeStatus.recipes
        .map((recipe) => (
              recipe: recipe,
              score: calculateRecipeScore(recipe, _userStatus, _foodStatus, _recipeStatus)
            ))
        .toList();

    // 점수를 기준으로 정렬
    scoredRecipes.sort((a, b) => b.score.compareTo(a.score));

    // 정렬된 레시피만 반환
    return scoredRecipes.map((item) => item.recipe).toList();
  }
}
