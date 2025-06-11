import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

// 테스트 광고 ID 사용 (실제 출시 시에는 실제 광고 ID로 변경 필요)
final String testBannerAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-1961572115316398/3834101518'  // Android ID
    : 'ca-app-pub-1961572115316398/2852192338'; // iOS ID

class AdSupportedRecipeListWidget extends StatefulWidget {
  final List<Recipe> recipes;
  final FocusNode node;
  final int adFrequency; // 몇 개의 레시피마다 광고를 표시할지

  const AdSupportedRecipeListWidget({
    Key? key,
    required this.recipes,
    required this.node,
    this.adFrequency = 5, // 기본값으로 5개 레시피마다 광고 삽입
  }) : super(key: key);

  @override
  State<AdSupportedRecipeListWidget> createState() => _AdSupportedRecipeListWidgetState();
}

class _AdSupportedRecipeListWidgetState extends State<AdSupportedRecipeListWidget> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  List<Recipe> _loadedRecipes = [];
  List<BannerAd?> _bannerAds = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _recipeCardsSinceLastAd = 0;

  static const int _pageSize = 15; // 페이지 크기 증가로 광고 로드 빈도 감소

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreRecipes();
  }

  @override
  void didUpdateWidget(AdSupportedRecipeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 레시피 리스트가 변경되었는지 확인 (길이나 내용 변경)
    if (widget.recipes.length != oldWidget.recipes.length ||
        !listEquals(widget.recipes, oldWidget.recipes)) {

      print('레시피 목록 변경 감지: ${oldWidget.recipes.length} -> ${widget.recipes.length}');

      // 기존 광고 정리
      for (var ad in _bannerAds) {
        ad?.dispose();
      }

      // 모든 상태 초기화
      setState(() {
        _loadedRecipes = [];
        _bannerAds = [];
        _hasMore = true;
        _isLoading = false;
      });

      // 새 데이터로 다시 로드
      _loadMoreRecipes();
    }
  }

  // 레시피 목록 비교를 위한 헬퍼 메서드
  bool listEquals(List<Recipe> a, List<Recipe> b) {
    if (a.length != b.length) return false;

    // ID 기반 Set으로 비교하여 중복 체크
    final setA = a.map((recipe) => recipe.id).toSet();
    final setB = b.map((recipe) => recipe.id).toSet();
    
    return setA.length == setB.length && setA.difference(setB).isEmpty;
  }

  void _createBannerAd() {
    BannerAd(
      adUnitId: testBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAds.add(ad as BannerAd);
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('배너 광고 로드 실패: ${err.message}');
          ad.dispose();
          setState(() {
            _bannerAds.add(null); // 로드 실패 시 null 추가
          });
        },
      ),
    ).load();
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final start = _loadedRecipes.length;
    final end = start + _pageSize;

    if (start >= widget.recipes.length) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    // 지연 시간 단축
    await Future.delayed(Duration(milliseconds: 100));

    // 새 레시피 추가
    final newRecipes = widget.recipes.sublist(
      start,
      end > widget.recipes.length ? widget.recipes.length : end,
    );

    // 광고 추가 최적화 - 한 번에 여러 개 로드하지 않고 필요에 따라 로드
    int currentAdsNeeded = ((_loadedRecipes.length + newRecipes.length) / widget.adFrequency).ceil();
    int existingAds = _bannerAds.where((ad) => ad != null).length;
    
    if (currentAdsNeeded > existingAds) {
      _createBannerAd();
    }

    if (mounted) { // mounted 체크
      // 중복 제거 - 이미 로드된 레시피 ID들
      final loadedIds = _loadedRecipes.map((r) => r.id).toSet();
      final uniqueNewRecipes = newRecipes.where((recipe) => !loadedIds.contains(recipe.id)).toList();
      
      setState(() {
        _loadedRecipes.addAll(uniqueNewRecipes);
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 400) { // threshold 증가
      _loadMoreRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    int totalItems = _loadedRecipes.length;
    // 광고 개수 계산 (adFrequency개 레시피마다 1개 광고)
    int adCount = (totalItems / widget.adFrequency).ceil();
    // 총 아이템 수 (레시피 + 광고)
    int totalListItems = totalItems + adCount;

    return Column(
      children: [
        Expanded(
          child: _loadedRecipes.isEmpty && _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: EdgeInsets.only(top: 10.h),
            controller: _scrollController,
            itemCount: totalListItems + (_isLoading ? 1 : 0),
            cacheExtent: 600, // 캐시 영역 설정
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              // 로딩 인디케이터 표시
              if (index >= totalListItems) {
                return Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // 광고 위치 계산 수정
              // 광고는 매 (adFrequency + 1)번째 위치에 표시
              // 예: adFrequency=4일 때, 인덱스 4, 9, 14, 19... 에 광고 표시
              bool isAdPosition = (index + 1) % (widget.adFrequency + 1) == 0;
              
              if (isAdPosition) {
                // 광고 인덱스 계산
                int adIndex = index ~/ (widget.adFrequency + 1);
                
                if (adIndex < _bannerAds.length) {
                  final ad = _bannerAds[adIndex];
                  if (ad == null) {
                    // 로드 실패한 광고는 빈 컨테이너로 처리
                    return SizedBox(height: 10.h);
                  }
                  return Container(
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Color(0xFFBB885E), width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    height: 60.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: AdWidget(ad: ad),
                    ),
                  );
                } else {
                  // 광고가 아직 로드되지 않은 경우 스킵
                  return SizedBox.shrink();
                }
              } else {
                // 레시피 카드 표시
                // 실제 레시피 인덱스 계산 (광고 개수만큼 빼기)
                int adsBeforeThisIndex = index ~/ (widget.adFrequency + 1);
                int recipeIndex = index - adsBeforeThisIndex;
                
                if (recipeIndex >= _loadedRecipes.length) {
                  return SizedBox.shrink();
                }
                
                return RecipeCardWidget(
                  key: ValueKey(_loadedRecipes[recipeIndex].id),
                  recipe: _loadedRecipes[recipeIndex],
                  node: widget.node,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    for (var ad in _bannerAds) {
      ad?.dispose();
    }
    super.dispose();
  }
}