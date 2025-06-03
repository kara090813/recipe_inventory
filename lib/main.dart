import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'funcs/_funcs.dart';
import 'models/data.dart';
import 'router.dart';
import 'status/_status.dart';
import 'package:flutter/services.dart';

// AppLinks 인스턴스
late AppLinks _appLinks;

// 레시피 알림 예약 함수
Future<void> scheduleRecipeNotification() async {
  try {
    final recipeStatus = RecipeStatus();
    await recipeStatus.refreshRecipes();

    final foodStatus = FoodStatus();
    await foodStatus.loadFoods();

    final userStatus = UserStatus();
    await userStatus.loadUserStatus();

    if (recipeStatus.recipes.isEmpty) {
      print('레시피가 없어 알림을 예약할 수 없습니다.');
      return;
    }

    // 추천 레시피 중 랜덤하게 하나 선택 (상위 5개 중에서)
    final recommendedRecipe = recipeStatus.getRandomRecommendedRecipe(foodStatus, userStatus, 5);

    // 매일 저녁 6시 알림 예약
    await NotificationService().scheduleDailyRecipeNotification(recipe: recommendedRecipe);
  } catch (e) {
    print('레시피 알림 예약 실패: $e');
  }
}

// 테스트용 함수: 20초 후 레시피 알림 예약
Future<void> scheduleTestRecipeNotificationIn20Seconds() async {
  try {
    final recipeStatus = RecipeStatus();
    await recipeStatus.refreshRecipes();

    final foodStatus = FoodStatus();
    await foodStatus.loadFoods();

    final userStatus = UserStatus();
    await userStatus.loadUserStatus();

    if (recipeStatus.recipes.isEmpty) {
      print('레시피가 없어 알림을 예약할 수 없습니다.');
      return;
    }

    // 추천 레시피 중 랜덤하게 하나 선택 (상위 5개 중에서)
    final recommendedRecipe = recipeStatus.getRandomRecommendedRecipe(foodStatus, userStatus, 5);

    // 20초 후 알림 예약
    await NotificationService().scheduleTestRecipeNotification(recipe: recommendedRecipe);
  } catch (e) {
    print('레시피 테스트 알림 예약 실패: $e');
    rethrow; // 에러를 호출자에게 전달
  }
}

// 딥링크 처리 함수
void handleDeepLink(Uri? uri, BuildContext? context) {
  if (uri == null) return;

  print('딥링크 수신: $uri');

  // /recipeInfo/{recipeId} 형식 처리
  final pathSegments = uri.pathSegments;
  if (pathSegments.length >= 2 && pathSegments[0] == 'recipeInfo') {
    final recipeId = pathSegments[1];
    print('레시피 ID로 이동: $recipeId');

    if (goRouterNavigator != null) {
      // 홈으로 먼저 이동
      goRouterNavigator!.go('/');

      // 약간의 지연 후 레시피 페이지로 이동
      Future.delayed(Duration(milliseconds: 300), () {
        goRouterNavigator!.go('/recipeInfo/$recipeId');
      });
    } else {
      print('라우터가 초기화되지 않았습니다');
      // 알림 서비스에 ID 저장
      NotificationService().saveLastNotificationRecipeId(recipeId);
    }
  }
}

// 딥링크 리스너 구독
StreamSubscription<Uri>? _linkSubscription;

// 초기화 및 딥링크 설정
Future<void> initDeepLinks() async {
  try {
    // AppLinks 초기화
    _appLinks = AppLinks();

    // 첫 실행시 딥링크 확인
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      print('초기 앱 링크: $appLink');
      handleDeepLink(appLink, null);
    }

    // 딥링크 리스너 등록
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('스트림에서 앱 링크 수신: $uri');
      handleDeepLink(uri, null);
    }, onError: (e) => print('딥링크 스트림 에러: $e'));

    // 저장된 알림 ID 확인
    final recipeId = await NotificationService().getLastNotificationRecipeId();
    if (recipeId != null && recipeId.isNotEmpty) {
      print('초기화 시 저장된 레시피 ID: $recipeId');

      // 딜레이 후 라우터 확인 (앱 초기화 완료 후)
      Future.delayed(Duration(milliseconds: 500), () {
        if (goRouterNavigator != null) {
          goRouterNavigator!.go('/');
          Future.delayed(Duration(milliseconds: 300), () {
            goRouterNavigator!.go('/recipeInfo/$recipeId');
          });
        }
      });
    }
  } on PlatformException catch (e) {
    print('딥링크 초기화 에러: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  try {
    await NotificationService().init();
    print('알림 서비스 초기화 성공');
  } catch (e) {
    print('알림 서비스 초기화 실패: $e');
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

  // 매일 저녁 6시 레시피 알림 예약
  await scheduleRecipeNotification();

  // 딥링크 초기화
  await initDeepLinks();

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
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 저장된 알림 ID 확인
      _checkPendingNotification();
    }
  }

  Future<void> _checkPendingNotification() async {
    try {
      final recipeId = await NotificationService().getLastNotificationRecipeId();
      if (recipeId != null && recipeId.isNotEmpty) {
        print('대기 중인 알림 레시피 ID를 로드합니다: $recipeId');

        if (goRouterNavigator != null && mounted) {
          // 홈 화면으로 이동
          goRouterNavigator!.go('/');

          // 탭 인덱스 설정
          Provider.of<TabStatus>(context, listen: false).setIndex(0);

          // 약간의 지연 후 레시피 페이지로 이동
          Future.delayed(Duration(milliseconds: 300), () {
            if (goRouterNavigator != null && mounted) {
              goRouterNavigator!.go('/recipeInfo/$recipeId');
            }
          });
        }
      }
    } catch (e) {
      print('대기 중인 알림 처리 중 오류: $e');
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
            ChangeNotifierProvider(create: (context) => UserStatus()),
            ChangeNotifierProvider(create: (_) => TabStatus()),
            ChangeNotifierProvider(create: (context) => RecipeStatus()),
          ],
          child: Builder(
            builder: (BuildContext context) {
              final router = Provider.of<AppRouter>(context, listen: false).router;

              // Go Router 인스턴스를 전역 변수에 할당
              goRouterNavigator = router;

              // 앱이 빌드된 후 초기 알림 확인
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkPendingNotification();
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