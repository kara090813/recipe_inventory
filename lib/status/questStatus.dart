import 'package:flutter/foundation.dart';
import '../models/_models.dart';
import '../models/questSyncService.dart';
import '../funcs/questChecker_func.dart';
import '../services/hive_service.dart';
import '../funcs/notification_service.dart';
import '_status.dart';

class QuestStatus extends ChangeNotifier {
  final QuestSyncService _syncService = QuestSyncService();
  List<Quest> _quests = [];
  bool _isLoading = false;

  // Getters
  List<Quest> get quests => List.unmodifiable(_quests);
  bool get isLoading => _isLoading;

  // 생성자에서 초기화
  QuestStatus() {
    _initializeQuests();
  }

  /// 앱 시작 시 퀘스트 동기화 및 초기화
  Future<void> _initializeQuests() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Initializing quests...");
      _quests = await _syncService.syncQuests();
      print("Initialized quests count: ${_quests.length}");
    } catch (e) {
      print('Error initializing quests: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 퀘스트 진행도 업데이트 (QuestChecker 활용)
  Future<void> updateQuestProgress(
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      ) async {
    try {
      bool hasChanges = false;
      List<Quest> completedQuests = [];

      print("Updating quest progress...");

      for (int i = 0; i < _quests.length; i++) {
        final quest = _quests[i];

        // 이미 완료된 퀘스트는 건너뛰기
        if (quest.isCompleted) continue;

        // QuestChecker로 현재 진행도 계산
        final newProgress = QuestChecker.calculateProgress(
          quest,
          userStatus,
          foodStatus,
          recipeStatus,
        );

        // 진행도가 변경되었는지 확인
        if (newProgress != quest.currentProgress) {
          print('Quest "${quest.title}" progress: ${quest.currentProgress} -> $newProgress');

          final isNowCompleted = newProgress >= quest.targetCount;

          // 퀘스트 업데이트
          final updatedQuest = quest.copyWith(
            currentProgress: newProgress,
            isCompleted: isNowCompleted,
          );

          _quests[i] = updatedQuest;
          hasChanges = true;

          // 새로 완료된 퀘스트 추가
          if (isNowCompleted && !quest.isCompleted) {
            completedQuests.add(updatedQuest);
            print('🎉 Quest completed: ${quest.title}');
          }

          // Hive에 개별 퀘스트 진행도 업데이트
          await HiveService.updateQuestProgress(
            quest.id,
            newProgress,
            isNowCompleted,
            quest.isRewardReceived,
          );
        }
      }

      // 변경사항이 있으면 알림
      if (hasChanges) {
        notifyListeners();

        // 완료된 퀘스트들에 대해 알림 표시
        for (final completedQuest in completedQuests) {
          await _showQuestCompletedNotification(completedQuest);
        }
      }

      print("Quest progress update completed. Changes: $hasChanges");
    } catch (e) {
      print('Error updating quest progress: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// 보상 수령 처리 (UserStatus.addPoints, addExperience 호출)
  Future<bool> receiveReward(String questId, UserStatus userStatus) async {
    try {
      final questIndex = _quests.indexWhere((q) => q.id == questId);
      if (questIndex == -1) {
        print('Quest not found: $questId');
        return false;
      }

      final quest = _quests[questIndex];

      // 완료되지 않았거나 이미 보상을 받은 경우
      if (!quest.isCompleted) {
        print('Quest not completed yet: ${quest.title}');
        return false;
      }

      if (quest.isRewardReceived) {
        print('Reward already received for quest: ${quest.title}');
        return false;
      }

      print('Receiving reward for quest: ${quest.title}');
      print('Reward: ${quest.rewardPoints}P, ${quest.rewardExperience}XP');

      // 포인트와 경험치 지급
      await userStatus.addPoints(quest.rewardPoints);
      await userStatus.addExperience(quest.rewardExperience);

      // 퀘스트 상태 업데이트
      final updatedQuest = quest.copyWith(isRewardReceived: true);
      _quests[questIndex] = updatedQuest;

      // Hive에 저장
      await HiveService.updateQuestProgress(
        quest.id,
        quest.currentProgress,
        quest.isCompleted,
        true, // isRewardReceived = true
      );

      notifyListeners();

      print('✅ Reward received successfully for quest: ${quest.title}');
      return true;
    } catch (e) {
      print('Error receiving reward for quest $questId: $e');
      return false;
    }
  }

  /// 수동 동기화
  Future<void> forceSync() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Force syncing quests...");
      _quests = await _syncService.forceSyncQuests();
      print("Force synced quests count: ${_quests.length}");
    } catch (e) {
      print('Error force syncing quests: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 일반 동기화 (새로고침)
  Future<void> refreshQuests() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Refreshing quests...");
      _quests = await _syncService.syncQuests();
      print("Refreshed quests count: ${_quests.length}");
    } catch (e) {
      print('Error refreshing quests: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 퀘스트 완료 알림 표시
  Future<void> _showQuestCompletedNotification(Quest quest) async {
    try {
      // 간단한 콘솔 알림 (실제 구현에서는 UI 알림이나 토스트 메시지 사용)
      print('🎉 퀘스트 완료 알림: ${quest.title}');
      print('   보상: ${quest.rewardPoints}P + ${quest.rewardExperience}XP');

      // 필요하다면 NotificationService를 사용하여 실제 알림 구현
      // await NotificationService().showQuestCompletedNotification(quest);

    } catch (e) {
      print('Error showing quest completed notification: $e');
    }
  }

  /// 특정 상태별 퀘스트 필터링
  List<Quest> getQuestsByStatus({
    bool? isCompleted,
    bool? isRewardReceived,
  }) {
    return _quests.where((quest) {
      if (isCompleted != null && quest.isCompleted != isCompleted) {
        return false;
      }
      if (isRewardReceived != null && quest.isRewardReceived != isRewardReceived) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 진행 중인 퀘스트 목록
  List<Quest> get inProgressQuests => getQuestsByStatus(isCompleted: false);

  /// 완료되었지만 보상을 받지 않은 퀘스트 목록
  List<Quest> get canReceiveRewardQuests => getQuestsByStatus(
    isCompleted: true,
    isRewardReceived: false,
  );

  /// 완전히 완료된 퀘스트 목록 (보상까지 받은)
  List<Quest> get completedQuests => getQuestsByStatus(
    isCompleted: true,
    isRewardReceived: true,
  );

  /// 특정 퀘스트 찾기
  Quest? findQuestById(String questId) {
    try {
      return _quests.firstWhere((quest) => quest.id == questId);
    } catch (e) {
      print('Quest not found with id: $questId');
      return null;
    }
  }

  /// 퀘스트 진행률 계산 (전체)
  double get totalProgressPercentage {
    if (_quests.isEmpty) return 0.0;

    final totalTargetCount = _quests.fold<int>(0, (sum, quest) => sum + quest.targetCount);
    final totalCurrentProgress = _quests.fold<int>(0, (sum, quest) => sum + quest.currentProgress);

    if (totalTargetCount == 0) return 0.0;
    return (totalCurrentProgress / totalTargetCount * 100).clamp(0.0, 100.0);
  }

  /// 수령 가능한 보상 포인트 합계
  int get totalAvailableRewardPoints {
    return canReceiveRewardQuests.fold<int>(0, (sum, quest) => sum + quest.rewardPoints);
  }

  /// 수령 가능한 보상 경험치 합계
  int get totalAvailableRewardExperience {
    return canReceiveRewardQuests.fold<int>(0, (sum, quest) => sum + quest.rewardExperience);
  }

  /// 디버깅용 정보 출력
  void printQuestStatus() {
    print('=== Quest Status ===');
    print('Total Quests: ${_quests.length}');
    print('In Progress: ${inProgressQuests.length}');
    print('Can Receive Reward: ${canReceiveRewardQuests.length}');
    print('Completed: ${completedQuests.length}');
    print('Total Progress: ${totalProgressPercentage.toStringAsFixed(1)}%');
    print('Available Rewards: ${totalAvailableRewardPoints}P + ${totalAvailableRewardExperience}XP');
    print('==================');
  }

  /// 퀘스트 데이터 클리어 (테스트용)
  Future<void> clearQuests() async {
    try {
      await HiveService.clearQuests();
      _quests.clear();
      notifyListeners();
      print('All quests cleared');
    } catch (e) {
      print('Error clearing quests: $e');
    }
  }
}