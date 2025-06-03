import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../status/recipeStatus.dart';

// 전역 Go Router 객체
GoRouter? goRouterNavigator;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 마지막으로 알림을 통해 접근한 레시피 ID 저장
  Future<void> saveLastNotificationRecipeId(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_notification_recipe_id', recipeId);
      print('마지막 알림 레시피 ID 저장: $recipeId');
    } catch (e) {
      print('알림 레시피 ID 저장 실패: $e');
    }
  }

  // 마지막 알림 레시피 ID 불러오기 (사용 후 삭제)
  Future<String?> getLastNotificationRecipeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipeId = prefs.getString('last_notification_recipe_id');
      if (recipeId != null && recipeId.isNotEmpty) {
        // 사용 후 삭제
        await prefs.remove('last_notification_recipe_id');
        print('마지막 알림 레시피 ID 불러옴: $recipeId');
        return recipeId;
      }
    } catch (e) {
      print('알림 레시피 ID 불러오기 실패: $e');
    }
    return null;
  }

  // 알림 처리를 위한 딥링크 URI 생성
  String _buildDeepLinkUri(String recipeId) {
    // 앱 스킴 사용
    return 'recipeapp://recipe/recipeInfo/$recipeId';
  }

  Future<void> init() async {
    try {
      // timezone 초기화
      tz_data.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android 설정
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 설정
      final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        // iOS에서 포그라운드에서도 알림 표시
        notificationCategories: [
          DarwinNotificationCategory(
            'recipeCategory',
            actions: [
              DarwinNotificationAction.plain(
                'view',
                '보기',
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
          ),
        ],
      );

      // 초기화 설정
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // 알림 플러그인 초기화
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) async {
          // 알림 탭 시 콜백
          print('알림 클릭됨: ${details.payload}');

          // 레시피 ID가 포함된 경우
          if (details.payload != null && details.payload!.isNotEmpty) {
            try {
              final recipeId = details.payload!;

              // 레시피 ID 저장 (앱이 inactive 상태일 때 사용)
              await saveLastNotificationRecipeId(recipeId);

              // 딥링크 URI 생성
              final deepLinkUri = _buildDeepLinkUri(recipeId);
              print('생성된 딥링크 URI: $deepLinkUri');

              // 앱이 실행 중일 때만 라우팅 시도
              if (goRouterNavigator != null) {
                // 홈으로 이동 후 레시피 상세 페이지로 이동
                goRouterNavigator!.go('/');

                // 약간의 지연 후 레시피 상세 페이지로 이동
                Future.delayed(Duration(milliseconds: 300), () {
                  goRouterNavigator!.go('/recipeInfo/$recipeId');
                });
              } else {
                // 앱이 실행 중이 아닐 때는 ID 저장
                print('라우터가 초기화되지 않음, 앱 시작 시 딥링크를 처리할 예정');
              }
            } catch (e) {
              print('알림 처리 오류: $e');
            }
          }
        },
      );

      // 알림 권한 요청 (iOS)
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 알림 권한 요청 (Android)
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Android인 경우 정확한 알람 권한 확인 및 요청
      if (Platform.isAndroid) {
        await requestExactAlarmPermission();
      }
    } catch (e) {
      print('알림 서비스 초기화 중 오류: $e');
    }
  }

  // 정확한 알람 권한 요청 (Android)
  Future<bool> requestExactAlarmPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final hasPermission = await androidPlugin.requestExactAlarmsPermission();
          if (hasPermission == null || !hasPermission) {
            print('정확한 알람 권한이 없습니다.');
            return false;
          }
          return true;
        }
      }
      return true; // iOS는 항상 true
    } catch (e) {
      print('정확한 알람 권한 요청 중 오류: $e');
      return false;
    }
  }

  // 테스트용: 20초 후 레시피 추천 알림
  Future<void> scheduleTestRecipeNotification({
    required Recipe recipe,
  }) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: 20));

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'recipe_test_channel_id',
        '레시피 테스트 알림',
        channelDescription: '테스트용 레시피 알림',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.call, // 중요 알림으로 표시
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'recipeCategory',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // 레시피 정보 로그 출력
      print('테스트 알림 예약: ${recipe.title} (ID: ${recipe.id})');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        888, // 고유 ID (테스트용)
        '추천 레시피 알림 테스트',
        '${recipe.title} - 지금 바로 만들어보세요!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: _getScheduleMode(),
        payload: recipe.id, // 레시피 ID만 페이로드로 전달
        matchDateTimeComponents: null, // 반복 알림이 아님
      );

      print('테스트 알림 예약 완료: ${recipe.title} (${scheduledDate.toString()})');
    } catch (e) {
      print('레시피 테스트 알림 예약 실패: $e');
      rethrow; // 에러를 호출자에게 전달
    }
  }

  // 매일 저녁 6시 레시피 추천 알림 예약 기능
  Future<void> scheduleDailyRecipeNotification({
    required Recipe recipe,
    bool replace = true,
  }) async {
    try {
      if (replace) {
        // 기존 레시피 알림 취소
        await cancelNotification(999); // 레시피 알림의 고유 ID로 999 사용
      }

      final tz.TZDateTime scheduledDate = _nextInstanceOf6PM();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'recipe_daily_channel_id',
        '오늘의 레시피 알림',
        channelDescription: '매일 저녁 추천 레시피 알림',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.call, // 중요 알림으로 표시
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'recipeCategory',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // 레시피 정보 로그 출력
      print('매일 알림 예약: ${recipe.title} (ID: ${recipe.id})');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999, // 고유 ID
        '오늘의 추천 레시피',
        '${recipe.title} - 지금 바로 만들어보세요!',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: _getScheduleMode(),
        payload: recipe.id, // 레시피 ID만 페이로드로 전달
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      );

      print('매일 저녁 6시 레시피 알림 예약 완료: ${recipe.title}');
    } catch (e) {
      print('매일 레시피 알림 예약 실패: $e');
    }
  }

  // Android 스케줄 모드 설정 헬퍼
  AndroidScheduleMode _getScheduleMode() {
    if (Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.exactAllowWhileIdle; // iOS는 사용되지 않음
  }

  // 다음 오후 6시 시간 계산
  tz.TZDateTime _nextInstanceOf6PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 오후 6시
      0, // 0분
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 특정 ID의 알림 취소
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}