import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';

class QuestSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String LAST_QUEST_CHECK_TIME_KEY = 'last_quest_check_time';
  static const int CHECK_INTERVAL_DAYS = 7; // 1주일마다 체크

  /// 로컬에서 퀘스트 데이터 로드
  List<Quest> getLocalQuests() {
    try {
      return HiveService.getQuests();
    } catch (e) {
      print('❌ Error loading local quests: $e');
      return [];
    }
  }

  /// 로컬에 퀘스트 데이터 저장 (싱크 시간 설정 포함)
  Future<void> saveQuestsLocally(List<Quest> quests) async {
    try {
      final now = DateTime.now();

      // 모든 퀘스트에 syncedAt 시간 설정
      final questsWithSyncTime = quests.map((quest) {
        return quest.copyWith(syncedAt: now);
      }).toList();

      await HiveService.saveQuests(questsWithSyncTime);
      await HiveService.setInt(LAST_QUEST_CHECK_TIME_KEY, now.millisecondsSinceEpoch);

      print('✅ Saved ${questsWithSyncTime.length} quests with sync time: $now');
    } catch (e) {
      print('❌ Error saving quests locally: $e');
    }
  }

  /// Firebase에서 활성 퀘스트들 가져오기
  Future<List<Quest>> fetchActiveQuests() async {
    try {
      print('🔍 Fetching active quests from Firebase...');

      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('isActive', isEqualTo: true)
          .get();

      final quests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Firebase 문서 ID 설정
        _processTimestamps(data);
        return Quest.fromJson(data);
      }).toList();

      print('📦 Found ${quests.length} active quests');
      return quests;
    } catch (e) {
      print('❌ Error fetching active quests: $e');
      return [];
    }
  }

  /// Firebase에서 가장 최신 퀘스트 하나 가져오기 (updatedAt 기준)
  Future<Quest?> fetchLatestQuest() async {
    try {
      print('🔍 Fetching latest quest from Firebase...');

      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('📭 No active quests found in Firebase');
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      _processTimestamps(data);

      final quest = Quest.fromJson(data);
      print('📅 Latest quest: ${quest.title} (updated: ${quest.updatedAt})');
      return quest;
    } catch (e) {
      print('❌ Error fetching latest quest: $e');
      return null;
    }
  }

  /// 로컬에서 가장 최신 퀘스트 가져오기 (updatedAt 기준)
  Quest? getLatestLocalQuest() {
    final localQuests = getLocalQuests();
    if (localQuests.isEmpty) return null;

    // updatedAt 기준으로 가장 최신 퀘스트 찾기
    localQuests.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return localQuests.first;
  }

  /// 마지막 체크 시간부터 1주일이 지났는지 확인
  bool shouldCheckForUpdates() {
    try {
      final lastCheckTime = HiveService.getInt(LAST_QUEST_CHECK_TIME_KEY);
      if (lastCheckTime == null) {
        print('📅 No previous check time found - should check');
        return true;
      }

      final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckTime);
      final daysSinceLastCheck = DateTime.now().difference(lastCheck).inDays;

      final shouldCheck = daysSinceLastCheck >= CHECK_INTERVAL_DAYS;
      print('📅 Days since last check: $daysSinceLastCheck / $CHECK_INTERVAL_DAYS - Should check: $shouldCheck');

      return shouldCheck;
    } catch (e) {
      print('❌ Error checking update interval: $e');
      return true; // 에러 시 안전하게 체크
    }
  }

  /// 동기화가 필요한지 확인
  Future<bool> needsSync() async {
    try {
      final localQuests = getLocalQuests();

      // 1. 로컬에 퀘스트가 없으면 동기화 필요
      if (localQuests.isEmpty) {
        print('📭 No local quests - sync needed');
        return true;
      }

      // 2. 1주일이 지나지 않았으면 동기화 불필요
      if (!shouldCheckForUpdates()) {
        print('⏰ Check interval not reached - sync not needed');
        return false;
      }

      // 3. Firebase 최신 퀘스트와 로컬 최신 퀘스트 비교
      final latestFirebaseQuest = await fetchLatestQuest();
      if (latestFirebaseQuest == null) {
        print('📭 No Firebase quests found - sync not needed');
        return false;
      }

      final latestLocalQuest = getLatestLocalQuest();
      if (latestLocalQuest == null) {
        print('📭 No local quests found - sync needed');
        return true;
      }

      // 문서 ID가 다르면 새로운 퀘스트가 있음
      final needsSync = latestFirebaseQuest.id != latestLocalQuest.id;
      print('🔍 Latest Firebase quest ID: ${latestFirebaseQuest.id}');
      print('🔍 Latest local quest ID: ${latestLocalQuest.id}');
      print('🔍 Sync needed: $needsSync');

      return needsSync;
    } catch (e) {
      print('❌ Error checking sync need: $e');
      return true; // 에러 시 안전하게 동기화
    }
  }

  /// Timestamp 필드 처리
  void _processTimestamps(Map<String, dynamic> data) {
    if (data['updatedAt'] is Timestamp) {
      final timestamp = data['updatedAt'] as Timestamp;
      data['updatedAt'] = timestamp.toDate().toIso8601String();
    } else if (data['updatedAt'] == null) {
      data['updatedAt'] = DateTime.now().toIso8601String();
    }

    if (data['createdAt'] is Timestamp) {
      final timestamp = data['createdAt'] as Timestamp;
      data['createdAt'] = timestamp.toDate().toIso8601String();
    }
  }

  /// 🔥 메인 동기화 함수
  Future<List<Quest>> syncQuests() async {
    try {
      print('🚀 Starting quest synchronization...');

      if (await needsSync()) {
        print('🔄 Synchronization needed');

        // 🗑️ 기존 퀘스트 완전 삭제
        await HiveService.clearQuests();
        print('🗑️ Cleared all existing quests');

        // 📥 새로운 활성 퀘스트들 가져오기
        final newQuests = await fetchActiveQuests();

        if (newQuests.isEmpty) {
          print('❌ No active quests found in Firebase');
          return [];
        }

        // 💾 새로운 퀘스트 저장 (싱크 시간 설정)
        await saveQuestsLocally(newQuests);
        print('💾 Saved ${newQuests.length} new quests');

        return newQuests;
      } else {
        // 📚 로컬 데이터 사용
        final localQuests = getLocalQuests();
        print('📚 Using existing local quests (${localQuests.length} quests)');
        return localQuests;
      }
    } catch (e) {
      print('💥 Error syncing quests: $e');
      print('📚 Falling back to local quests');

      // 에러 발생시 로컬 데이터 반환
      return getLocalQuests();
    }
  }

  /// 강제 동기화 (테스트용)
  Future<List<Quest>> forceSyncQuests() async {
    try {
      print('🔥 Force syncing quests...');

      // 로컬 데이터 완전 클리어
      await HiveService.clearQuests();
      await HiveService.remove(LAST_QUEST_CHECK_TIME_KEY);

      // 새로운 퀘스트 가져오기
      final newQuests = await fetchActiveQuests();
      if (newQuests.isNotEmpty) {
        await saveQuestsLocally(newQuests);
      }

      return newQuests;
    } catch (e) {
      print('💥 Error in force sync: $e');
      return [];
    }
  }

  /// 디버깅용 정보 출력
  Future<void> printSyncStatus() async {
    try {
      print('=== Quest Sync Status ===');

      final lastCheckTime = HiveService.getInt(LAST_QUEST_CHECK_TIME_KEY);
      if (lastCheckTime != null) {
        final checkDate = DateTime.fromMillisecondsSinceEpoch(lastCheckTime);
        print('Last Check Time: $checkDate');
        print('Days Since Check: ${DateTime.now().difference(checkDate).inDays}');
      } else {
        print('Last Check Time: Never');
      }

      final localQuests = getLocalQuests();
      print('Local Quests Count: ${localQuests.length}');

      if (localQuests.isNotEmpty) {
        final latestLocal = getLatestLocalQuest();
        print('Latest Local Quest: ${latestLocal?.title} (ID: ${latestLocal?.id})');
        print('Latest Local Updated: ${latestLocal?.updatedAt}');
        print('Latest Local Synced: ${latestLocal?.syncedAt}');
      }

      final latestFirebase = await fetchLatestQuest();
      if (latestFirebase != null) {
        print('Latest Firebase Quest: ${latestFirebase.title} (ID: ${latestFirebase.id})');
        print('Latest Firebase Updated: ${latestFirebase.updatedAt}');
      }

      final needsSync = await this.needsSync();
      print('Needs Sync: $needsSync');
      print('========================');
    } catch (e) {
      print('❌ Error printing sync status: $e');
    }
  }
}