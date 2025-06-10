import 'package:flutter/foundation.dart';
import '../models/_models.dart';
import '../data/badgeData.dart';
import '../funcs/badgeChecker_func.dart';
import '../services/hive_service.dart';
import '_status.dart';

class BadgeStatus extends ChangeNotifier {
  List<Badge> _badges = [];
  List<UserBadgeProgress> _userBadgeProgressList = [];
  UserBadgeProgress? _mainBadge;
  bool _isLoading = false;

  // 뱃지 업데이트를 위한 콜백 함수 (다른 Status들로부터 받음)
  Future<void> Function()? _badgeUpdateCallback;

  // Getters
  List<Badge> get badges => List.unmodifiable(_badges);
  List<UserBadgeProgress> get userBadgeProgressList => List.unmodifiable(_userBadgeProgressList);
  UserBadgeProgress? get mainBadge => _mainBadge;
  bool get isLoading => _isLoading;

  // 생성자에서 초기화
  BadgeStatus() {
    _initializeBadges();
  }

  /// 뱃지 업데이트 콜백 설정 (다른 Status들로부터)
  void setBadgeUpdateCallback(Future<void> Function()? callback) {
    _badgeUpdateCallback = callback;
    print('BadgeStatus: Badge update callback set');
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
      print("✅ Initialized default progress for ${_userBadgeProgressList.length} badges");
    }
  }

  /// 뱃지 진행도 업데이트 (BadgeChecker 활용)
  Future<void> updateBadgeProgress(
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      ) async {
    if (_isLoading) return;

    try {
      print("🔄 Updating badge progress...");

      bool hasChanges = false;
      List<UserBadgeProgress> newlyUnlockedBadges = [];

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

        // 이미 완료된 뱃지는 건너뛰기
        if (userProgress.isUnlocked) continue;

        // BadgeChecker로 현재 진행도 계산
        final newProgress = progressResults[badge.id] ?? 0;
        final targetCount = _getTargetCount(badge);

        // 진행도가 변경되었는지 확인
        if (newProgress != userProgress.currentProgress) {
          print('📈 Badge "${badge.name}" progress: ${userProgress.currentProgress} -> $newProgress');

          final isNowCompleted = newProgress >= targetCount;

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

            // 첫 번째 획득 뱃지를 메인 뱃지로 설정
            if (_mainBadge == null) {
              await _setMainBadgeInternal(badge.id);
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

        // 새로 획득한 뱃지들에 대해 알림 표시
        for (final unlockedBadge in newlyUnlockedBadges) {
          await _showBadgeUnlockedNotification(unlockedBadge);
        }
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

  /// 메인 뱃지 설정 (내부용)
  Future<void> _setMainBadgeInternal(String badgeId) async {
    // Hive에서 메인 뱃지 설정
    await HiveService.setMainBadge(badgeId);

    // 로컬 상태 업데이트
    _mainBadge = HiveService.getMainBadge();
    _userBadgeProgressList = HiveService.getUserBadgeProgress();

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

  /// 잠금 해제된 뱃지 목록
  List<UserBadgeProgress> get unlockedBadges =>
      _userBadgeProgressList.where((p) => p.isUnlocked).toList();

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

      // 간단한 콘솔 알림 (실제 구현에서는 UI 알림이나 토스트 메시지 사용)
      print('🎉 뱃지 획득 알림: ${badge.name}');
      print('   설명: ${badge.description}');
      print('   카테고리: ${badge.category.displayName}');
      print('   난이도: ${badge.difficulty.displayName}');

      // 필요하다면 NotificationService를 사용하여 실제 알림 구현
      // await NotificationService().showBadgeUnlockedNotification(badge);

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
}