import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../data/badgeData.dart';
import '../funcs/badgeChecker_func.dart';
import '../services/hive_service.dart';
import '../widgets/_widgets.dart';
import '_status.dart';

class BadgeStatus extends ChangeNotifier {
  List<Badge> _badges = [];
  List<UserBadgeProgress> _userBadgeProgressList = [];
  UserBadgeProgress? _mainBadge;
  bool _isLoading = false;

  // 뱃지 업데이트를 위한 콜백 함수 (다른 Status들로부터 받음)
  Future<void> Function()? _badgeUpdateCallback;
  
  // UserStatus 연동을 위한 콜백 함수
  Future<void> Function(String?)? _userProfileUpdateCallback;
  
  // 뱃지 팝업 관련 필드
  List<Badge> _pendingBadgeNotifications = [];
  bool _isShowingBadgePopup = false;
  BuildContext? _currentContext;
  bool _isMigrationCompleted = false;
  
  // 이번 세션에서 새로 획득한 뱃지 추적
  List<String> _currentSessionNewBadges = [];

  // Getters
  List<Badge> get badges => List.unmodifiable(_badges);
  List<UserBadgeProgress> get userBadgeProgressList => List.unmodifiable(_userBadgeProgressList);
  UserBadgeProgress? get mainBadge => _mainBadge;
  bool get isLoading => _isLoading;
  
  // 편의 Getters
  List<UserBadgeProgress> get unlockedBadges => 
    _userBadgeProgressList.where((badge) => badge.isUnlocked).toList();
  
  List<UserBadgeProgress> get lockedBadges => 
    _userBadgeProgressList.where((badge) => !badge.isUnlocked).toList();

  // 생성자에서 초기화 지연
  BadgeStatus() {
    // 다음 프레임에서 초기화하여 Hive가 완전히 준비된 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBadges();
    });
  }

  /// 뱃지 업데이트 콜백 설정 (다른 Status들로부터)
  void setBadgeUpdateCallback(Future<void> Function()? callback) {
    _badgeUpdateCallback = callback;
    print('BadgeStatus: Badge update callback set');
  }

  /// UserStatus 프로필 업데이트 콜백 설정
  void setUserProfileUpdateCallback(Future<void> Function(String?)? callback) {
    _userProfileUpdateCallback = callback;
    print('BadgeStatus: UserProfile update callback set');
  }

  /// 앱 시작 시 뱃지 초기화
  Future<void> _initializeBadges() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("🚀 Initializing badges...");

      // 전체 뱃지 목록 로드 (badgeData.dart에서)
      _badges = BADGE_LIST;

      // 사용자 뱃지 진행도 로드
      _userBadgeProgressList = HiveService.getUserBadgeProgress();

      // 메인 뱃지 로드
      _mainBadge = HiveService.getMainBadge();

      // 기존 사용자를 위한 초기값 설정
      await _initializeDefaultProgressForExistingUsers();

      print("✅ Initialized badges count: ${_badges.length}");
      print("✅ User progress count: ${_userBadgeProgressList.length}");

      // 뱃지 통계 업데이트
      await HiveService.updateBadgeStats();

    } catch (e) {
      print('💥 Error initializing badges: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 기존 사용자를 위한 기본값 설정
  Future<void> _initializeDefaultProgressForExistingUsers() async {
    bool hasChanges = false;

    // 기존 사용자 체크 - 마이그레이션 서비스에서 설정한 플래그 확인
    bool isExistingUser = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      isExistingUser = prefs.getBool('is_legacy_user') ?? false;
      
      // 추가적인 체크 (마이그레이션이 완료되지 않은 경우)
      if (!isExistingUser) {
        final userProfile = HiveService.getUserProfile();
        final cookingHistory = HiveService.getCookingHistory();
        isExistingUser = userProfile != null || cookingHistory.isNotEmpty;
      }
    } catch (e) {
      print("⚠️ Legacy user 체크 중 오류: $e");
      // 폴백: Hive 데이터로 판단
      final userProfile = HiveService.getUserProfile();
      final cookingHistory = HiveService.getCookingHistory();
      isExistingUser = userProfile != null || cookingHistory.isNotEmpty;
    }
    
    if (isExistingUser) {
      print("🔄 기존 사용자 감지: 뱃지 진행도 초기화 중...");
    }

    for (final badge in _badges) {
      // 진행도가 없는 뱃지들에 대해 기본값 생성
      final existingProgress = _userBadgeProgressList
          .where((p) => p.badgeId == badge.id)
          .firstOrNull;

      if (existingProgress == null) {
        final defaultProgress = UserBadgeProgress(
          badgeId: badge.id,
          currentProgress: 0,
          isUnlocked: false,
          progressUpdatedAt: DateTime.now(),
        );

        _userBadgeProgressList.add(defaultProgress);
        hasChanges = true;
      }
    }

    // 변경사항이 있으면 저장
    if (hasChanges) {
      await HiveService.saveUserBadgeProgress(_userBadgeProgressList);
      print("✅ Initialized default progress for ${_userBadgeProgressList.length} badges (기존 사용자: $isExistingUser)");
      
      // 기존 사용자의 경우 즉시 뱃지 진행도 업데이트 수행 (알림 억제)
      if (isExistingUser && _badgeUpdateCallback != null) {
        print("🔄 기존 사용자 뱃지 진행도 업데이트 실행 (알림 억제)...");
        try {
          // 기존 사용자는 알림을 표시하지 않음
          await _performMigrationBadgeUpdate();
          print("✅ 기존 사용자 뱃지 진행도 업데이트 완료 (알림 억제)");
        } catch (e) {
          print("💥 기존 사용자 뱃지 진행도 업데이트 실패: $e");
        }
      }
    }
  }

  /// 뱃지 진행도 업데이트 (BadgeChecker 활용)
  Future<void> updateBadgeProgress(
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      {bool suppressNotifications = false}
      ) async {
    if (_isLoading) return;

    try {
      print("🔄 Updating badge progress... (suppressNotifications: $suppressNotifications)");

      bool hasChanges = false;
      List<UserBadgeProgress> newlyUnlockedBadges = [];

      // BadgeChecker 캐시 클리어하여 최신 데이터 보장
      BadgeChecker.clearCache();
      
      // 배치로 모든 뱃지 진행도 계산 (성능 최적화)
      final progressResults = BadgeChecker.calculateMultipleBadgeProgress(
        _badges,
        userStatus,
        foodStatus,
        recipeStatus,
        _userBadgeProgressList,
      );

      for (int i = 0; i < _userBadgeProgressList.length; i++) {
        final userProgress = _userBadgeProgressList[i];
        final badge = getBadgeById(userProgress.badgeId);

        if (badge == null) continue;

        // 이미 완료된 뱃지는 건너뛰기 (단, 디버그 로그는 출력)
        if (userProgress.isUnlocked) {
          print('⭐ Badge "${badge.name}" already unlocked, skipping...');
          continue;
        }
        
        print('🔍 Checking badge "${badge.name}" - current: ${userProgress.currentProgress}, unlocked: ${userProgress.isUnlocked}');

        // BadgeChecker로 현재 진행도 계산
        final newProgress = progressResults[badge.id] ?? 0;
        final targetCount = _getTargetCount(badge);

        // 진행도가 변경되었거나, 조건을 만족하지만 unlock되지 않은 경우 처리
        final isNowCompleted = newProgress >= targetCount;
        final needsUpdate = newProgress != userProgress.currentProgress || 
                           (isNowCompleted && !userProgress.isUnlocked);
        
        if (needsUpdate) {
          print('📈 Badge "${badge.name}" progress: ${userProgress.currentProgress} -> $newProgress (completed: $isNowCompleted, unlocked: ${userProgress.isUnlocked})');

          // 뱃지 진행도 업데이트
          final updatedProgress = userProgress.copyWith(
            currentProgress: newProgress,
            isUnlocked: isNowCompleted,
            unlockedAt: isNowCompleted ? DateTime.now() : null,
            progressUpdatedAt: DateTime.now(),
          );

          _userBadgeProgressList[i] = updatedProgress;
          hasChanges = true;

          // 새로 완료된 뱃지 추가
          if (isNowCompleted && !userProgress.isUnlocked) {
            newlyUnlockedBadges.add(updatedProgress);
            print('🎉 Badge unlocked: ${badge.name}');

            // 이번 세션에서 새로 획득한 뱃지로 추가
            _currentSessionNewBadges.add(badge.id);

            // 첫 번째 획득 뱃지를 메인 뱃지로 설정
            if (_mainBadge == null) {
              await _setMainBadgeInternal(badge.id);
            }
            
            // 즉시 알림 표시 (개별적으로) - suppressNotifications가 false이고 마이그레이션이 완료된 후에만
            if (!suppressNotifications && (_isMigrationCompleted || _isNewUser())) {
              await _showBadgeUnlockedNotification(updatedProgress);
            } else {
              print('🔕 Badge notification suppressed: migration=${!_isMigrationCompleted}, suppress=${suppressNotifications}, badge=${badge.name}');
            }
          }

          // Hive에 개별 뱃지 진행도 업데이트
          await HiveService.updateBadgeProgress(
            badgeId: badge.id,
            currentProgress: newProgress,
            isUnlocked: isNowCompleted,
            unlockedAt: isNowCompleted ? DateTime.now() : null,
          );
        }
      }

      // 변경사항이 있으면 알림
      if (hasChanges) {
        notifyListeners();

        // 뱃지 통계 업데이트
        await HiveService.updateBadgeStats();
      }

      print("✅ Badge progress update completed. Changes: $hasChanges");
    } catch (e) {
      print('💥 Error updating badge progress: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// 뱃지 획득 처리 및 알림 (내부용)
  Future<void> unlockBadge(String badgeId) async {
    try {
      final badge = getBadgeById(badgeId);
      if (badge == null) {
        print('❌ Badge not found: $badgeId');
        return;
      }

      final progressIndex = _userBadgeProgressList.indexWhere((p) => p.badgeId == badgeId);
      if (progressIndex == -1) {
        print('❌ Badge progress not found: $badgeId');
        return;
      }

      final userProgress = _userBadgeProgressList[progressIndex];

      // 이미 획득한 뱃지인 경우
      if (userProgress.isUnlocked) {
        print('⚠️ Badge already unlocked: ${badge.name}');
        return;
      }

      print('🎁 Unlocking badge: ${badge.name}');

      // 뱃지 상태 업데이트
      final updatedProgress = userProgress.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progressUpdatedAt: DateTime.now(),
      );

      _userBadgeProgressList[progressIndex] = updatedProgress;

      // Hive에 저장
      await HiveService.updateBadgeProgress(
        badgeId: badgeId,
        currentProgress: userProgress.currentProgress,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      // 첫 번째 획득 뱃지를 메인 뱃지로 설정
      if (_mainBadge == null) {
        await _setMainBadgeInternal(badgeId);
      }

      // 뱃지 통계 업데이트
      await HiveService.updateBadgeStats();

      notifyListeners();

      // 알림 표시
      await _showBadgeUnlockedNotification(updatedProgress);

      print('✅ Badge unlocked successfully: ${badge.name}');
    } catch (e) {
      print('💥 Error unlocking badge $badgeId: $e');
    }
  }

  /// 메인 뱃지 변경
  Future<bool> setMainBadge(String badgeId) async {
    try {
      final badge = getBadgeById(badgeId);
      if (badge == null) {
        print('❌ Badge not found: $badgeId');
        return false;
      }

      final userProgress = getBadgeProgress(badgeId);
      if (userProgress == null || !userProgress.isUnlocked) {
        print('⚠️ Badge not unlocked yet: ${badge.name}');
        return false;
      }

      await _setMainBadgeInternal(badgeId);

      print('✅ Main badge changed to: ${badge.name}');
      return true;
    } catch (e) {
      print('💥 Error setting main badge $badgeId: $e');
      return false;
    }
  }

  /// 메인 뱃지 해제
  Future<bool> clearMainBadge() async {
    try {
      // Hive에서 메인 뱃지 클리어
      await HiveService.clearMainBadge();

      // 로컬 상태 업데이트
      _mainBadge = null;
      _userBadgeProgressList = HiveService.getUserBadgeProgress();

      // UserStatus 프로필 업데이트 트리거 (null로 해제)
      if (_userProfileUpdateCallback != null) {
        try {
          await _userProfileUpdateCallback!(null);
          print('BadgeStatus: UserProfile updated - main badge cleared');
        } catch (e) {
          print('BadgeStatus: Error clearing user profile badge: $e');
        }
      }

      notifyListeners();

      print('✅ Main badge cleared successfully');
      return true;
    } catch (e) {
      print('💥 Error clearing main badge: $e');
      return false;
    }
  }

  /// 메인 뱃지 설정 (내부용)
  Future<void> _setMainBadgeInternal(String badgeId) async {
    // Hive에서 메인 뱃지 설정
    await HiveService.setMainBadge(badgeId);

    // 로컬 상태 업데이트
    _mainBadge = HiveService.getMainBadge();
    _userBadgeProgressList = HiveService.getUserBadgeProgress();

    // UserStatus 프로필 업데이트 트리거
    if (_userProfileUpdateCallback != null) {
      try {
        await _userProfileUpdateCallback!(badgeId);
        print('BadgeStatus: UserProfile updated with main badge: $badgeId');
      } catch (e) {
        print('BadgeStatus: Error updating user profile: $e');
      }
    }

    notifyListeners();
  }

  /// 카테고리별 뱃지 필터링
  List<Badge> getBadgesByCategory(BadgeCategory category) {
    return _badges.where((badge) => badge.category == category).toList();
  }

  /// 난이도별 뱃지 필터링
  List<Badge> getBadgesByDifficulty(BadgeDifficulty difficulty) {
    return _badges.where((badge) => badge.difficulty == difficulty).toList();
  }

  /// 개별 뱃지 진행도 조회
  UserBadgeProgress? getBadgeProgress(String badgeId) {
    try {
      return _userBadgeProgressList.firstWhere((p) => p.badgeId == badgeId);
    } catch (e) {
      return null;
    }
  }

  /// 뱃지 ID로 뱃지 찾기
  Badge? getBadgeById(String badgeId) {
    try {
      return _badges.firstWhere((badge) => badge.id == badgeId);
    } catch (e) {
      return null;
    }
  }

  /// 진행 중인 뱃지 목록
  List<UserBadgeProgress> get inProgressBadges =>
      _userBadgeProgressList.where((p) => !p.isUnlocked && p.currentProgress > 0).toList();

  /// 전체 뱃지 진행률 계산
  double get totalProgressPercentage {
    if (_badges.isEmpty) return 0.0;

    final totalTargetCount = _badges.fold<int>(0, (sum, badge) => sum + _getTargetCount(badge));
    final totalCurrentProgress = _userBadgeProgressList.fold<int>(0, (sum, progress) => sum + progress.currentProgress);

    if (totalTargetCount == 0) return 0.0;
    return (totalCurrentProgress / totalTargetCount * 100).clamp(0.0, 100.0);
  }

  /// 뱃지의 목표 수치 반환
  int _getTargetCount(Badge badge) {
    switch (badge.condition.type) {
      case BadgeType.totalCookingCount:
        return badge.condition.targetCookingCount ?? 1;
      case BadgeType.consecutiveCooking:
        return badge.condition.consecutiveDays ?? 1;
      case BadgeType.difficultyBasedCooking:
        return badge.condition.difficultyCount ?? 1;
      case BadgeType.recipeTypeCooking:
        return badge.condition.recipeTypeCount ?? 1;
      case BadgeType.timeBasedCooking:
        return badge.condition.timeBasedCount ?? 1;
      case BadgeType.wishlistCollection:
        return badge.condition.wishlistCount ?? 1;
      case BadgeType.recipeRetry:
        return badge.condition.sameRecipeRetryCount ?? 1;
    }
  }

  /// 뱃지 획득 알림 표시
  Future<void> _showBadgeUnlockedNotification(UserBadgeProgress unlockedBadge) async {
    try {
      final badge = getBadgeById(unlockedBadge.badgeId);
      if (badge == null) return;

      // 콘솔 로그
      print('🎉 뱃지 획득 알림: ${badge.name}');
      print('   설명: ${badge.description}');
      print('   카테고리: ${badge.category.displayName}');
      print('   난이도: ${badge.difficulty.displayName}');

      // 새로 획득한 뱃지를 대기열에 추가 (중복 방지)
      if (!_pendingBadgeNotifications.any((b) => b.id == badge.id)) {
        _pendingBadgeNotifications.add(badge);
        print('🔔 Badge "${badge.name}" added to notification queue');
      } else {
        print('⚠️ Badge "${badge.name}" already in notification queue, skipping...');
      }
      
      // 현재 화면에서 팝업을 표시할 수 있으면 즉시 표시
      _tryShowNextBadgePopup();

    } catch (e) {
      print('💥 Error showing badge unlocked notification: $e');
    }
  }

  /// 상태별 뱃지 목록 (화면에서 사용)
  List<UserBadgeProgress> getBadgesByStatus({
    bool? isUnlocked,
    BadgeCategory? category,
    BadgeDifficulty? difficulty,
  }) {
    return _userBadgeProgressList.where((progress) {
      // 잠금 해제 여부 필터링
      if (isUnlocked != null && progress.isUnlocked != isUnlocked) {
        return false;
      }

      // 카테고리 필터링
      if (category != null) {
        final badge = getBadgeById(progress.badgeId);
        if (badge == null || badge.category != category) {
          return false;
        }
      }

      // 난이도 필터링
      if (difficulty != null) {
        final badge = getBadgeById(progress.badgeId);
        if (badge == null || badge.difficulty != difficulty) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 수동 새로고침
  Future<void> refreshBadges() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("🔄 Refreshing badges...");

      // 사용자 뱃지 진행도 재로드
      _userBadgeProgressList = HiveService.getUserBadgeProgress();
      _mainBadge = HiveService.getMainBadge();

      // 뱃지 통계 업데이트
      await HiveService.updateBadgeStats();

      print("✅ Refreshed badges");
    } catch (e) {
      print('💥 Error refreshing badges: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 디버깅용 정보 출력
  void printBadgeStatus() {
    print('=== Badge Status ===');
    print('Total Badges: ${_badges.length}');
    print('Unlocked Badges: ${unlockedBadges.length}');
    print('In Progress Badges: ${inProgressBadges.length}');
    print('Total Progress: ${totalProgressPercentage.toStringAsFixed(1)}%');
    print('Main Badge: ${_mainBadge?.badgeId ?? 'None'}');

    // 카테고리별 통계
    for (final category in BadgeCategory.values) {
      final categoryBadges = getBadgesByCategory(category);
      final unlockedInCategory = getBadgesByStatus(isUnlocked: true, category: category);
      print('${category.displayName}: ${unlockedInCategory.length}/${categoryBadges.length}');
    }
    print('==================');
  }

  /// 뱃지 데이터 클리어 (테스트용)
  Future<void> clearBadges() async {
    try {
      await HiveService.clearBadgeProgress();
      _userBadgeProgressList.clear();
      _mainBadge = null;
      notifyListeners();
      print('🗑️ All badge progress cleared');
    } catch (e) {
      print('💥 Error clearing badges: $e');
    }
  }

  /// BadgeChecker 캐시 초기화 (메모리 절약)
  void clearBadgeCache() {
    BadgeChecker.clearCache();
    print('🗑️ Badge checker cache cleared');
  }
  
  // =============== 뱃지 팝업 관련 메서드 ===============
  
  /// 현재 컨텍스트 설정 (화면에서 호출)
  void setCurrentContext(BuildContext? context) {
    _currentContext = context;
  }
  
  /// 다음 뱃지 팝업 표시 시도
  void _tryShowNextBadgePopup() {
    if (_isShowingBadgePopup || _pendingBadgeNotifications.isEmpty) {
      return;
    }
    
    // 컨텍스트가 없으면 잠깐 후 다시 시도
    if (_currentContext == null) {
      print('⏰ No context available for badge popup, retrying in 1 second...');
      Future.delayed(const Duration(seconds: 1), () {
        _tryShowNextBadgePopup();
      });
      return;
    }
    
    _showBadgePopup(_pendingBadgeNotifications.removeAt(0));
  }
  
  /// 뱃지 팝업 표시
  Future<void> _showBadgePopup(Badge badge) async {
    if (_currentContext == null) return;
    
    _isShowingBadgePopup = true;
    
    try {
      await showBadgeUnlockedDialog(
        context: _currentContext!,
        badge: badge,
        onConfirm: () {
          _isShowingBadgePopup = false;
          // 다음 대기 중인 뱃지가 있으면 연속으로 표시
          Future.delayed(const Duration(milliseconds: 300), () {
            _tryShowNextBadgePopup();
          });
        },
      );
    } catch (e) {
      print('💥 Error showing badge popup: $e');
      _isShowingBadgePopup = false;
      // 에러 발생 시에도 다음 뱃지 시도
      _tryShowNextBadgePopup();
    }
  }
  
  /// 수동으로 팝업 표시 (외부에서 호출 가능)
  void showPendingBadgePopups() {
    _tryShowNextBadgePopup();
  }
  
  /// 대기 중인 팝업 개수
  int get pendingBadgeCount => _pendingBadgeNotifications.length;
  
  /// 모든 대기 중인 팝업 클리어
  void clearPendingBadgePopups() {
    _pendingBadgeNotifications.clear();
    print('🗑️ All pending badge popups cleared');
  }
  
  /// 이번 세션에서 새로 획득한 뱃지 목록 반환
  List<String> getCurrentSessionNewBadges() {
    return List.unmodifiable(_currentSessionNewBadges);
  }
  
  /// 이번 세션 새 뱃지 목록 초기화 (새로운 요리 시작 시 호출)
  void clearCurrentSessionNewBadges() {
    _currentSessionNewBadges.clear();
    print('🗑️ Current session new badges cleared');
  }
  
  /// 마이그레이션용 뱃지 업데이트 (알림 억제)
  Future<void> _performMigrationBadgeUpdate() async {
    if (_badgeUpdateCallback == null) return;
    
    try {
      // 기존 콜백은 suppressNotifications 매개변수를 지원하지 않으므로
      // 임시로 팝업 대기열을 클리어하고 알림을 억제하는 플래그를 설정
      final originalNotifications = List<Badge>.from(_pendingBadgeNotifications);
      _pendingBadgeNotifications.clear();
      
      // 일시적으로 컨텍스트를 null로 설정하여 팝업이 표시되지 않도록 함
      final originalContext = _currentContext;
      _currentContext = null;
      
      // 뱃지 업데이트 실행
      await _badgeUpdateCallback!();
      
      // 원래 컨텍스트 복원 (새로운 알림은 허용)
      _currentContext = originalContext;
      
      // 마이그레이션 중 생성된 알림들은 제거 (기존 획득 뱃지들)
      _pendingBadgeNotifications.clear();
      
      // 마이그레이션 완료 플래그 설정
      _isMigrationCompleted = true;
      
      print('🔕 Migration badge update completed with suppressed notifications');
      
    } catch (e) {
      print('💥 Error in migration badge update: $e');
      // 에러 발생 시 컨텍스트 복원
      _currentContext = _currentContext;
    }
  }
  
  /// 새 사용자인지 확인 (요리 히스토리가 거의 없는 경우)
  bool _isNewUser() {
    try {
      final cookingHistoryCount = HiveService.getCookingHistory().length;
      return cookingHistoryCount <= 1; // 첫 요리 또는 아직 요리하지 않은 사용자
    } catch (e) {
      print('⚠️ Error checking if new user: $e');
      return true; // 에러 시 새 사용자로 간주
    }
  }
}