import 'package:hive_flutter/hive_flutter.dart';
import '../models/_models.dart';

class HiveService {
  static const String RECIPE_BOX = 'recipes';
  static const String FOOD_BOX = 'foods';
  static const String COOKING_HISTORY_BOX = 'cooking_history';
  static const String ONGOING_COOKING_BOX = 'ongoing_cooking';
  static const String USER_PROFILE_BOX = 'user_profile';
  static const String FAVORITE_RECIPES_BOX = 'favorite_recipes';
  static const String APP_SETTINGS_BOX = 'app_settings';
  static const String QUEST_BOX = 'quests';

  static late Box<Recipe> _recipeBox;
  static late Box<Food> _foodBox;
  static late Box<CookingHistory> _cookingHistoryBox;
  static late Box<OngoingCooking> _ongoingCookingBox;
  static late Box<UserProfile> _userProfileBox;
  static late Box<String> _favoriteRecipesBox;
  static late Box _appSettingsBox;
  static late Box<Quest> _questBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Type Adapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IngredientAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FoodAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CookingHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(OngoingCookingAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(LoginProviderAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(QuestAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(QuestConditionAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(QuestTypeAdapter());
    }

    // Box 열기
    _recipeBox = await Hive.openBox<Recipe>(RECIPE_BOX);
    _foodBox = await Hive.openBox<Food>(FOOD_BOX);
    _cookingHistoryBox =
        await Hive.openBox<CookingHistory>(COOKING_HISTORY_BOX);
    _ongoingCookingBox =
        await Hive.openBox<OngoingCooking>(ONGOING_COOKING_BOX);
    _userProfileBox = await Hive.openBox<UserProfile>(USER_PROFILE_BOX);
    _favoriteRecipesBox = await Hive.openBox<String>(FAVORITE_RECIPES_BOX);
    _appSettingsBox = await Hive.openBox(APP_SETTINGS_BOX);
    _questBox = await Hive.openBox<Quest>(QUEST_BOX);
  }

  // Recipe 관련 메서드
  static Future<void> saveRecipes(List<Recipe> recipes) async {
    await _recipeBox.clear();
    for (int i = 0; i < recipes.length; i++) {
      await _recipeBox.put(recipes[i].id, recipes[i]);
    }
  }

  static List<Recipe> getRecipes() {
    return _recipeBox.values.toList();
  }

  static Recipe? getRecipe(String id) {
    return _recipeBox.get(id);
  }

  // Food 관련 메서드
  static Future<void> saveFoods(List<Food> foods) async {
    await _foodBox.clear();
    for (int i = 0; i < foods.length; i++) {
      await _foodBox.put(i, foods[i]);
    }
  }

  static List<Food> getFoods() {
    return _foodBox.values.toList();
  }

  static Future<void> addFoods(List<Food> foods) async {
    final existingFoods = getFoods();
    final Set<Food> uniqueFoods = Set.from(existingFoods);
    uniqueFoods.addAll(foods);
    await saveFoods(uniqueFoods.toList());
  }

  static Future<void> removeFoods(List<Food> foods) async {
    final existingFoods = getFoods();
    final Set<Food> foodsToRemove = Set.from(foods);
    final filteredFoods =
        existingFoods.where((food) => !foodsToRemove.contains(food)).toList();
    await saveFoods(filteredFoods);
  }

  static Future<void> clearFoods() async {
    await _foodBox.clear();
  }

  // CookingHistory 관련 메서드
  static Future<void> saveCookingHistory(List<CookingHistory> history) async {
    await _cookingHistoryBox.clear();
    for (int i = 0; i < history.length; i++) {
      await _cookingHistoryBox.put(i, history[i]);
    }
  }

  static List<CookingHistory> getCookingHistory() {
    return _cookingHistoryBox.values.toList();
  }

  static Future<void> addCookingHistory(CookingHistory history) async {
    await _cookingHistoryBox.add(history);
  }

  // OngoingCooking 관련 메서드
  static Future<void> saveOngoingCooking(List<OngoingCooking> ongoing) async {
    await _ongoingCookingBox.clear();
    for (int i = 0; i < ongoing.length; i++) {
      await _ongoingCookingBox.put(i, ongoing[i]);
    }
  }

  static List<OngoingCooking> getOngoingCooking() {
    return _ongoingCookingBox.values.toList();
  }

  static Future<void> clearOngoingCooking() async {
    await _ongoingCookingBox.clear();
  }

  // UserProfile 관련 메서드
  static Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put('profile', profile);
  }

  static UserProfile? getUserProfile() {
    return _userProfileBox.get('profile');
  }

  static Future<void> clearUserProfile() async {
    await _userProfileBox.clear();
  }

  // FavoriteRecipes 관련 메서드
  static Future<void> saveFavoriteRecipes(List<String> recipeIds) async {
    await _favoriteRecipesBox.clear();
    for (int i = 0; i < recipeIds.length; i++) {
      await _favoriteRecipesBox.put(i, recipeIds[i]);
    }
  }

  static List<String> getFavoriteRecipes() {
    return _favoriteRecipesBox.values.toList();
  }

  static Future<void> addFavoriteRecipe(String recipeId) async {
    final favorites = getFavoriteRecipes();
    if (!favorites.contains(recipeId)) {
      await _favoriteRecipesBox.add(recipeId);
    }
  }

  static Future<void> removeFavoriteRecipe(String recipeId) async {
    final favorites = getFavoriteRecipes();
    final index = favorites.indexOf(recipeId);
    if (index >= 0) {
      await _favoriteRecipesBox.deleteAt(index);
    }
  }

  static Future<void> clearFavoriteRecipes() async {
    await _favoriteRecipesBox.clear();
  }

  static Future<void> saveQuests(List<Quest> quests) async {
    await _questBox.clear();
    for (int i = 0; i < quests.length; i++) {
      await _questBox.put(quests[i].id, quests[i]);
    }
  }

  static List<Quest> getQuests() {
    return _questBox.values.toList();
  }

  static Quest? getQuest(String questId) {
    return _questBox.get(questId);
  }

  /// 개별 퀘스트 업데이트
  static Future<void> updateQuestProgress(String questId, int progress,
      bool isCompleted, bool isRewardReceived) async {
    final quest = _questBox.get(questId);
    if (quest != null) {
      final updatedQuest = quest.copyWith(
        currentProgress: progress,
        isCompleted: isCompleted,
        isRewardReceived: isRewardReceived,
      );
      await _questBox.put(questId, updatedQuest);
    }
  }

  static Future<void> clearQuests() async {
    await _questBox.clear();
  }

  // 퀘스트 체크 시간 관련 메서드 (기존 설정 메서드 활용)
  static Future<void> setLastQuestCheckTime(int timestamp) async {
    await _appSettingsBox.put('last_quest_check_time', timestamp);
  }

  static int? getLastQuestCheckTime() {
    return _appSettingsBox.get('last_quest_check_time');
  }

  // App Settings 관련 메서드 (기존 SharedPreferences 기타 설정들)
  static Future<void> setString(String key, String value) async {
    await _appSettingsBox.put(key, value);
  }

  static String? getString(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _appSettingsBox.put(key, value);
  }

  static bool? getBool(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _appSettingsBox.put(key, value);
  }

  static int? getInt(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _appSettingsBox.put(key, value);
  }

  static List<String>? getStringList(String key) {
    final value = _appSettingsBox.get(key);
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  static Future<void> remove(String key) async {
    await _appSettingsBox.delete(key);
  }

  // 전체 데이터 클리어
  static Future<void> clearAll() async {
    await _recipeBox.clear();
    await _foodBox.clear();
    await _cookingHistoryBox.clear();
    await _ongoingCookingBox.clear();
    await _userProfileBox.clear();
    await _favoriteRecipesBox.clear();
    await _appSettingsBox.clear();
    await _questBox.clear();
  }

  // 마이그레이션용 메서드
  static Future<void> migrateFromSharedPreferences() async {
    // 이 메서드는 기존 SharedPreferences 데이터를 Hive로 마이그레이션할 때 사용
    // 필요시 구현
  }
}
