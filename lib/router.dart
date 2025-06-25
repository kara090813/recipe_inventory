import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'models/_models.dart';
import 'models/freezed/badge_model.dart' as BadgeModel;
import 'screens/_screens.dart';
import 'status/recipeStatus.dart';

class AppRouter {
  final Recipe? pendingRecipe;
  AppRouter({this.pendingRecipe});

  late final router = GoRouter(
    initialLocation: pendingRecipe != null ? '/recipeInfo' : '/',
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
      // 기존 /recipeInfo 라우트 (호환성 유지)
      GoRoute(
        path: '/recipeInfo',
        builder: (context, state) {
          final Recipe? recipe = state.extra as Recipe? ?? pendingRecipe;
          if (recipe == null) return MainScreen();
          return RecipeInfoScreen(recipe: recipe);
        },
      ),
      // 새로운 /recipeInfo/:recipeId 라우트 (딥링크용)
      GoRoute(
        path: '/recipeInfo/:recipeId',
        builder: (context, state) {
          final recipeId = state.pathParameters['recipeId']!;
          return RecipeInfoScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
          path: '/cookingStart',
          builder: (context, state) {
            if (state.extra is Recipe) {
              return CookingStartScreen(recipe: state.extra as Recipe);
            } else if (state.extra is String) {
              // 레시피 ID를 받는 경우도 처리
              return CookingStartScreen(recipeId: state.extra as String);
            }
            return MainScreen();
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
      GoRoute(
        path: '/quest',
        builder: (context, state) {
          return QuestScreen();
        },
      ),
      GoRoute(
        path: '/badge',
        builder: (context, state) {
          return BadgeCollectionScreen();
        },
      ),
      GoRoute(
        path: '/customRecipe',
        builder: (context, state) {
          return CustomRecipeScreen();
        },
      ),
      GoRoute(
        path: '/customRecipePurchase',
        builder: (context, state) {
          return CustomRecipePurchaseScreen();
        },
      ),
      GoRoute(
        path: '/custom-manage',
        builder: (context, state) {
          return CustomRecipeManageScreen();
        },
      ),
      GoRoute(
        path: '/custom-edit/:recipeId',
        builder: (context, state) {
          final recipeId = state.pathParameters['recipeId']!;
          return CustomRecipeEditScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/cook-complete',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CookCompleteScreen(
            recipe: data['recipe'] as Recipe,
            cookingTime: data['cookingTime'] as int,
            newlyAcquiredBadgeIds: data['newlyAcquiredBadgeIds'] as List<String>?,
            newlyCompletedQuestIds: data['newlyCompletedQuestIds'] as List<String>?,
            interstitialAd: data['interstitialAd'],
            newlyAcquiredBadges: data['newlyAcquiredBadges'] as List<BadgeModel.Badge>?,
          );
        },
      ),
    ],
    // 라우트를 찾을 수 없을 때 메인 화면으로 리다이렉트
    errorBuilder: (context, state) {
      print('라우트를 찾을 수 없음: ${state.uri.path}');
      return MainScreen();
    },
    debugLogDiagnostics: true,
  );
}