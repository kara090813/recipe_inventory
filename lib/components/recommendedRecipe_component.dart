import 'dart:io';
import 'dart:math' as math; // 회전 애니메이션에 필요
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class RecommendedRecipeComponent extends StatefulWidget {
  const RecommendedRecipeComponent({Key? key}) : super(key: key);

  @override
  _RecommendedRecipeComponentState createState() => _RecommendedRecipeComponentState();
}

class _RecommendedRecipeComponentState extends State<RecommendedRecipeComponent> with AutomaticKeepAliveClientMixin {
  late CardSwiperController _cardSwiperController;
  List<Recipe> _recipeItems = [];
  int _recipeCardsSinceLastAd = 0;
  
  @override
  bool get wantKeepAlive => true;

  // 광고 관련 상수
  static const int TARGET_AD_COUNT = 3; // 유지하려는 광고 개수
  static const int SWIPE_COUNT_FOR_AD = 5; // 광고 표시까지 필요한 스와이프 횟수

  // 광고 상태 관리
  final List<NativeAd> _readyAds = []; // 로드 완료되어 사용 가능한 광고들
  bool _isLoadingAd = false; // 현재 광고 로드 중인지 여부
  bool _showAdOverlay = false;
  NativeAd? _currentAd;

  @override
  void initState() {
    super.initState();
    _cardSwiperController = CardSwiperController();
    _initializeAds();
  }

  // 초기 광고 로드
  void _initializeAds() {
    for (int i = 0; i < TARGET_AD_COUNT; i++) {
      _loadNewAd();
    }
  }

  // 새로운 광고 로드
  void _loadNewAd() {
    if (_isLoadingAd) return;
    if (_readyAds.length >= TARGET_AD_COUNT) return;

    _isLoadingAd = true;

    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-1961572115316398/3369086750'
        : 'ca-app-pub-1961572115316398/2672719231';

    NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _readyAds.add(ad as NativeAd);
              _isLoadingAd = false;
            });

            // 아직 목표 개수에 도달하지 않았다면 다음 광고 로드
            if (_readyAds.length < TARGET_AD_COUNT) {
              _loadNewAd();
            }
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('광고 로드 실패: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoadingAd = false;
            });
          }
        },
      ),
    ).load();
  }

  // 광고 표시 시도
  void _tryShowAd() {
    if (_readyAds.isEmpty) {
      // 준비된 광고가 없으면 새로 로드 시도
      _loadNewAd();
      return;
    }

    setState(() {
      _currentAd = _readyAds.removeAt(0);
      _showAdOverlay = true;
      _recipeCardsSinceLastAd = 0;
    });

    // 사용한 광고 자리를 채우기 위해 새 광고 로드
    _loadNewAd();
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    _recipeCardsSinceLastAd++;

    if (_recipeCardsSinceLastAd >= SWIPE_COUNT_FOR_AD) {
      _tryShowAd();
    }

    return true;
  }

  void _handleAdDismissed() {
    setState(() {
      _showAdOverlay = false;
      _currentAd?.dispose();
      _currentAd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          children: [
            HeaderWidget(title: '레시피 추천'),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 26.h),
            Expanded(
              child: Selector3<RecipeStatus, UserStatus, FoodStatus, ({bool isLoading, int recipesLength, int userHash, int foodHash})>(
                selector: (context, recipeStatus, userStatus, foodStatus) => (
                  isLoading: recipeStatus.isLoading,
                  recipesLength: recipeStatus.recipes.length,
                  userHash: userStatus.hashCode,
                  foodHash: foodStatus.hashCode,
                ),
                builder: (context, data, child) {
                  if (data.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_recipeItems.isEmpty) {
                    final recipeStatus = context.read<RecipeStatus>();
                    final userStatus = context.read<UserStatus>();
                    final foodStatus = context.read<FoodStatus>();
                    
                    _recipeItems = RecipeRecommendationService().getRecommendedRecipes(
                      userStatus,
                      foodStatus,
                      recipeStatus,
                    );
                    if (_recipeItems.isEmpty) {
                      return const Center(child: Text('레시피가 없습니다'));
                    }
                  }

                  return CardSwiper(
                    controller: _cardSwiperController,
                    cardsCount: _recipeItems.length,
                    onSwipe: _onSwipe,
                    onUndo: (_, __, ___) => true,
                    backCardOffset: const Offset(0, 40),
                    numberOfCardsDisplayed: 3,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      final recipe = _recipeItems[index];
                      return RecipeCard(
                        key: ValueKey(recipe.id),
                        recipe: recipe,
                        onPrevious: () => _cardSwiperController.undo(),
                        onNext: () => _cardSwiperController.swipe(CardSwiperDirection.left),
                        onLike: () => _cardSwiperController.swipe(CardSwiperDirection.right),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
        if (_showAdOverlay && _currentAd != null)
          Positioned.fill(
            child: SwipableAdCard(
              nativeAd: _currentAd!,
              onDismissed: _handleAdDismissed,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // 광고 정리
    for (final ad in _readyAds) {
      ad.dispose();
    }
    _currentAd?.dispose();
    
    // 컨트롤러 정리
    _cardSwiperController.dispose();
    
    // 캐시 정리 (메모리 절약)
    if (_recipeItems.length > 50) {
      _recipeItems.clear();
    }
    
    super.dispose();
  }
}

/// 광고를 “레시피 카드”처럼 보이게 하면서,
/// 드래그로 왼/오른쪽으로 날리는 애니메이션을 구현한 위젯.
class SwipableAdCard extends StatefulWidget {
  final NativeAd nativeAd;
  final VoidCallback onDismissed;

  const SwipableAdCard({
    Key? key,
    required this.nativeAd,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<SwipableAdCard> createState() => _SwipableAdCardState();
}

class _SwipableAdCardState extends State<SwipableAdCard> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero; // 드래그 이동
  double _rotation = 0.0; // 회전(기울이기)
  late Size screenSize;

  AnimationController? _dismissController;
  Animation<Offset>? _dismissAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenSize = MediaQuery.of(context).size;
    });
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dismissController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 전체 카드에 스와이프 애니메이션 적용
    return AnimatedBuilder(
      animation: _dismissController!,
      builder: (context, child) {
        final animOffset = _dismissAnimation?.value ?? Offset.zero;
        final totalOffset = _offset + animOffset;

        return Transform.translate(
          offset: totalOffset,
          child: Transform.rotate(
            angle: _rotation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Y축 이동도 허용
            _offset += details.delta;
            // 회전 각도를 X축 이동에 따라 조절
            _rotation = _offset.dx * 0.001; // 회전 각도 조절
          });
        },
        onPanEnd: (details) {
          // 레시피 카드와 동일한 threshold로 설정 (화면 너비의 15%)
          final threshold = screenSize.width * 0.15;

          // X축 또는 Y축 이동이 threshold를 넘으면 카드 제거
          if (_offset.dx.abs() > threshold || _offset.dy.abs() > threshold) {
            // 이동 방향에 따라 적절한 방향으로 날아가도록 설정
            double endX = _offset.dx.abs() > _offset.dy.abs()
                ? (_offset.dx > 0 ? screenSize.width : -screenSize.width)
                : 0;
            double endY = _offset.dx.abs() <= _offset.dy.abs()
                ? (_offset.dy > 0 ? screenSize.height : -screenSize.height)
                : _offset.dy;

            _startDismissAnimation(endX, endY);
          } else {
            // threshold를 넘지 않으면 원위치
            setState(() {
              _offset = Offset.zero;
              _rotation = 0;
            });
          }
        },
        child: Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 90.h),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(color: const Color(0xFFBB885E), width: 1.w),
          ),
          // 카드 높이를 너무 길게 안 잡고, 적당히 고정:
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: AdWidget(ad: widget.nativeAd),
          ),
        ),
      ),
    );
  }

  void _startDismissAnimation(double endX, double endY) {
    _dismissAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _dismissController!,
      curve: Curves.easeInOut,
    ));

    _dismissController!.reset();
    _dismissController!.forward().then((_) {
      widget.onDismissed();
    });
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLike;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onPrevious,
    required this.onNext,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: Color(0xFFBB885E), width: 1.w), // 테두리 색상과 두께
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: RecipeThumbnailWidget(
              recipe: recipe,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: isTablet(context)
                  ? EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w)
                  : EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isTablet(context) ? 2.h : 10.h,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(left: 8.w, right: 8.w, top: 0, bottom: 4.h),
                                child: Text(
                                  recipe.title,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.black,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<RecipeStatus>().toggleFavorite(recipe.id);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBD6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Selector<RecipeStatus, bool>(
                              selector: (context, recipeStatus) => recipeStatus.isFavorite(recipe.id),
                              builder: (context, isFavorite, child) {
                                return Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: const Color(0xFFEC3030),
                                  size: 24,
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet(context) ? 14.h : 28.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recipe.recipe_tags
                          .map((tag) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEAE5DF),
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF5E3009)),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Center(
                    child: Text(
                      recipe.sub_title,
                      style: TextStyle(fontSize: 14.sp, color: Color(0xFF707070)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Builder(
                    builder: (context) {
                      final foodStatus = context.read<FoodStatus>();
                      final matchRate = foodStatus.calculateMatchRate(recipe.ingredients);
                      return Center(child: MatchRateIndicator(matchRate: matchRate));
                    },
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onPrevious,
                        child: Container(
                            width: isTablet(context) ? 40.w : 50.w,
                            height: isTablet(context) ? 40.w : 50.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.refresh,
                                color: Color(0xFF9A9A9A), size: isTablet(context) ? 30.w : 40.w)),
                      ),
                      SizedBox(
                        width: isTablet(context) ? 10.w :  20.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<UserStatus>().startCooking(recipe);
                          context.push('/recipeInfo', extra: recipe);
                        },
                        child: Container(
                          width: isTablet(context) ? 60.w : 70.w,
                          height: isTablet(context) ? 60.w : 70.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8B27),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: SizedBox(
                                width: isTablet(context) ? 46.w : 56.w,
                                child: Image.asset('assets/imgs/items/cookStart'
                                    '.png')),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isTablet(context) ? 10.w : 20.w,
                      ),
                      GestureDetector(
                        onTap: onNext,
                        child: Container(
                          width: isTablet(context) ? 40.w : 50.w,
                          height: isTablet(context) ? 40.w : 50.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFEA0000),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: isTablet(context) ? 28.w : 38.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Center(
                    child: Text(
                      "레시피 확인",
                      style: TextStyle(color: Color(0xFFFF8B27), fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, Color color) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, color: color, size: 24.w),
      ),
    );
  }
}
