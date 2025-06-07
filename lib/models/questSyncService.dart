import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';

class QuestSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String LAST_QUEST_SYNC_MONTH_KEY = 'last_quest_sync_month';
  static const String QUEST_SYNC_TIME_KEY = 'quest_sync_time';

  /// 현재 월 키 반환 ("YYYY-MM" 형식)
  String getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// 로컬에서 퀘스트 데이터 로드 (Hive 사용)
  List<Quest> getLocalQuests() {
    try {
      return HiveService.getQuests();
    } catch (e) {
      print('Error loading local quests from Hive: $e');
      return [];
    }
  }

  /// 로컬에 퀘스트 데이터 저장 (시작 날짜 설정 포함)
  Future<void> saveQuestsLocally(List<Quest> quests, {bool setStartDate = true}) async {
    try {
      // 🆕 새로운 퀘스트인 경우 시작 날짜 설정
      final questsWithStartDate = quests.map((quest) {
        if (setStartDate && quest.startDate == null) {
          return quest.copyWith(startDate: DateTime.now());
        }
        return quest;
      }).toList();

      await HiveService.saveQuests(questsWithStartDate);

      final currentMonth = getCurrentMonthKey();
      await HiveService.setLastQuestSyncMonth(currentMonth);
      await HiveService.setQuestSyncTime(DateTime.now().millisecondsSinceEpoch);

      print('✅ Quest sync completed for month: $currentMonth (${questsWithStartDate.length} quests)');
      if (setStartDate) {
        print('📅 Quest start dates set to: ${DateTime.now()}');
      }
    } catch (e) {
      print('❌ Error saving local quests to Hive: $e');
    }
  }

  /// 🆕 새로운 퀘스트가 있는지 확인 (Firebase의 최신 월과 로컬 월 비교)
  Future<bool> hasNewerQuests() async {
    try {
      final currentMonth = getCurrentMonthKey();

      // 1. 현재 월 퀘스트 확인
      final currentMonthQuests = await fetchQuestsForMonth(currentMonth);
      if (currentMonthQuests.isNotEmpty) {
        final localQuests = getLocalQuests();
        final localMonth = HiveService.getLastQuestSyncMonth();

        // 현재 월 퀘스트가 있고, 로컬에 현재 월 퀘스트가 없으면 새로운 퀘스트
        return localMonth != currentMonth || localQuests.isEmpty;
      }

      // 2. 현재 월 퀘스트가 없으면 최신 월 찾기
      final latestMonth = await getLatestQuestMonth();
      if (latestMonth == null) return false;

      final localMonth = HiveService.getLastQuestSyncMonth();

      // 최신 월이 로컬 월보다 새로우면 새로운 퀘스트
      return latestMonth != localMonth;
    } catch (e) {
      print('❌ Error checking for newer quests: $e');
      return false;
    }
  }

  /// 🆕 Firebase에서 가장 최신 월 찾기
  Future<String?> getLatestQuestMonth() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('isActive', isEqualTo: true)
          .orderBy('monthKey', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['monthKey'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting latest quest month: $e');
      return null;
    }
  }

  /// 동기화가 필요한지 확인
  Future<bool> needsQuestSync() async {
    try {
      final localQuests = getLocalQuests();

      // 로컬에 퀘스트가 없으면 동기화 필요
      if (localQuests.isEmpty) {
        print('📭 No local quests found - sync needed');
        return true;
      }

      // 새로운 퀘스트가 있는지 확인
      final hasNewer = await hasNewerQuests();
      if (hasNewer) {
        print('🆕 Newer quests available - sync needed');
        return true;
      }

      print('✅ Quest sync not needed - using local data');
      return false;
    } catch (e) {
      print('❌ Error checking quest sync need: $e');
      return true; // 에러 발생시 안전하게 동기화 시도
    }
  }

  /// Firebase에서 특정 월 퀘스트 가져오기
  Future<List<Quest>> fetchQuestsForMonth(String monthKey) async {
    try {
      print('🔍 Fetching quests for month: $monthKey');

      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('monthKey', isEqualTo: monthKey)
          .where('isActive', isEqualTo: true)
          .get();

      final quests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _processTimestamps(data);
        return Quest.fromJson(data);
      }).toList();

      print('📦 Found ${quests.length} quests for month: $monthKey');
      return quests;
    } catch (e) {
      print('❌ Error fetching quests for month $monthKey: $e');
      return [];
    }
  }

  /// Firebase에서 최신 월 퀘스트 가져오기
  Future<List<Quest>> fetchLatestAvailableQuests() async {
    try {
      print('🔍 Fetching latest available quests...');

      final latestMonth = await getLatestQuestMonth();
      if (latestMonth == null) {
        print('❌ No quest months found in Firebase');
        return [];
      }

      print('📅 Latest quest month found: $latestMonth');
      return await fetchQuestsForMonth(latestMonth);
    } catch (e) {
      print('❌ Error fetching latest available quests: $e');
      return [];
    }
  }

  /// Timestamp 필드들을 적절히 처리
  void _processTimestamps(Map<String, dynamic> data) {
    if (data['createdAt'] is Timestamp) {
      final timestamp = data['createdAt'] as Timestamp;
      data['createdAt'] = timestamp.toDate().toIso8601String();
    }

    if (data['updatedAt'] is Timestamp) {
      final timestamp = data['updatedAt'] as Timestamp;
      data['updatedAt'] = timestamp.toDate().toIso8601String();
    }
  }

  /// 🔥 메인 동기화 함수 (완전히 새로 작성)
  Future<List<Quest>> syncQuests() async {
    try {
      print('🚀 Starting quest synchronization...');

      if (await needsQuestSync()) {
        print('🔄 Synchronization needed');

        // 🗑️ 기존 퀘스트 완전 삭제
        await HiveService.clearQuests();
        await HiveService.remove(LAST_QUEST_SYNC_MONTH_KEY);
        await HiveService.remove(QUEST_SYNC_TIME_KEY);
        print('🗑️ Cleared all existing quests');

        final currentMonth = getCurrentMonthKey();

        // 1️⃣ 현재 월 퀘스트 시도
        List<Quest> questsToUse = await fetchQuestsForMonth(currentMonth);

        if (questsToUse.isNotEmpty) {
          print('✅ Using current month quests: $currentMonth');
        } else {
          print('⚠️ No current month quests, fetching latest...');

          // 2️⃣ 최신 월 퀘스트 시도
          questsToUse = await fetchLatestAvailableQuests();

          if (questsToUse.isEmpty) {
            print('❌ No quests found in Firebase');
            return [];
          }
        }

        // 💾 새로운 퀘스트 저장 (시작 날짜 설정)
        await saveQuestsLocally(questsToUse, setStartDate: true);
        print('💾 Saved ${questsToUse.length} new quests with start date');

        return questsToUse;
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

  /// Firebase에서 퀘스트 개수 확인 (디버깅용)
  Future<int> getFirebaseQuestCount() async {
    try {
      final AggregateQuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting Firebase quest count: $e');
      return 0;
    }
  }

  /// 강제 동기화 (테스트용)
  Future<List<Quest>> forceSyncQuests() async {
    try {
      print('🔥 Force syncing quests...');

      // 로컬 데이터 완전 클리어
      await HiveService.clearQuests();
      await HiveService.remove(LAST_QUEST_SYNC_MONTH_KEY);
      await HiveService.remove(QUEST_SYNC_TIME_KEY);

      // 동기화 실행
      return await syncQuests();
    } catch (e) {
      print('💥 Error in force sync: $e');
      return [];
    }
  }

  /// 디버깅용 정보 출력
  Future<void> printSyncStatus() async {
    try {
      print('=== Quest Sync Status ===');
      print('Current Month: ${getCurrentMonthKey()}');
      print('Last Sync Month: ${HiveService.getLastQuestSyncMonth()}');

      final lastSyncTime = HiveService.getQuestSyncTime();
      if (lastSyncTime != null) {
        final syncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncTime);
        print('Last Sync Time: $syncDate');
      } else {
        print('Last Sync Time: Never');
      }

      final localQuests = getLocalQuests();
      print('Local Quests Count: ${localQuests.length}');

      if (localQuests.isNotEmpty) {
        final monthKeys = localQuests.map((q) => q.monthKey).toSet();
        print('Local Quest Months: ${monthKeys.join(", ")}');
        print('Quest Start Dates: ${localQuests.map((q) => q.startDate).toSet()}');
      }

      final latestMonth = await getLatestQuestMonth();
      print('Latest Firebase Month: $latestMonth');

      final firebaseCount = await getFirebaseQuestCount();
      print('Firebase Active Quests Count: $firebaseCount');

      final needsSync = await needsQuestSync();
      print('Needs Sync: $needsSync');
      print('========================');
    } catch (e) {
      print('❌ Error printing sync status: $e');
    }
  }
}