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

  /// 로컬에 퀘스트 데이터 저장 (Hive 사용)
  Future<void> saveQuestsLocally(List<Quest> quests) async {
    try {
      await HiveService.saveQuests(quests);

      // 동기화 시간과 월 정보 저장
      final currentMonth = getCurrentMonthKey();
      await HiveService.setLastQuestSyncMonth(currentMonth);
      await HiveService.setQuestSyncTime(DateTime.now().millisecondsSinceEpoch);

      print('Quest sync completed for month: $currentMonth (${quests.length} quests)');
    } catch (e) {
      print('Error saving local quests to Hive: $e');
    }
  }

  /// 동기화가 필요한지 확인
  Future<bool> needsQuestSync() async {
    try {
      final localQuests = getLocalQuests();
      final currentMonth = getCurrentMonthKey();

      // 로컬에 퀘스트가 없으면 동기화 필요
      if (localQuests.isEmpty) {
        print('No local quests found - sync needed');
        return true;
      }

      // 마지막 동기화 월 확인
      final lastSyncMonth = HiveService.getLastQuestSyncMonth();
      if (lastSyncMonth == null || lastSyncMonth != currentMonth) {
        print('Month changed ($lastSyncMonth -> $currentMonth) - sync needed');
        return true;
      }

      // 로컬 퀘스트의 monthKey가 현재 월과 다른지 확인
      final hasCurrentMonthQuests = localQuests.any((quest) => quest.monthKey == currentMonth);
      if (!hasCurrentMonthQuests) {
        print('Local quests not for current month - sync needed');
        return true;
      }

      print('Quest sync not needed - using local data');
      return false;
    } catch (e) {
      print('Error checking quest sync need: $e');
      return true; // 에러 발생시 안전하게 동기화 시도
    }
  }

  /// Firebase에서 현재 월 퀘스트 가져오기
  Future<List<Quest>> fetchCurrentMonthQuests() async {
    try {
      final currentMonth = getCurrentMonthKey();
      print('Fetching quests for current month: $currentMonth');

      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('monthKey', isEqualTo: currentMonth)
          .where('isActive', isEqualTo: true)
          .get();

      final quests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Timestamp 처리
        _processTimestamps(data);

        return Quest.fromJson(data);
      }).toList();

      print('Found ${quests.length} quests for current month');
      return quests;
    } catch (e) {
      print('Error fetching current month quests: $e');
      return [];
    }
  }

  /// Firebase에서 최신 월 퀘스트 가져오기 (현재 월 퀘스트가 없을 때)
  Future<List<Quest>> fetchLatestAvailableQuests() async {
    try {
      print('Fetching latest available quests...');

      // 먼저 활성화된 퀘스트들을 월별로 정렬해서 가져오기
      final QuerySnapshot snapshot = await _firestore
          .collection('quests')
          .where('isActive', isEqualTo: true)
          .orderBy('monthKey', descending: true)
          .limit(50) // 적절한 수만큼 가져와서 최신 월 찾기
          .get();

      if (snapshot.docs.isEmpty) {
        print('No active quests found in Firebase');
        return [];
      }

      // 가장 최신 월 찾기
      String? latestMonth;
      final Map<String, List<DocumentSnapshot>> questsByMonth = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final monthKey = data['monthKey'] as String?;

        if (monthKey != null) {
          if (latestMonth == null || monthKey.compareTo(latestMonth) > 0) {
            latestMonth = monthKey;
          }

          if (!questsByMonth.containsKey(monthKey)) {
            questsByMonth[monthKey] = [];
          }
          questsByMonth[monthKey]!.add(doc);
        }
      }

      if (latestMonth == null) {
        print('No valid month keys found');
        return [];
      }

      print('Using latest available month: $latestMonth');

      // 최신 월의 퀘스트들 변환
      final latestQuests = questsByMonth[latestMonth]!.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Timestamp 처리
        _processTimestamps(data);

        return Quest.fromJson(data);
      }).toList();

      print('Found ${latestQuests.length} quests for latest month: $latestMonth');
      return latestQuests;
    } catch (e) {
      print('Error fetching latest available quests: $e');
      return [];
    }
  }

  /// Timestamp 필드들을 적절히 처리
  void _processTimestamps(Map<String, dynamic> data) {
    // createdAt 처리
    if (data['createdAt'] is Timestamp) {
      final timestamp = data['createdAt'] as Timestamp;
      data['createdAt'] = timestamp.toDate().toIso8601String();
    }

    // updatedAt 처리
    if (data['updatedAt'] is Timestamp) {
      final timestamp = data['updatedAt'] as Timestamp;
      data['updatedAt'] = timestamp.toDate().toIso8601String();
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
      print('Error getting Firebase quest count: $e');
      return 0;
    }
  }

  /// 메인 동기화 함수
  Future<List<Quest>> syncQuests() async {
    try {
      print('Starting quest synchronization...');

      if (await needsQuestSync()) {
        // 1차: 현재 월 퀘스트 시도
        List<Quest> currentMonthQuests = await fetchCurrentMonthQuests();

        if (currentMonthQuests.isNotEmpty) {
          // 현재 월 퀘스트가 있으면 저장
          await saveQuestsLocally(currentMonthQuests);
          print('Sync completed with current month quests');
          return currentMonthQuests;
        } else {
          print('No current month quests found, trying latest available...');

          // 2차: 최신 월 퀘스트 시도
          List<Quest> latestQuests = await fetchLatestAvailableQuests();

          if (latestQuests.isNotEmpty) {
            await saveQuestsLocally(latestQuests);
            print('Sync completed with latest available quests');
            return latestQuests;
          } else {
            print('No quests found in Firebase');
            return [];
          }
        }
      } else {
        // 동기화 불필요 - 로컬 데이터 사용
        final localQuests = getLocalQuests();
        print('Using local quests (${localQuests.length} quests)');
        return localQuests;
      }
    } catch (e) {
      print('Error syncing quests: $e');
      print('Stack trace: ${StackTrace.current}');

      // 에러 발생시 로컬 데이터 반환
      final localQuests = getLocalQuests();
      print('Returning local quests due to sync error (${localQuests.length} quests)');
      return localQuests;
    }
  }

  /// 특정 월의 퀘스트 가져오기 (테스트용)
  Future<List<Quest>> fetchQuestsForMonth(String monthKey) async {
    try {
      print('Fetching quests for month: $monthKey');

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

      print('Found ${quests.length} quests for month: $monthKey');
      return quests;
    } catch (e) {
      print('Error fetching quests for month $monthKey: $e');
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
      }

      final firebaseCount = await getFirebaseQuestCount();
      print('Firebase Active Quests Count: $firebaseCount');

      final needsSync = await needsQuestSync();
      print('Needs Sync: $needsSync');
      print('========================');
    } catch (e) {
      print('Error printing sync status: $e');
    }
  }

  /// 강제 동기화 (테스트용)
  Future<List<Quest>> forceSyncQuests() async {
    try {
      print('Force syncing quests...');

      // 로컬 데이터 클리어
      await HiveService.clearQuests();
      await HiveService.remove(LAST_QUEST_SYNC_MONTH_KEY);
      await HiveService.remove(QUEST_SYNC_TIME_KEY);

      // 동기화 실행
      return await syncQuests();
    } catch (e) {
      print('Error in force sync: $e');
      return [];
    }
  }
}