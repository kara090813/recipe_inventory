import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';
import 'dart:math';
import 'dart:io';
import '../data/badgeData.dart';

class UserStatus extends ChangeNotifier {
  List<CookingHistory> _cookingHistory = [];
  List<OngoingCooking> _ongoingCooking = [];
  String? _profileImage;
  String _nickname = "사용자";
  bool _isInitialized = false;
  UserProfile? _userProfile;

  // 퀘스트 업데이트를 위한 콜백 함수
  Future<void> Function()? _questUpdateCallback;
  Future<void> Function()? _badgeUpdateCallback;

  List<CookingHistory> get cookingHistory => List.unmodifiable(_cookingHistory);
  List<OngoingCooking> get ongoingCooking => List.unmodifiable(_ongoingCooking);
  String get nickname => _nickname;
  bool get isInitialized => _isInitialized;
  String? get profileImage => _profileImage;
  UserProfile? get userProfile => _userProfile;

  // 포인트, 경험치, 레벨 관련 getter
  int get currentPoints => _userProfile?.points ?? 0;
  int get currentLevel => _userProfile?.level ?? 1;
  int get currentExperience => _userProfile?.experience ?? 0;
  
  // 커스텀 레시피 생성권 관련 getter
  int get customRecipeTickets => _userProfile?.customRecipeTickets ?? 0;

  UserStatus() {
    loadUserStatus();
  }

  void setBadgeUpdateCallback(Future<void> Function()? callback) {
    _badgeUpdateCallback = callback;
    print('BadgeStatus: Badge update callback set');
  }
  /// 퀘스트 업데이트 콜백 설정
  void setQuestUpdateCallback(Future<void> Function()? callback) {
    _questUpdateCallback = callback;
    print('UserStatus: Quest update callback set');
  }

  /// 퀘스트 업데이트 트리거
  Future<void> _triggerQuestUpdate() async {
    if (_questUpdateCallback != null) {
      try {
        await _questUpdateCallback!();
        print('UserStatus: Quest update triggered successfully');
      } catch (e) {
        print('UserStatus: Error triggering quest update: $e');
      }
    }
  }

  /// 뱃지 업데이트 트리거
  Future<void> _triggerBadgeUpdate() async {
    if (_badgeUpdateCallback != null) {
      try {
        await _badgeUpdateCallback!();
        print('UserStatus: Badge update triggered successfully');
      } catch (e) {
        print('UserStatus: Error triggering badge update: $e');
      }
    }
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

      // 🆕 초기화 완료 후 퀘스트 업데이트 트리거 (약간의 지연)
      Future.delayed(Duration(milliseconds: 200), () async {
        await _triggerQuestUpdate();
      });

      print("✅ UserStatus initialization completed");
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

  /// 뱃지 프로필 설정/해제
  Future<void> toggleBadgeProfile(String? badgeId) async {
    try {
      if (_userProfile == null) {
        print('UserProfile이 존재하지 않습니다.');
        return;
      }

      // 뱃지 프로필 해제
      if (badgeId == null) {
        final updatedProfile = _userProfile!.copyWith(
          isUsingBadgeProfile: false,
          mainBadgeId: null,
        );
        await updateUserProfile(updatedProfile);
        print('뱃지 프로필이 해제되었습니다.');
        return;
      }

      // 뱃지 존재 확인
      final badge = getBadgeById(badgeId);
      if (badge == null) {
        print('해당 뱃지를 찾을 수 없습니다: $badgeId');
        return;
      }

      // 뱃지 이미지 파일 존재 확인
      final badgeImagePath = badge.imagePath;
      final file = File(badgeImagePath);
      if (!await file.exists()) {
        print('뱃지 이미지 파일이 존재하지 않습니다: $badgeImagePath');
        // 에셋 파일은 File.exists()로 확인할 수 없으므로 이 체크는 생략
      }

      // 뱃지 프로필 설정
      final updatedProfile = _userProfile!.copyWith(
        isUsingBadgeProfile: true,
        mainBadgeId: badgeId,
      );
      await updateUserProfile(updatedProfile);
      print('뱃지 프로필이 설정되었습니다: ${badge.name}');
    } catch (e) {
      print('뱃지 프로필 토글 실패: $e');
    }
  }

  /// 메인 뱃지 변경에 따른 프로필 업데이트 (BadgeStatus에서 호출)
  Future<void> updateMainBadgeProfile(String? badgeId) async {
    try {
      if (_userProfile == null) {
        // 프로필이 없으면 기본 프로필 생성
        _userProfile = UserProfile(
          uid: 'local_user',
          email: 'local@example.com',
          name: _nickname,
          provider: LoginProvider.none,
        );
      }

      final updatedProfile = _userProfile!.copyWith(
        isUsingBadgeProfile: badgeId != null,
        mainBadgeId: badgeId,
      );
      
      await updateUserProfile(updatedProfile);
      print('메인 뱃지 변경에 따른 프로필 업데이트 완료: $badgeId');
    } catch (e) {
      print('메인 뱃지 프로필 업데이트 실패: $e');
    }
  }

  /// 현재 표시할 프로필 이미지 경로 가져오기
  String getDisplayProfileImage() {
    if (_userProfile == null) {
      return 'assets/imgs/items/baseProfile.png'; // 기본 프로필 이미지
    }

    // 뱃지 프로필 사용 중인 경우
    if (_userProfile!.isUsingBadgeProfile && _userProfile!.mainBadgeId != null) {
      final badge = getBadgeById(_userProfile!.mainBadgeId!);
      if (badge != null) {
        return badge.imagePath;
      }
    }

    // 기본 프로필 이미지
    return _userProfile!.photoURL ?? 'assets/imgs/items/baseProfile.png';
  }

  /// 현재 프로필 타입 가져오기
  String getProfileType() {
    if (_userProfile == null) {
      return '베이스';
    }

    if (_userProfile!.isUsingBadgeProfile && _userProfile!.mainBadgeId != null) {
      final badge = getBadgeById(_userProfile!.mainBadgeId!);
      if (badge != null) {
        return '뱃지: ${badge.name}';
      }
    }

    return '베이스';
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

  // =============== 포인트 관련 메서드 ===============

  /// 포인트 추가
  Future<void> addPoints(int points) async {
    if (points <= 0) return;

    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      final updatedProfile = currentProfile.copyWith(
        points: currentProfile.points + points,
      );

      await updateUserProfile(updatedProfile);
      print('포인트 추가: +$points (총 ${updatedProfile.points}P)');
    } catch (e) {
      print('포인트 추가 실패: $e');
    }
  }

  /// 포인트 차감 (0 이하로 내려가지 않음)
  Future<bool> subtractPoints(int points) async {
    if (points <= 0) return false;

    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      if (currentProfile.points < points) {
        print('포인트 부족: 현재 ${currentProfile.points}P, 필요 ${points}P');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        points: currentProfile.points - points,
      );

      await updateUserProfile(updatedProfile);
      print('포인트 차감: -$points (남은 ${updatedProfile.points}P)');
      return true;
    } catch (e) {
      print('포인트 차감 실패: $e');
      return false;
    }
  }

  // =============== 커스텀 레시피 생성권 관련 메서드 ===============

  /// 커스텀 레시피 생성권 추가
  Future<void> addCustomRecipeTickets(int tickets) async {
    if (tickets <= 0) return;

    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      final updatedProfile = currentProfile.copyWith(
        customRecipeTickets: currentProfile.customRecipeTickets + tickets,
      );

      await updateUserProfile(updatedProfile);
      print('커스텀 레시피 생성권 추가: +$tickets (총 ${updatedProfile.customRecipeTickets}개)');
    } catch (e) {
      print('커스텀 레시피 생성권 추가 실패: $e');
    }
  }

  /// 커스텀 레시피 생성권 사용 (1개 차감)
  Future<bool> useCustomRecipeTicket() async {
    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      if (currentProfile.customRecipeTickets <= 0) {
        print('커스텀 레시피 생성권 부족: 현재 ${currentProfile.customRecipeTickets}개');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        customRecipeTickets: currentProfile.customRecipeTickets - 1,
      );

      await updateUserProfile(updatedProfile);
      print('커스텀 레시피 생성권 사용: -1 (남은 ${updatedProfile.customRecipeTickets}개)');
      return true;
    } catch (e) {
      print('커스텀 레시피 생성권 사용 실패: $e');
      return false;
    }
  }

  /// 커스텀 레시피 생성권 구매 (포인트로)
  Future<bool> purchaseCustomRecipeTickets(int tickets, int totalCost) async {
    if (tickets <= 0 || totalCost <= 0) return false;

    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      if (currentProfile.points < totalCost) {
        print('포인트 부족: 현재 ${currentProfile.points}P, 필요 ${totalCost}P');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        points: currentProfile.points - totalCost,
        customRecipeTickets: currentProfile.customRecipeTickets + tickets,
      );

      await updateUserProfile(updatedProfile);
      print('커스텀 레시피 생성권 구매 완료: +${tickets}개, -${totalCost}P');
      print('남은 포인트: ${updatedProfile.points}P, 총 생성권: ${updatedProfile.customRecipeTickets}개');
      return true;
    } catch (e) {
      print('커스텀 레시피 생성권 구매 실패: $e');
      return false;
    }
  }

  // =============== 경험치 및 레벨 관련 메서드 ===============

  /// 난이도별 경험치 반환
  int getDifficultyExperience(String difficulty) {
    switch (difficulty) {
      case '매우쉬움':
      case '매우 쉬움':
        return 10;
      case '쉬움':
        return 10;
      case '보통':
        return 20;
      case '어려움':
        return 20;
      case '매우어려움':
      case '매우 어려움':
        return 30;
      default:
        return 20; // 기본값
    }
  }

  /// 특정 레벨에 필요한 총 경험치 계산
  /// 레벨 1: 0XP, 레벨 2: 100XP, 레벨 3: 210XP, 레벨 4: 330XP...
  /// 공식: 레벨 n에 필요한 총 경험치 = (n-1) * 100 + 10 * (n-2) * (n-1) / 2
  int calculateRequiredExpForLevel(int level) {
    if (level <= 1) return 0;

    final n = level;
    return (n - 1) * 100 + (10 * (n - 2) * (n - 1) ~/ 2);
  }

  /// 현재 레벨에서의 진행도 계산 (0.0 ~ 1.0)
  double calculateCurrentLevelProgress() {
    final currentLevel = this.currentLevel;
    final currentExp = this.currentExperience;

    if (currentLevel <= 1) {
      // 레벨 1에서 레벨 2로 가는 진행도
      return (currentExp / 100.0).clamp(0.0, 1.0);
    }

    final currentLevelRequiredExp = calculateRequiredExpForLevel(currentLevel);
    final nextLevelRequiredExp = calculateRequiredExpForLevel(currentLevel + 1);
    final levelExpRange = nextLevelRequiredExp - currentLevelRequiredExp;
    final currentLevelProgress = currentExp - currentLevelRequiredExp;

    if (levelExpRange <= 0) return 1.0;

    return (currentLevelProgress / levelExpRange).clamp(0.0, 1.0);
  }

  /// 경험치 추가 및 자동 레벨업 체크
  Future<void> addExperience(int exp) async {
    if (exp <= 0) return;

    try {
      final currentProfile = _userProfile ?? UserProfile(
        uid: 'local_user',
        email: 'local@example.com',
        name: _nickname,
        provider: LoginProvider.none,
      );

      final newExperience = currentProfile.experience + exp;
      int newLevel = currentProfile.level;

      // 레벨업 체크
      while (newLevel < 100) { // 최대 레벨 100으로 제한
        final requiredExp = calculateRequiredExpForLevel(newLevel + 1);
        if (newExperience >= requiredExp) {
          newLevel++;
        } else {
          break;
        }
      }

      final updatedProfile = currentProfile.copyWith(
        experience: newExperience,
        level: newLevel,
      );

      // 레벨업 확인
      if (newLevel > currentProfile.level) {
        final levelDiff = newLevel - currentProfile.level;
        print('🎉 레벨업! ${currentProfile.level} → $newLevel (+$levelDiff레벨)');

        // 레벨업 보상 포인트 지급 (레벨당 100포인트)
        final bonusPoints = levelDiff * 100;
        final finalProfile = updatedProfile.copyWith(
          points: updatedProfile.points + bonusPoints,
        );

        await updateUserProfile(finalProfile);
        print('📈 경험치 획득: +${exp}XP (총 ${newExperience}XP)');
        print('🎁 레벨업 보상: +${bonusPoints}P (총 ${finalProfile.points}P)');
      } else {
        await updateUserProfile(updatedProfile);
        print('📈 경험치 획득: +${exp}XP (총 ${newExperience}XP)');
      }
    } catch (e) {
      print('경험치 추가 실패: $e');
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

  // ⭐ 수정된 부분: 요리 히스토리 추가 시 퀘스트 및 뱃지 업데이트 트리거
  void addCookingHistory(Recipe recipe) {
    _cookingHistory.insert(0, CookingHistory(recipe: recipe, dateTime: DateTime.now()));
    saveUserStatus();

    // 요리 완료 시 난이도별 경험치 지급
    int expToAdd = getDifficultyExperience(recipe.difficulty);
    addExperience(expToAdd);

    notifyListeners();

    // 🎯 즉시 퀘스트 및 뱃지 진행도 업데이트 트리거 (동기적으로)
    Future.microtask(() async {
      await _triggerQuestUpdate();
      await _triggerBadgeUpdate();
    });
  }

  void startCooking(Recipe recipe) {
    _ongoingCooking.insert(0, OngoingCooking(recipe: recipe, startTime: DateTime.now()));
    if (_ongoingCooking.length > 2) {
      _ongoingCooking.removeLast();
    }
    saveUserStatus();
    notifyListeners();
  }

  // ⭐ 수정된 부분: 요리 완료 시 퀘스트 및 뱃지 업데이트 트리거
  void endCooking(Recipe recipe) {
    _ongoingCooking.removeWhere((cooking) => cooking.recipe.id == recipe.id);
    addCookingHistory(recipe);
    saveUserStatus();
    notifyListeners();

    // 🎯 즉시 퀘스트 및 뱃지 진행도 업데이트 트리거 (추가 안전성 위해)
    Future.microtask(() async {
      await _triggerQuestUpdate();
      await _triggerBadgeUpdate();
    });
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

  Future<void> reset() async {
    _cookingHistory.clear();
    _ongoingCooking.clear();
    _isInitialized = false;
    _userProfile = null;
    _profileImage = null;
    _nickname = generateRandomNickname();
    
    // Hive에서 UserProfile 완전 삭제
    await HiveService.clearUserProfile();
    
    saveUserStatus();
    notifyListeners();
  }
}