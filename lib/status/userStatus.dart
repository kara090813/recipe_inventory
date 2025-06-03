import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';
import 'dart:math';

class UserStatus extends ChangeNotifier {
  List<CookingHistory> _cookingHistory = [];
  List<OngoingCooking> _ongoingCooking = [];
  String? _profileImage;
  String _nickname = "사용자";
  bool _isInitialized = false;
  UserProfile? _userProfile;

  List<CookingHistory> get cookingHistory => List.unmodifiable(_cookingHistory);
  List<OngoingCooking> get ongoingCooking => List.unmodifiable(_ongoingCooking);
  String get nickname => _nickname;
  bool get isInitialized => _isInitialized;
  String? get profileImage => _profileImage;
  UserProfile? get userProfile => _userProfile;

  UserStatus() {
    loadUserStatus();
  }

  Future<void> loadUserStatus() async {
    try {
      // Hive에서 데이터 로드
      _cookingHistory = HiveService.getCookingHistory();
      _ongoingCooking = HiveService.getOngoingCooking();
      _userProfile = HiveService.getUserProfile();

      if (_userProfile != null) {
        _nickname = _userProfile?.name ?? generateRandomNickname();
        _profileImage = _userProfile?.photoURL;
      } else {
        // SharedPreferences에서 기존 닉네임 가져오기 (호환성을 위해)
        final prefs = await SharedPreferences.getInstance();
        _nickname = prefs.getString('nickname') ?? generateRandomNickname();
      }

      // 초기화 상태는 여전히 SharedPreferences 사용 (가벼운 설정값)
      final prefs = await SharedPreferences.getInstance();
      _isInitialized = prefs.getBool('isInitialized') ?? false;

      notifyListeners();
    } catch (e) {
      print('Error loading user status: $e');
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      _userProfile = profile;
      _nickname = profile.name;
      _profileImage = profile.photoURL;

      await HiveService.saveUserProfile(profile);
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<void> clearUserProfile() async {
    try {
      _userProfile = null;
      _nickname = generateRandomNickname();
      _profileImage = null;

      await HiveService.clearUserProfile();
      notifyListeners();
    } catch (e) {
      print('Error clearing user profile: $e');
    }
  }

  Future<void> saveUserStatus() async {
    try {
      await HiveService.saveCookingHistory(_cookingHistory);
      await HiveService.saveOngoingCooking(_ongoingCooking);

      // 닉네임과 초기화 상태는 SharedPreferences에 저장 (호환성)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', _nickname);
      await prefs.setBool('isInitialized', _isInitialized);
    } catch (e) {
      print('Error saving user status: $e');
    }
  }

  String generateRandomNickname() {
    final adjectives = ['행복한', '즐거운', '신나는', '멋진', '귀여운', '열정적인', '창의적인'];
    final nouns = ['요리사', '셰프', '주방장', '맛집탐험가', '미식가', '푸드스타일리스트'];

    final random = Random();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];

    return '$adjective $noun';
  }

  void addCookingHistory(Recipe recipe) {
    _cookingHistory.insert(0, CookingHistory(recipe: recipe, dateTime: DateTime.now()));
    saveUserStatus();
    notifyListeners();
  }

  void startCooking(Recipe recipe) {
    _ongoingCooking.insert(0, OngoingCooking(recipe: recipe, startTime: DateTime.now()));
    if (_ongoingCooking.length > 2) {
      _ongoingCooking.removeLast();
    }
    saveUserStatus();
    notifyListeners();
  }

  void endCooking(Recipe recipe) {
    _ongoingCooking.removeWhere((cooking) => cooking.recipe.id == recipe.id);
    addCookingHistory(recipe);
    saveUserStatus();
    notifyListeners();
  }

  void clearOngoingCooking() {
    _ongoingCooking.clear();
    saveUserStatus();
    notifyListeners();
  }

  void setNickname(String newNickname) {
    _nickname = newNickname;
    saveUserStatus();
    notifyListeners();
  }

  int getConsecutiveCookingDays() {
    if (_cookingHistory.isEmpty) return 0;

    // 날짜별로 요리 기록을 그룹화
    Map<String, bool> cookingDays = {};
    for (var history in _cookingHistory) {
      String dateKey = '${history.dateTime.year}-${history.dateTime.month}-${history.dateTime.day}';
      cookingDays[dateKey] = true;
    }

    // 오늘 날짜부터 역순으로 연속된 날짜 확인
    int consecutiveDays = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      String dateKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      if (!cookingDays.containsKey(dateKey)) break;

      consecutiveDays++;
      currentDate = currentDate.subtract(Duration(days: 1));
    }

    return consecutiveDays;
  }

  void reset() {
    _cookingHistory.clear();
    _ongoingCooking.clear();
    _isInitialized = false;
    _userProfile = null;
    _profileImage = null;
    _nickname = generateRandomNickname();
    saveUserStatus();
    notifyListeners();
  }
}