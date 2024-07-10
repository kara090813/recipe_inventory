import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'router.dart';

// import 'status/_status.dart';
// import 'app_theme.dart';

void main() {
  runApp(RecipeInventory());
}

class RecipeInventory extends StatelessWidget {
  const RecipeInventory({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(430, 932),
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [Provider<AppRouter>(lazy: false, create: (context) => AppRouter())],
          child: Builder(
            builder: (BuildContext context) {
              final router = Provider.of<AppRouter>(context, listen: false).router;
              return MaterialApp.router(
                routerDelegate: router.routerDelegate,
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
              );
            },
          ),
        );
      },
    );
  }
}
