import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:in_app_review/in_app_review.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

// youtube_player_iframe: ^5.2.1 (pubspec.yaml 추가 후, 아래 임포트)
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/_models.dart';
import '../models/freezed/badge_model.dart' as BadgeModel;
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import 'cook_complete_screen.dart';

class CookingStartScreen extends StatefulWidget {
  final Recipe? recipe;
  final String? recipeId;

  const CookingStartScreen({Key? key, this.recipe, this.recipeId}) : super(key: key);

  @override
  State<CookingStartScreen> createState() => _CookingStartScreenState();
}

class _CookingStartScreenState extends State<CookingStartScreen> with TickerProviderStateMixin {
  Recipe? _loadedRecipe;
  bool _isLoading = false;
  String? _error;

  /// (5.x) YoutubePlayerController
  late YoutubePlayerController _youtubeController;
  
  /// 조리 시작 시간
  DateTime? _cookingStartTime;
  
  /// 애니메이션 컨트롤러들
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _shimmerAnimation;
  
  /// 타이머들
  Timer? _nudgeTimer;
  Timer? _cookingDurationTimer;
  
  /// 요리 진행 상태
  int _cookingMinutes = 0;
  bool _showMotivationalMessage = false;
  
  /// 메시지 목록
  final List<String> _motivationalMessages = [
    "🍳 요리가 거의 완성되어 가요!",
    "👨‍🍳 맛있는 요리가 완성되었나요?",
    "✨ 완료 버튼을 눌러 보상을 받아보세요!",
    "🎁 새로운 뱃지와 퀘스트가 기다리고 있어요!",
    "🏆 요리 완료로 경험치를 얻어보세요!",
  ];
  

  /// Interstitial 광고 ID
  final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1961572115316398/5389842917' // Android 테스트용 ID
      : 'ca-app-pub-1961572115316398/4302894479'; // iOS 테스트용 ID
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _cookingStartTime = DateTime.now(); // 조리 시작 시간 기록
    _initializeAnimations();
    _startCookingTimer();
    _loadRecipe();
  }
  
  void _initializeAnimations() {
    // 맥박 애니메이션 (느린 펄스)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // 글로우 애니메이션 (빛나는 효과)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // 바운스 애니메이션
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    // 시머 애니메이션 (반짝임)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: const Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // 자동 애니메이션 시작
    _startAutoAnimations();
  }
  
  void _startAutoAnimations() {
    // 맥박 애니메이션 반복
    _pulseController.repeat(reverse: true);
    
    // 글로우 애니메이션 반복
    _glowController.repeat(reverse: true);
    
    // 넛지 타이머 설정 (15초마다)
    _nudgeTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _triggerAttentionAnimation();
    });
    
  }
  
  void _startCookingTimer() {
    _cookingDurationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _cookingMinutes++;
      });
      
      // 10분 후부터 동기부여 메시지 표시
      if (_cookingMinutes >= 10 && _cookingMinutes % 5 == 0) {
        _showMotivationalNudge();
      }
    });
  }
  
  void _triggerAttentionAnimation() {
    if (mounted) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
      
      _shimmerController.forward().then((_) {
        _shimmerController.reset();
      });
    }
  }
  
  void _showMotivationalNudge() {
    if (mounted) {
      setState(() {
        _showMotivationalMessage = true;
      });
      
      _triggerAttentionAnimation();
      
      // 5초 후 메시지 숨김
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showMotivationalMessage = false;
          });
        }
      });
    }
  }
  

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 직접 Recipe 객체가 전달된 경우
      if (widget.recipe != null) {
        setState(() {
          _loadedRecipe = widget.recipe;
          _isLoading = false;
        });
        _initializeYoutubePlayer();
        _loadInterstitialAd();
        return;
      }

      // recipeId가 전달된 경우
      if (widget.recipeId != null && widget.recipeId!.isNotEmpty) {
        final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
        final recipe = recipeStatus.findRecipeById(widget.recipeId!);

        if (recipe != null) {
          setState(() {
            _loadedRecipe = recipe;
            _isLoading = false;
          });
          _initializeYoutubePlayer();
          _loadInterstitialAd();
        } else {
          setState(() {
            _error = '레시피를 찾을 수 없습니다: ${widget.recipeId}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = '레시피 정보가 없습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '레시피 로드 중 오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  // 유튜브 링크가 유효한지 확인하는 메서드
  bool _hasValidYouTubeLink() {
    if (_loadedRecipe == null) return false;
    
    // 1. recipe.link 확인 (기본 레시피용)
    if (_loadedRecipe!.link.isNotEmpty && 
        _loadedRecipe!.link != '' && 
        !_loadedRecipe!.link.contains('null') &&
        Uri.tryParse(_loadedRecipe!.link) != null) {
      return true;
    }
    
    // 2. recipe.youtubeUrl 확인 (커스텀 레시피용)
    if (_loadedRecipe!.youtubeUrl.isNotEmpty && 
        _loadedRecipe!.youtubeUrl != '' && 
        !_loadedRecipe!.youtubeUrl.contains('null') &&
        Uri.tryParse(_loadedRecipe!.youtubeUrl) != null) {
      return true;
    }
    
    return false;
  }

  // 유튜브 URL을 가져오는 메서드
  String _getYouTubeUrl() {
    if (_loadedRecipe == null) return '';
    
    // 커스텀 레시피의 경우 youtubeUrl 우선 사용
    if (_loadedRecipe!.isCustom && _loadedRecipe!.youtubeUrl.isNotEmpty) {
      return _loadedRecipe!.youtubeUrl;
    }
    
    // 기본 레시피 또는 커스텀 레시피에 youtubeUrl이 없는 경우 link 사용
    return _loadedRecipe!.link;
  }

  void _initializeYoutubePlayer() {
    if (_loadedRecipe == null) return;

    // 링크에서 videoId 추출
    final videoId = YoutubePlayerController.convertUrlToId(_loadedRecipe!.link) ?? '';

    // (5.x) YoutubePlayerController.fromVideoId(...) 사용
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  /// 광고 로드
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> _showIngredientRemovalDialog(BuildContext mainContext, Recipe recipe) async {
    final matchedIngredients = classifyIngredients(recipe, Provider.of<FoodStatus>(mainContext, listen: false).userFood);
    final availableIngredients = matchedIngredients['available'] ?? [];

    if (availableIngredients.isEmpty) {
      _checkCookCountAndNavigate(mainContext);
      return;
    }

    return showDialog<void>(
      context: mainContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ChangeNotifierProvider(
          create: (_) => SelectedFoodProvider(),
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal:20.w,vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '소진한 식재료가 있나요?',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D674B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '클릭하여 선택하기',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF707070),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(dialogContext).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: availableIngredients.map((food) =>
                            Consumer<SelectedFoodProvider>(
                              builder: (context, provider, child) {
                                final isSelected = provider.isSelected(food);
                                return GestureDetector(
                                  onTap: () => provider.toggleFood(food),
                                  child: Container(
                                    width: (MediaQuery.of(dialogContext).size.width - 80.w) / 3,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFFFFF3E6) : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? Color(0xFFFF8B27) : Color(0xFFE4E4E4),
                                      ),
                                      borderRadius: BorderRadius.circular(10.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1), // 그림자 색상 (투명도 조절)
                                          spreadRadius: 1, // 그림자 퍼짐 정도
                                          blurRadius: 4, // 그림자 흐림 정도
                                          offset: Offset(0, 1), // 그림자 위치 (x, y)
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(8.w),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          food.img,
                                          width: 50.w,
                                          height: 50.w,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          food.name,
                                          style: TextStyle(fontSize: 12.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Consumer<SelectedFoodProvider>(
                    builder: (context, provider, child) => Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _checkCookCountAndNavigate(mainContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5E3009),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              '건너뛰기',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (provider.selectedFoods.isNotEmpty) {
                                // 소진한 식재료 처리를 위한 매칭 로직 적용
                                final foodStatus = Provider.of<FoodStatus>(mainContext, listen: false);
                                final userFoodList = foodStatus.userFood;

                                // 실제 삭제할 사용자 식재료 목록
                                List<Food> actualFoodsToRemove = [];

                                // 선택된 각 식재료에 대해
                                for (var selectedFood in provider.selectedFoods) {
                                  // 사용자의 실제 식재료 중에서 매칭되는 것 찾기
                                  for (var userFood in userFoodList) {
                                    if (userFood.name == selectedFood.name ||
                                        isIngredientMatched(userFood.name, selectedFood.name) ||
                                        userFood.similarNames.any((name) => isIngredientMatched(name, selectedFood.name))) {
                                      actualFoodsToRemove.add(userFood);
                                      break;  // 한 번 매칭되면 다음 선택된 식재료로 이동
                                    }
                                  }
                                }

                                // 찾은 실제 사용자 식재료 삭제
                                if (actualFoodsToRemove.isNotEmpty) {
                                  foodStatus.removeFoods(actualFoodsToRemove);
                                }
                              }
                              Navigator.pop(dialogContext);
                              _checkCookCountAndNavigate(mainContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF8B27),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              '삭제하기(${provider.selectedFoods.length}개)',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h,)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 요리 횟수를 확인하고 적절한 액션 수행 (광고 또는 리뷰 요청)
  Future<void> _checkCookCountAndNavigate(BuildContext context) async {
    final userStatus = Provider.of<UserStatus>(context, listen: false);
    final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
    final foodStatus = Provider.of<FoodStatus>(context, listen: false);
    final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
    final questStatus = Provider.of<QuestStatus>(context, listen: false);
    
    // 이전 세션 새 뱃지/퀘스트 목록 초기화
    badgeStatus.clearCurrentSessionNewBadges();
    questStatus.clearCurrentSessionNewQuests();
    
    userStatus.endCooking(_loadedRecipe!);
    
    // 뱃지 진행도 업데이트 (팝업 표시는 하지 않음)
    await badgeStatus.updateBadgeProgress(userStatus, foodStatus, recipeStatus);
    
    // 퀘스트 진행도 업데이트
    await questStatus.updateQuestProgress(userStatus, foodStatus, recipeStatus);
    
    final cookCount = userStatus.cookingHistory.length;

    final prefs = await SharedPreferences.getInstance();
    final hasReviewed = prefs.getBool('has_reviewed') ?? false;

    final shouldRequestReview = !hasReviewed &&
        (cookCount == 3 || ((cookCount - 3) % 5 == 0 && cookCount > 3));

    if (shouldRequestReview) {
      _showPreReviewNoticeDialog(context, cookCount);
    } else {
      _navigateToCompleteScreen(context);
    }
  }



  /// 리뷰 요청 다이얼로그
  void _showPreReviewNoticeDialog(BuildContext context, int cookCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              Image.asset(
                'assets/imgs/items/cookLoading.png',
                width: 80.w,
                height: 80.w,
              ),
              SizedBox(height: 20.h),
              Text(
                '냉장고 털이 어떠셨나요?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7D674B),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '앱을 자주 사용해주셔서\n정말 감사합니다!\n간단한 평가를 남겨주시면 \n저희에게 큰 도움이 됩니다 🙏',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF707070),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToCompleteScreen(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8E8E8),
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        '다음에 하기',
                        style: TextStyle(
                          color: const Color(0xFF7D674B),
                          fontFamily: 'Mapo',
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // 다이얼로그 닫기
                        final inAppReview = InAppReview.instance;
                        final prefs = await SharedPreferences.getInstance();

                        try {
                          if (await inAppReview.isAvailable()) {
                            await inAppReview.requestReview();
                            await prefs.setBool('has_reviewed', true);
                          } else {
                            final storeUrl = Platform.isAndroid
                                ? Uri.parse('https://play.google.com/store/apps/details?id=net.lamoss.recipe_inventory')
                                : Uri.parse('https://apps.apple.com/app/id6740774474?action=write-review');

                            if (await canLaunchUrl(storeUrl)) {
                              await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
                              await prefs.setBool('has_reviewed', true);
                            }
                          }
                        } catch (e) {
                          debugPrint('리뷰 요청 실패: $e');
                        }

                        _navigateToCompleteScreen(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8B27),
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        '리뷰 남기기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Mapo',
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  // 홈으로 이동하는 함수
  void _navigateToHome(BuildContext context) {
    if (!mounted) return;
    // TabStatus 변경
    Provider.of<TabStatus>(context, listen: false).setIndex(4);
    // 네비게이션
    context.go('/');
  }

  /// 완료 화면으로 이동 (광고 없이)
  void _navigateToCompleteScreen(BuildContext context) {
    if (!mounted) return;
    
    // 실제 조리 시간 계산 (분 단위)
    final cookingTime = _calculateCookingTimeInMinutes();
    
    // 이번 세션에서 새로 획득한 뱃지와 퀘스트 정보 가져오기
    final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
    final questStatus = Provider.of<QuestStatus>(context, listen: false);
    final newBadgeIds = badgeStatus.getCurrentSessionNewBadges();
    final newQuests = questStatus.getCurrentSessionNewQuests();
    
    // 뱃지 ID로부터 실제 뱃지 객체들 가져오기
    final newBadgeObjects = newBadgeIds
        .map((id) => badgeStatus.getBadgeById(id))
        .where((badge) => badge != null)
        .cast<BadgeModel.Badge>()
        .toList();
    
    print('🎯 NavigateToCompleteScreen - newBadgeIds: $newBadgeIds');
    print('🎯 NavigateToCompleteScreen - newBadgeObjects: ${newBadgeObjects.length}');
    
    // GoRouter를 사용하여 완료 화면으로 이동
    context.go('/cook-complete', extra: {
      'recipe': _loadedRecipe!,
      'cookingTime': cookingTime,
      'newlyAcquiredBadgeIds': newBadgeIds,
      'newlyCompletedQuestIds': newQuests,
      'interstitialAd': _interstitialAd, // 광고 객체 전달
      'newlyAcquiredBadges': newBadgeObjects, // 실제 뱃지 객체들 전달
    });
  }

  /// 실제 조리 시간 계산 (분 단위)
  int _calculateCookingTimeInMinutes() {
    if (_cookingStartTime == null) {
      print('⚠️ 조리 시작 시간이 기록되지 않음, 기본값 30분 반환');
      return 30; // 기본값
    }
    
    final now = DateTime.now();
    final duration = now.difference(_cookingStartTime!);
    final minutes = duration.inMinutes;
    
    // 최소 1분, 최대 480분(8시간)으로 제한
    final clampedMinutes = minutes.clamp(1, 480);
    
    print('🕒 조리 시간: ${duration.inHours}시간 ${duration.inMinutes % 60}분 (총 ${clampedMinutes}분)');
    
    return clampedMinutes;
  }

  /// 요리 종료 로직
  void _endCooking(BuildContext context) {
    if (_loadedRecipe == null) return;
    _showIngredientRemovalDialog(context, _loadedRecipe!);
  }
  
  
  /// 향상된 완료 버튼 위젯
  Widget _buildEnhancedFinishButton() {
    return Column(
      children: [
        // 동기부여 메시지 (조건부 표시)
        if (_showMotivationalMessage)
          AnimatedOpacity(
            opacity: _showMotivationalMessage ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFE4B5).withOpacity(0.9),
                    const Color(0xFFFFD700).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber[700],
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _motivationalMessages[Random().nextInt(_motivationalMessages.length)],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B4513),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.star,
                    color: Colors.amber[700],
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),
        
        // 메인 완료 버튼
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _glowAnimation, _bounceAnimation, _shimmerAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * _bounceAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8B27).withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 20,
                      spreadRadius: _glowAnimation.value * 4,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      // 기본 버튼
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF8B27),
                              const Color(0xFFFF6B00),
                              const Color(0xFFE55100),
                            ],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await _showExitConfirmationDialog(context);
                              if (result == null) {
                                return;
                              }
                              if (result) {
                                _endCooking(context);
                              } else {
                                context.pop();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 18.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 24.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    '요리 완료하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Mapo',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      '🎁',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // 시머 효과
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_shimmerAnimation.value.dx * 200, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // 보조 설명 텍스트
        SizedBox(height: 12.h),
        Text(
          '눌러야 퀘스트와 뱃지의 진행도가 체크되고 기록됩니다! 📊',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF8B4513),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 유튜브 플레이어 위젯
  Widget _buildYoutubePlayer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 3,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          // (5.x) YoutubePlayer 위젯 사용
          child: YoutubePlayer(
            controller: _youtubeController,
            // 추가: aspectRatio 지정해도 되지만,
            // 이미 바깥에 AspectRatio가 있어서 생략 가능.
          ),
        ),
      ),
    );
  }

  Widget _buildIOSVideoSection(Recipe recipe) {
    return Column(
      children: [
        // 썸네일 이미지
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: RecipeThumbnailWidget(
            recipe: recipe,
            width: double.infinity,
            height: 200.h,
            borderRadius: BorderRadius.circular(12.r),
            fit: BoxFit.cover,
            highQuality: true,
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    // (5.x) iFrame 컨트롤러는 close() 사용
    if (_loadedRecipe != null) {
      _youtubeController.close();
    }
    
    // 애니메이션 컨트롤러들 정리
    _pulseController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    
    // 타이머들 정리
    _nudgeTimer?.cancel();
    _cookingDurationTimer?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이거나 에러가 있는 경우
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8B27),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: ScaffoldPaddingWidget(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BackButtonWidget(context),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadedRecipe == null) {
      Future.microtask(() => context.go('/'));
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8B27),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final result = await _showExitConfirmationDialog(context);
        if (result == null) {
          return;
        }
        if (result) {
          _endCooking(context);
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // 상단 헤더 부분
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.h,
                            vertical: 10.h,
                          ),
                          color: Colors.transparent,
                          child: Image.asset(
                            'assets/imgs/icons/back_arrow.png',
                            width: 26.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.h),
                      Expanded(
                        child: Text(
                          '요리 시작',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7D674B),
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 4.h),
                          TextButton(
                            onPressed: () async {
                              final result = await _showExitConfirmationDialog(context);
                              if (result == null) {
                                return;
                              }
                              if (result) {
                                _endCooking(context);
                              } else {
                                context.pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              backgroundColor: const Color(0xFFD64545),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '요리 종료',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  DottedBarWidget(),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
            // 본문 스크롤 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isTablet(context)) SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                      child: Column(
                        children: [
                          // 유튜브 플레이어
                          if (Platform.isAndroid)
                            _buildYoutubePlayer()
                          else if (Platform.isIOS)
                            _buildIOSVideoSection(_loadedRecipe!),
                          SizedBox(height: 10.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: -1,
                                  child: Container(
                                    height: 14,
                                    color: const Color(0xFFFFD8A8),
                                  ),
                                ),
                                Text(
                                  _loadedRecipe!.title,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // 유튜브 링크가 있는 경우에만 표시
                          if (_hasValidYouTubeLink())
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () async {
                                  final String youtubeUrl = _getYouTubeUrl();
                                  final Uri uri = Uri.parse(youtubeUrl);
                                  try {
                                    // 유튜브 앱(설치 시) → 없으면 웹브라우저
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    debugPrint('Could not launch youtube: $e');
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 24.w,
                                      color: const Color(0xFF277AFF),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '레시피 영상 보러가기',
                                      style: TextStyle(
                                        fontFamily: 'Mapo',
                                        color: const Color(0xFF277AFF),
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFF277AFF),
                                        decorationThickness: 1,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Text(
                                '재료',
                                style: TextStyle(
                                  color: const Color(0xFF707070),
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              DottedBarWidget(paddingSize: 80.w),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          IngredientTableWidget(ingredients: _loadedRecipe!.ingredients),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Text(
                                '요리과정',
                                style: TextStyle(
                                  color: const Color(0xFF707070),
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              DottedBarWidget(paddingSize: 110.w),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          NumberListWidget(
                            items: _loadedRecipe!.recipe_method,
                            ingredients: _loadedRecipe!.ingredients,
                          ),
                          SizedBox(height: 8.h),
                          _buildEnhancedFinishButton(),
                          SizedBox(height: 50.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 요리 종료 시 확인 다이얼로그
  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              Image.asset(
                'assets/imgs/items/cookExit.png',
                width: 60.w,
                height: 60.w,
              ),
              SizedBox(height: 20.h),
              Text(
                '요리를 종료할까요?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7D674B),
                ),
              ),
              Text(
                '진행 중인 요리를 완료하셨나요?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF969696),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8E8E8),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  '아니오, 중단합니다.',
                  style: TextStyle(
                    color: const Color(0xFF7D674B),
                    fontFamily: 'Mapo',
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8B27),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  '예, 완료했습니다!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Mapo',
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  '계속 요리하기',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFFA7B1C),
                    fontFamily: 'Mapo',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFA7B1C),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

