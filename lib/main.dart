import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'funcs/_funcs.dart';
import 'models/data.dart';
import 'router.dart';
import 'status/_status.dart';
import 'services/hive_service.dart'; // Hive 서비스 추가
import 'services/migration_service.dart'; // 마이그레이션 서비스 추가
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 (가장 먼저)
  try {
    await HiveService.init();
    print('Hive 초기화 성공');

    // 데이터 마이그레이션 실행
    await MigrationService.migrateToHive();
  } catch (e) {
    print('Hive 초기화 또는 마이그레이션 실패: $e');
  }


  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 성공');
  } catch (e) {
    print('Firebase 초기화 실패: $e');
  }

  // MobileAds 초기화
  try {
    await MobileAds.instance.initialize();
    print('MobileAds 초기화 성공');
  } catch (e) {
    print('MobileAds 초기화 실패: $e');
  }


  runApp(RecipeInventory());
}

class RecipeInventory extends StatefulWidget {
  const RecipeInventory({Key? key}) : super(key: key);

  @override
  State<RecipeInventory> createState() => _RecipeInventoryState();
}

class _RecipeInventoryState extends State<RecipeInventory> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  // ========================================
// 2. lib/main.dart 수정 (_setupQuestCallbacks 메서드)
// ========================================

  void _setupStatusCallbacks(BuildContext context) {
    try {
      final questStatus = Provider.of<QuestStatus>(context, listen: false);
      final badgeStatus = Provider.of<BadgeStatus>(context, listen: false); // 🆕 추가
      final userStatus = Provider.of<UserStatus>(context, listen: false);
      final foodStatus = Provider.of<FoodStatus>(context, listen: false);
      final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);

      // 🎯 퀘스트 업데이트 콜백 설정
      userStatus.setQuestUpdateCallback(() async {
        await questStatus.updateQuestProgress(userStatus, foodStatus, recipeStatus);
      });

      foodStatus.setQuestUpdateCallback(() async {
        await questStatus.updateQuestProgress(userStatus, foodStatus, recipeStatus);
      });

      recipeStatus.setQuestUpdateCallback(() async {
        await questStatus.updateQuestProgress(userStatus, foodStatus, recipeStatus);
      });

      // 🆕 뱃지 업데이트 콜백 설정
      userStatus.setBadgeUpdateCallback(() async {
        await badgeStatus.updateBadgeProgress(userStatus, foodStatus, recipeStatus);
      });

      foodStatus.setBadgeUpdateCallback(() async {
        await badgeStatus.updateBadgeProgress(userStatus, foodStatus, recipeStatus);
      });

      recipeStatus.setBadgeUpdateCallback(() async {
        await badgeStatus.updateBadgeProgress(userStatus, foodStatus, recipeStatus);
      });

      // 🆕 뱃지 → UserStatus 프로필 업데이트 콜백 설정
      badgeStatus.setUserProfileUpdateCallback((String? badgeId) async {
        await userStatus.updateMainBadgeProfile(badgeId);
      });

      // 🆕 초기 뱃지 진행도 업데이트 실행
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print("⏰ Waiting for all Status to initialize...");

          // 모든 Status의 초기화가 완료될 때까지 대기 (최대 5초)
          int maxWaitTime = 50; // 5초 (100ms * 50)
          int waitCount = 0;

          while (waitCount < maxWaitTime) {
            // Status들이 로딩 중이 아니고, 기본 데이터가 있는지 확인
            if (!questStatus.isLoading &&
                !badgeStatus.isLoading &&
                !recipeStatus.isLoading) {
              break;
            }

            await Future.delayed(Duration(milliseconds: 100));
            waitCount++;
          }

          print("✅ Status initialization wait completed. Starting initial progress update...");

          // 퀘스트와 뱃지 진행도 모두 업데이트 실행 (초기화 시에는 알림 억제)
          await questStatus.updateQuestProgress(userStatus, foodStatus, recipeStatus);
          await badgeStatus.updateBadgeProgress(userStatus, foodStatus, recipeStatus, suppressNotifications: true);

        } catch (e) {
          print("❌ Error in initial progress setup: $e");
        }
      });

      print('✅ Status callbacks successfully set up');
    } catch (e) {
      print('❌ Error setting up status callbacks: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(430, 932),
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            Provider<AppRouter>(lazy: false, create: (context) => AppRouter()),
            ChangeNotifierProvider<FoodStatus>(create: (context) => FoodStatus()),
            ChangeNotifierProvider(create: (context) => SelectedFoodProvider()),
            ChangeNotifierProvider(create: (context) => FilterStatus()),
            ChangeNotifierProvider<UserStatus>(create: (context) => UserStatus()),
            ChangeNotifierProvider(create: (_) => TabStatus()),
            ChangeNotifierProvider<RecipeStatus>(create: (context) => RecipeStatus()),
            ChangeNotifierProvider<QuestStatus>(create: (context) => QuestStatus()),
            ChangeNotifierProvider<BadgeStatus>(create: (context) => BadgeStatus()),
          ],
          child: Builder(
            builder: (BuildContext context) {
              final router = Provider.of<AppRouter>(context, listen: false).router;

              // Go Router 인스턴스를 전역 변수에 할당

              // 앱이 빌드된 후 퀘스트 콜백 설정
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // 🎯 퀘스트 콜백 설정
                _setupStatusCallbacks(context);
              });

              return MaterialApp.router(
                routerDelegate: router.routerDelegate,
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                theme: AppTheme.defaultTheme,
              );
            },
          ),
        );
      },
    );
  }
}