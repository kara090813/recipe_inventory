import 'dart:async';
import 'dart:io';

import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

// youtube_player_iframe: ^5.2.1 (pubspec.yaml 추가 후, 아래 임포트)
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class CookingStartScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingStartScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<CookingStartScreen> createState() => _CookingStartScreenState();
}

class _CookingStartScreenState extends State<CookingStartScreen> {
  /// (5.x) YoutubePlayerController
  late YoutubePlayerController _youtubeController;

  /// Interstitial 광고 ID
  final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트용 ID
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트용 ID
  InterstitialAd? _interstitialAd;

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

  /// 광고 표시 후 메인화면 이동
  void _showAdAndNavigateHome(BuildContext context) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          // 광고가 닫힐 때 메인으로 이동
          context.read<UserStatus>().endCooking(widget.recipe);
          Provider.of<TabStatus>(context, listen: false).setIndex(4);
          context.go('/');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          // 광고 표시 실패 시 바로 메인으로 이동
          context.read<UserStatus>().endCooking(widget.recipe);
          Provider.of<TabStatus>(context, listen: false).setIndex(4);
          context.go('/');
        },
      );
      _interstitialAd!.show();
    } else {
      // 광고가 로드되지 않았을 때 바로 메인으로 이동
      context.read<UserStatus>().endCooking(widget.recipe);
      Provider.of<TabStatus>(context, listen: false).setIndex(4);
      context.go('/');
    }
  }

  /// 요리 종료 로직
  void _endCooking(BuildContext context) {
    _showAdAndNavigateHome(context);
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

  @override
  void initState() {
    super.initState();

    // 링크에서 videoId 추출
    final videoId = YoutubePlayerController.convertUrlToId(widget.recipe.link) ?? '';

    // (5.x) YoutubePlayerController.fromVideoId(...) 사용
    // autoPlay / showControls / showFullscreenButton 등은 params에서 지정
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );

    // 인터스티셜 광고 미리 로드
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    // (5.x) iFrame 컨트롤러는 close() 사용
    _youtubeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          _buildYoutubePlayer(),
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
                                  widget.recipe.title,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () async {
                                final Uri youtubeUrl = Uri.parse(widget.recipe.link);
                                try {
                                  // 유튜브 앱(설치 시) → 없으면 웹브라우저
                                  await launchUrl(
                                    youtubeUrl,
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
                          IngredientTableWidget(ingredients: widget.recipe.ingredients),
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
                            items: widget.recipe.recipe_method,
                            ingredients: widget.recipe.ingredients,
                          ),
                          SizedBox(height: 8.h),
                          ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E3009),
                              minimumSize: const Size(double.infinity, 0),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              '요리 종료하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Mapo',
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
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
