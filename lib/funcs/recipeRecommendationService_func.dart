import 'dart:collection';
import 'package:collection/collection.dart';
import '../models/_models.dart';
import '../status/_status.dart';

class RecipeRecommendationService {
  // 각 요소별 가중치 설정
  static const double INGREDIENT_MATCH_WEIGHT = 0.35; // 식재료 매치도
  static const double HISTORY_WEIGHT = 0.25; // 조리 히스토리 기반
  static const double TIME_WEIGHT = 0.15; // 시간대 적합성
  static const double FAVORITE_WEIGHT = 0.25; // 좋아요 기반

  // 성능 최적화를 위한 캐시 (LRU 캐시로 메모리 관리)
  static final Map<String, List<Recipe>> _cache = {};
  static final Map<String, double> _scoreCache = {};
  static final Map<int, int> _matchRateCache = {};
  static const int _maxCacheSize = 100; // 캐시 최대 크기 제한
  
  // 캐시 키 생성
  String _generateCacheKey(UserStatus userStatus, FoodStatus foodStatus, RecipeStatus recipeStatus) {
    return '${userStatus.hashCode}_${foodStatus.hashCode}_${recipeStatus.recipes.length}';
  }

  // 레시피 점수 계산 (캐시 적용)
  double calculateRecipeScore(
      Recipe recipe, UserStatus userStatus, FoodStatus foodStatus, RecipeStatus recipeStatus) {
    final scoreKey = '${recipe.id}_${userStatus.hashCode}_${foodStatus.hashCode}';
    
    if (_scoreCache.containsKey(scoreKey)) {
      return _scoreCache[scoreKey]!;
    }

    double score = 0.0;

    // 1. 식재료 매치도 점수 (캐시 적용)
    final matchRateKey = recipe.ingredients.hashCode;
    int matchRate;
    if (_matchRateCache.containsKey(matchRateKey)) {
      matchRate = _matchRateCache[matchRateKey]!;
    } else {
      matchRate = foodStatus.calculateMatchRate(recipe.ingredients);
      _matchRateCache[matchRateKey] = matchRate;
    }
    score += (matchRate / 100) * INGREDIENT_MATCH_WEIGHT;

    // 2. 조리 히스토리 기반 점수
    double historyScore = _calculateHistoryScore(recipe, userStatus);
    score += historyScore * HISTORY_WEIGHT;

    // 3. 시간대 적합성 점수 (정적 계산으로 최적화)
    double timeScore = _calculateTimeScoreOptimized(recipe);
    score += timeScore * TIME_WEIGHT;

    // 4. 좋아요 기반 유사도 점수
    double favoriteScore = _calculateFavoriteScore(recipe, recipeStatus);
    score += favoriteScore * FAVORITE_WEIGHT;

    // 점수 캐시에 저장 (크기 제한)
    if (_scoreCache.length >= _maxCacheSize) {
      _scoreCache.remove(_scoreCache.keys.first);
    }
    _scoreCache[scoreKey] = score;
    
    return score;
  }

  // 조리 히스토리 기반 점수 계산 (최적화)
  double _calculateHistoryScore(Recipe recipe, UserStatus userStatus) {
    var history = userStatus.cookingHistory;
    if (history.isEmpty) return 0.0;

    int typeMatch = 0;
    int tagMatch = 0;
    final recipeTagsSet = recipe.recipe_tags.toSet();

    for (var cooked in history) {
      if (cooked.recipe.recipe_type == recipe.recipe_type) {
        typeMatch++;
      }

      // Set 교집합을 이용한 최적화
      final cookedTagsSet = cooked.recipe.recipe_tags.toSet();
      tagMatch += recipeTagsSet.intersection(cookedTagsSet).length;
    }

    return (typeMatch / history.length * 0.6) +
        (tagMatch / (history.length * recipe.recipe_tags.length) * 0.4);
  }

  // 시간대 적합성 점수 계산 (최적화 - 태그 검색 개선)
  double _calculateTimeScoreOptimized(Recipe recipe) {
    final hour = DateTime.now().hour;

    // 아침 (5-10시), 점심 (11-15시), 저녁 (16-22시), 야식 (23-4시)
    bool isBreakfastTime = hour >= 5 && hour <= 10;
    bool isLunchTime = hour >= 11 && hour <= 15;
    bool isDinnerTime = hour >= 16 && hour <= 22;
    bool isNightTime = hour >= 23 || hour <= 4;

    // 태그를 한 번만 순회하여 모든 조건 검사
    bool isBreakfastMenu = false;
    bool isLunchMenu = false;
    bool isDinnerMenu = false;

    for (final tag in recipe.recipe_tags) {
      if (!isBreakfastMenu && (tag.contains('아침') || tag.contains('간단') || tag.contains('가벼운'))) {
        isBreakfastMenu = true;
      }
      if (!isLunchMenu && (tag.contains('점심') || tag.contains('식사') || tag.contains('간식'))) {
        isLunchMenu = true;
      }
      if (!isDinnerMenu && (tag.contains('저녁') || tag.contains('야식') || tag.contains('안주'))) {
        isDinnerMenu = true;
      }
      
      // 모든 조건이 만족되면 더 이상 검사할 필요 없음
      if (isBreakfastMenu && isLunchMenu && isDinnerMenu) break;
    }

    if ((isBreakfastTime && isBreakfastMenu) ||
        (isLunchTime && isLunchMenu) ||
        (isDinnerTime && isDinnerMenu) ||
        (isNightTime && isDinnerMenu)) {
      return 1.0;
    }

    return 0.5; // 시간대가 맞지 않는 경우 기본 점수
  }

  // 좋아요 기반 유사도 점수 계산 (최적화)
  double _calculateFavoriteScore(Recipe recipe, RecipeStatus recipeStatus) {
    var favoriteRecipes = recipeStatus.favoriteRecipes;
    if (favoriteRecipes.isEmpty) return 0.0;

    int typeMatch = 0;
    int tagMatch = 0;
    final recipeTagsSet = recipe.recipe_tags.toSet();

    for (var favorite in favoriteRecipes) {
      if (favorite.recipe_type == recipe.recipe_type) {
        typeMatch++;
      }

      // Set 교집합을 이용한 최적화
      final favoriteTagsSet = favorite.recipe_tags.toSet();
      tagMatch += recipeTagsSet.intersection(favoriteTagsSet).length;
    }

    return (typeMatch / favoriteRecipes.length * 0.6) +
        (tagMatch / (favoriteRecipes.length * recipe.recipe_tags.length) * 0.4);
  }

  List<Recipe> getRecommendedRecipes(UserStatus _userStatus,
      FoodStatus _foodStatus, RecipeStatus _recipeStatus) {
    
    // 캐시 확인
    final cacheKey = _generateCacheKey(_userStatus, _foodStatus, _recipeStatus);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 대용량 데이터 처리를 위한 최적화
    final recipes = _recipeStatus.recipes;
    
    // HeapSort를 사용한 부분 정렬 (상위 N개만 필요한 경우)
    const int maxRecommendations = 50; // 실제 필요한 개수만큼만 정렬
    
    if (recipes.length <= maxRecommendations) {
      // 소량 데이터는 기존 방식 사용
      var scoredRecipes = recipes
          .map((recipe) => (
                recipe: recipe,
                score: calculateRecipeScore(recipe, _userStatus, _foodStatus, _recipeStatus)
              ))
          .toList();

      scoredRecipes.sort((a, b) => b.score.compareTo(a.score));
      final result = scoredRecipes.map((item) => item.recipe).toList();
      
      // 결과 캐시에 저장 (크기 제한)
      if (_cache.length >= _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
      _cache[cacheKey] = result;
      return result;
    } else {
      // 대량 데이터는 부분 정렬 사용
      final priorityQueue = PriorityQueue<({Recipe recipe, double score})>(
        (a, b) => a.score.compareTo(b.score), // 최소 힙
      );

      for (var recipe in recipes) {
        final score = calculateRecipeScore(recipe, _userStatus, _foodStatus, _recipeStatus);
        
        if (priorityQueue.length < maxRecommendations) {
          priorityQueue.add((recipe: recipe, score: score));
        } else if (score > priorityQueue.first.score) {
          priorityQueue.removeFirst();
          priorityQueue.add((recipe: recipe, score: score));
        }
      }

      // 결과를 내림차순으로 정렬
      final result = priorityQueue.toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      
      final recommendedRecipes = result.map((item) => item.recipe).toList();
      
      // 결과 캐시에 저장 (크기 제한)
      if (_cache.length >= _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
      _cache[cacheKey] = recommendedRecipes;
      return recommendedRecipes;
    }
  }

  // 캐시 초기화 메서드 (메모리 관리)
  static void clearCache() {
    _cache.clear();
    _scoreCache.clear();
    _matchRateCache.clear();
  }
  
  // 메모리 압박 시 캐시 크기 줄이기
  static void reduceCacheSize() {
    if (_cache.length > _maxCacheSize / 2) {
      final keysToRemove = _cache.keys.take(_cache.length - _maxCacheSize ~/ 2);
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
    
    if (_scoreCache.length > _maxCacheSize / 2) {
      final keysToRemove = _scoreCache.keys.take(_scoreCache.length - _maxCacheSize ~/ 2);
      for (final key in keysToRemove) {
        _scoreCache.remove(key);
      }
    }
  }
}