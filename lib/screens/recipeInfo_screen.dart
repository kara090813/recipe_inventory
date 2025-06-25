import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import '../models/_models.dart';
import '../funcs/_funcs.dart';

class RecipeInfoScreen extends StatefulWidget {
  final Recipe? recipe;
  final String? recipeId;

  const RecipeInfoScreen({super.key, this.recipe, this.recipeId});

  @override
  State<RecipeInfoScreen> createState() => _RecipeInfoScreenState();
}

class _RecipeInfoScreenState extends State<RecipeInfoScreen> {
  Recipe? _loadedRecipe;
  bool _isLoading = false;
  String? _error;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-1961572115316398/8954754570'  // Android 광고 ID
        : 'ca-app-pub-1961572115316398/3953709338'; // iOS 광고 ID

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('요리시작 전면광고 표시됨');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('요리시작 전면광고 닫힘');
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // 광고가 닫힌 후 요리 시작 화면으로 이동
              _navigateToCookingStart();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('요리시작 전면광고 표시 실패: $error');
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // 광고 표시 실패 시에도 요리 시작 화면으로 이동
              _navigateToCookingStart();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('요리시작 전면광고 로드 실패: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      // 광고가 로드되지 않았거나 없으면 바로 요리 시작 화면으로 이동
      _navigateToCookingStart();
    }
  }

  void _navigateToCookingStart() {
    if (_loadedRecipe != null) {
      context.read<UserStatus>().startCooking(_loadedRecipe!);
      context.push('/cookingStart', extra: _loadedRecipe);
    }
  }

  Future<void> _loadRecipeData() async {
    // 이미 레시피 객체가 전달된 경우
    if (widget.recipe != null) {
      setState(() {
        _loadedRecipe = widget.recipe;
      });
      return;
    }

    // recipeId가 전달된 경우 레시피 로드
    if (widget.recipeId != null && widget.recipeId!.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // RecipeStatus에서 ID로 레시피 찾기
        final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
        final recipe = recipeStatus.findRecipeById(widget.recipeId!);

        if (recipe != null) {
          setState(() {
            _loadedRecipe = recipe;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = '레시피를 찾을 수 없습니다: ${widget.recipeId}';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = '레시피 로드 중 오류 발생: $e';
          _isLoading = false;
        });
      }
    } else if (widget.recipe == null && widget.recipeId == null) {
      setState(() {
        _error = '레시피 정보가 없습니다';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 상태 표시
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8B27),
          ),
        ),
      );
    }

    // 에러 상태 표시
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

    // 레시피가 로드되지 않은 경우, 메인 화면으로 리다이렉트
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

    // 실제 레시피 정보 화면
    final userFoods = context.watch<FoodStatus>().userFood;
    final classifiedIngredients = classifyIngredients(_loadedRecipe!, userFoods);
    final combinedFoods = [
      ...classifiedIngredients['available']!,
      ...classifiedIngredients['missing']!,
    ];

    // 각 Ingredient에 대해, 이름이 일치하는 Food를 찾아서 DisplayIngredient 생성
    List<DisplayIngredient> displayIngredients = _loadedRecipe!.ingredients.map((ingredient) {
      // Food의 name은 ingredient.food와 같게 설정되어 있음
      final matchedFood = combinedFoods.firstWhere(
            (food) => food.name == ingredient.food,
        orElse: () => Food(
          name: ingredient.food,
          type: '기타',
          img: 'assets/imgs/food/unknownFood.png',
        ),
      );
      return DisplayIngredient(
        food: ingredient.food,
        cnt: ingredient.cnt,
        img: matchedFood.img,
        type: matchedFood.type,
      );
    }).toList();

    const List<String> customOrder = [
      '육류',
      '수산물',
      '과일',
      '채소',
      '가공/유제품',
      '조미료/향신료',
      '기타',
    ];

    // displayIngredients는 List<DisplayIngredient>라고 가정
    displayIngredients.sort((a, b) {
      final aIndex = customOrder.indexOf(a.type);
      final bIndex = customOrder.indexOf(b.type);
      return aIndex.compareTo(bIndex);
    });

    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                BackButtonWidget(context),
                SizedBox(width: 10.w),
                Text(
                  '레시피 정보',
                  style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                )
              ],
            ),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -1,
                            child: Container(
                              height: 14.h,
                              color: Color(0xFFFFD8A8),
                            ),
                          ),
                          Text(
                            _loadedRecipe!.title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
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
                        recipe: _loadedRecipe!,
                        height: 200.h,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(12.r),
                        fit: BoxFit.cover,
                        highQuality: true,
                      ),
                    ),
                    if (isTablet(context))
                      SizedBox(
                        height: 8.h,
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _loadedRecipe!.recipe_tags
                            .map((tag) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Color(0xFF5E3009),
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Color(0xFFEAE5DF),
                              padding:
                              EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                    if (isTablet(context))
                      SizedBox(
                        height: 4.h,
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          _loadedRecipe!.sub_title,
                          style: TextStyle(color: Color(0xFF707070), fontSize: 12.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    IngredientListWidget(ingredients: displayIngredients),
                    SizedBox(
                      height: 16.h,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("있는 식재료",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Color(0xFF149700),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    FoodListWidget(
                      foodList: classifiedIngredients['available']!,
                      isCategory: false,
                      multi: true,
                      partCount: 7,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("없는 식재료",
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Color(0xFFFF0000),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    FoodListWidget(
                      foodList: classifiedIngredients['missing']!,
                      isCategory: false,
                      multi: true,
                      partCount: 7,
                      bkgColor: 0xFFBFBFBF,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // 가로, 세로 방향의 거리
              ),
            ],
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 6.h),
          child: Row(
            children: [
              Expanded(
                flex: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<RecipeStatus>(builder: (context, recipeStatus, child) {
                      return IconButton(
                        icon: Icon(
                          recipeStatus.isFavorite(_loadedRecipe!.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 32.sp,
                        ),
                        onPressed: () {
                          recipeStatus.toggleFavorite(_loadedRecipe!.id);
                        },
                      );
                    }),
                    SizedBox(
                      height: 5.h,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isTablet(context) ? 6.h : 0),
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFFF8B27),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r), // 버튼의 모서리를 둥글게
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/icons/cook.png',
                              width: 22.w,
                            ),
                            SizedBox(
                              width: isTablet(context) ? 6.w : 10.w,
                            ),
                            Text(
                              '요리 시작하기',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onPressed: () {
                          _showInterstitialAd();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}