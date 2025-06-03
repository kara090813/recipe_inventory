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

class _AdSupportedRecipeListWidgetState extends State<AdSupportedRecipeListWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Recipe> _loadedRecipes = [];
  List<BannerAd?> _bannerAds = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _recipeCardsSinceLastAd = 0;

  static const int _pageSize = 10;

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

    for (int i = 0; i < a.length; i++) {
      // ID로 비교 (더 정확한 비교 방법이 있다면 사용)
      if (a[i].id != b[i].id) return false;
    }

    return true;
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

    // 지연 시뮬레이션 (실제 API 호출 대체)
    await Future.delayed(Duration(milliseconds: 500));

    // 새 레시피 추가
    final newRecipes = widget.recipes.sublist(
      start,
      end > widget.recipes.length ? widget.recipes.length : end,
    );

    // 광고 추가 계산
    int adsToAdd = (newRecipes.length / widget.adFrequency).ceil();
    for (int i = 0; i < adsToAdd; i++) {
      _createBannerAd();
    }

    setState(() {
      _loadedRecipes.addAll(newRecipes);
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200) {
      _loadMoreRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            itemBuilder: (context, index) {
              // 로딩 인디케이터 표시
              if (index >= totalListItems) {
                return Padding(
                  padding: EdgeInsets.all(8.0.h),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // 광고 위치 계산
              int adIndex = index ~/ (widget.adFrequency + 1);
              bool isAdPosition = (index % (widget.adFrequency + 1) == widget.adFrequency);
              // 광고제거버전
              // if (isAdPosition && adIndex < _bannerAds.length && 1==2) {
              if (isAdPosition && adIndex < _bannerAds.length) {
                // 광고 표시
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
                // 레시피 카드 표시
                // 광고 때문에 실제 레시피 인덱스 계산
                int recipeIndex = index - (index ~/ (widget.adFrequency + 1));
                if (recipeIndex >= _loadedRecipes.length) {
                  return SizedBox.shrink();
                }
                return RecipeCardWidget(
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