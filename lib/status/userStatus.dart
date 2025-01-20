import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/_models.dart';
import 'dart:math';

class CookingHistory {
  final Recipe recipe;
  final DateTime dateTime;

  CookingHistory({required this.recipe, required this.dateTime});

  Map<String, dynamic> toJson() => {
    'recipe': recipe.toJson(),
    'dateTime': dateTime.toIso8601String(),
  };

  factory CookingHistory.fromJson(Map<String, dynamic> json) => CookingHistory(
    recipe: Recipe.fromJson(json['recipe']),
    dateTime: DateTime.parse(json['dateTime']),
  );
}

class OngoingCooking {
  final Recipe recipe;
  final DateTime startTime;

  OngoingCooking({required this.recipe, required this.startTime});

  Map<String, dynamic> toJson() => {
    'recipe': recipe.toJson(),
    'startTime': startTime.toIso8601String(),
  };

  factory OngoingCooking.fromJson(Map<String, dynamic> json) => OngoingCooking(
    recipe: Recipe.fromJson(json['recipe']),
    startTime: DateTime.parse(json['startTime']),
  );
}

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
    final prefs = await SharedPreferences.getInstance();

    final historyJson = prefs.getString('cookingHistory');
    if (historyJson != null) {
      final historyList = json.decode(historyJson) as List;
      _cookingHistory =
          historyList.map((item) => CookingHistory.fromJson(item)).toList();
    }

    final userProfileJson = prefs.getString('userProfile');
    if (userProfileJson != null) {
      _userProfile = UserProfile.fromJson(json.decode(userProfileJson));
      _nickname = _userProfile?.name ?? generateRandomNickname();
      _profileImage = _userProfile?.photoURL;
    } else {
      _nickname = prefs.getString('nickname') ?? generateRandomNickname();
    }

    _isInitialized = prefs.getBool('isInitialized') ?? false;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    _nickname = profile.name;
    _profileImage = profile.photoURL;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', json.encode(profile.toJson()));

    notifyListeners();
  }

  Future<void> clearUserProfile() async {
    _userProfile = null;
    _nickname = generateRandomNickname();
    _profileImage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userProfile');

    notifyListeners();
  }

  Future<void> saveUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cookingHistory',
      json.encode(_cookingHistory.map((h) => h.toJson()).toList()),
    );
    await prefs.setString(
      'ongoingCooking',
      json.encode(_ongoingCooking.map((o) => o.toJson()).toList()),
    );
    await prefs.setString('nickname', _nickname);
    await prefs.setBool('isInitialized', _isInitialized);
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
    _ongoingCooking.removeWhere((cooking) => cooking.recipe == recipe);
    addCookingHistory(recipe);
    saveUserStatus();
    notifyListeners();
  }

  void clearOngoingCooking(){
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