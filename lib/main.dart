import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'models/data.dart';
import 'router.dart';
import 'status/_status.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 먼저 Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // MobileAds 초기화를 try-catch로 감싸기
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    print('Failed to initialize MobileAds: $e');
  }

  runApp(RecipeInventory());
}

class RecipeInventory extends StatelessWidget {
  const RecipeInventory({Key? key}) : super(key: key);

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
