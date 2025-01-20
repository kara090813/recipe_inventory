import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'models/_models.dart';
import 'screens/_screens.dart';

class AppRouter {
  late final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return MainScreen();
        },
      ),
      GoRoute(
          path: '/foodAdd',
          builder: (context, state) {
            return FoodAddScreen();
          },
          routes: [
            GoRoute(
                path: 'refrigeratorScan',
                builder: (context, state) {
                  return RefrigeratorScanScreen();
                }),
            GoRoute(
                path: 'receiptScan',
                builder: (context, state) {
                  return ReceiptScanScreen();
                }),
          ]),
      GoRoute(
        path: '/foodDel',
        builder: (context, state) {
          return FoodDelScreen();
        },
      ),
      GoRoute(
          path: '/foodSearch',
          builder: (context, state) {
            return FoodSearchScreen();
          }),
      GoRoute(
          path: '/recipeFilter',
          builder: (context, state) {
            return RecipeFilterScreen();
          }),
      GoRoute(
          path: '/recipeInfo',
          builder: (context, state) {
            return RecipeInfoScreen(recipe: state.extra as Recipe);
          }),
      GoRoute(
          path: '/cookingStart',
          builder: (context, state) {
            return CookingStartScreen(recipe: state.extra as Recipe);
          }),
      GoRoute(
          path: '/cookHistory',
          builder: (context, state) {
            return CookHistoryScreen();
          }),
      GoRoute(
          path: '/profileSet',
          builder: (context, state) {
            return ProfileSetScreen();
          }),
      GoRoute(
        path: '/recipeWishList',
        builder: (context, state) {
          return RecipeWishListScreen();
        },
      ),
      GoRoute(
        path: '/customFood',
        builder: (context, state) {
          return CustomFoodScreen();
        },
      ),

    ],
    debugLogDiagnostics: true,
  );
}
