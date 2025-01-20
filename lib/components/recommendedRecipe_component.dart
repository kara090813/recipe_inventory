import 'dart:io';
import 'dart:math' as math; // 회전 애니메이션에 필요
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class RecommendedRecipeComponent extends StatefulWidget {
  const RecommendedRecipeComponent({Key? key}) : super(key: key);

  @override
  _RecommendedRecipeComponentState createState() => _RecommendedRecipeComponentState();
}

class _RecommendedRecipeComponentState extends State<RecommendedRecipeComponent> {
  late CardSwiperController _cardSwiperController;
  List<Recipe> _recipeItems = [];
  int _recipeCardsSinceLastAd = 0;

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
        ? 'ca-app-pub-3940256099942544/2247696110'
        : 'ca-app-pub-3940256099942544/3986624511';

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
    return Stack(
      children: [
        Column(
          children: [
            HeaderWidget(title: '레시피 추천'),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 26.h),
            Consumer<RecipeStatus>(
              builder: (context, recipeStatus, child) {
                if (recipeStatus.isLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (_recipeItems.isEmpty) {
                  _recipeItems = RecipeRecommendationService().getRecommendedRecipes(
                    Provider.of<UserStatus>(context, listen: false),
                    Provider.of<FoodStatus>(context, listen: false),
                    recipeStatus,
                  );
                  if (_recipeItems.isEmpty) {
                    return const Expanded(
                      child: Center(child: Text('레시피가 없습니다')),
                    );
                  }
                }

                return Expanded(
                  child: CardSwiper(
                    controller: _cardSwiperController,
                    cardsCount: _recipeItems.length,
                    onSwipe: _onSwipe,
                    onUndo: (_, __, ___) => true,
                    backCardOffset: const Offset(0, 40),
                    numberOfCardsDisplayed: 3,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      final recipe = _recipeItems[index];
                      return RecipeCard(
                        recipe: recipe,
                        onPrevious: () => _cardSwiperController.undo(),
                        onNext: () => _cardSwiperController.swipe(CardSwiperDirection.left),
                        onLike: () => _cardSwiperController.swipe(CardSwiperDirection.right),
                      );
                    },
                  ),
                );
              },
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
    for (final ad in _readyAds) {
      ad.dispose();
    }
    _currentAd?.dispose();
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
      // 실제 카드 UI
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            _rotation = _offset.dx * 0.0015;
          });
        },
        onPanEnd: (details) {
          final threshold = (screenSize.width * 0.3);
          if (_offset.dx.abs() > threshold) {
            final endX = (_offset.dx > 0) ? screenSize.width : -screenSize.width;
            _startDismissAnimation(endX);
          } else {
            // 제자리 복귀
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

  void _startDismissAnimation(double endX) {
    _dismissAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, _offset.dy * 0.5),
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
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              child: Image.network(
                recipe.thumbnail,
                fit: BoxFit.fitWidth,
              ),
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
                            child: Consumer<RecipeStatus>(
                              builder: (context, recipeStatus, child) {
                                return Icon(
                                  recipeStatus.isFavorite(recipe.id)
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
                  Consumer<FoodStatus>(
                    builder: (context, foodStatus, child) {
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
                      Consumer<UserStatus>(builder: (context, userStatus, child) {
                        return GestureDetector(
                          onTap: () {
                            userStatus.startCooking(recipe);
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
                        );
                      }),
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
