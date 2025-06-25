import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../models/_models.dart';
import '../models/freezed/badge_model.dart' as BadgeModel;
import '../status/_status.dart';
import '../status/userStatus.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/_widgets.dart';

class CookCompleteScreen extends StatefulWidget {
  final Recipe recipe;
  final int cookingTime;
  final String? completedImagePath;
  final List<String>? newlyAcquiredBadgeIds;
  final List<String>? newlyCompletedQuestIds;
  final InterstitialAd? interstitialAd;
  final List<BadgeModel.Badge>? newlyAcquiredBadges; // 실제 뱃지 객체들

  const CookCompleteScreen({
    Key? key,
    required this.recipe,
    required this.cookingTime,
    this.completedImagePath,
    this.newlyAcquiredBadgeIds,
    this.newlyCompletedQuestIds,
    this.interstitialAd,
    this.newlyAcquiredBadges,
  }) : super(key: key);

  @override
  State<CookCompleteScreen> createState() => _CookCompleteScreenState();
}

class _CookCompleteScreenState extends State<CookCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;
  final GlobalKey _legalPadKey = GlobalKey();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isRecipePhotoSelected = true;
  String? _selectedImagePath;
  bool _hasShownAd = false;
  bool _hasShownBadges = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();

    // 요리 완료시 경험치 지급
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStatus = Provider.of<UserStatus>(context, listen: false);
      userStatus.addCookingHistory(widget.recipe);
      
      // 화면 로드 후 광고 표시
      _showAdAndThenBadges();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 광고 표시 후 뱃지 팝업
  void _showAdAndThenBadges() {
    if (_hasShownAd) return; // 이미 광고를 표시했으면 건너뛰기
    
    _hasShownAd = true;
    
    print('🎯 _showAdAndThenBadges called');
    print('🎯 interstitialAd is null: ${widget.interstitialAd == null}');
    
    // 약간의 지연 후 광고 표시 (화면이 완전히 로드된 후)
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // 광고가 있고 아직 dispose되지 않았으면 표시
      if (widget.interstitialAd != null) {
        try {
          print('🎯 Attempting to show ad');
          widget.interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('🎯 Ad dismissed');
              // 광고 종료 후 약간의 지연을 두고 뱃지 팝업 표시
              Future.delayed(Duration(milliseconds: 300), () {
                if (mounted) {
                  print('🎯 Showing badges after ad dismissed');
                  _showBadgePopups();
                }
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('🎯 Ad failed to show: $error');
              // 광고 실패 시에도 뱃지 팝업 표시
              Future.delayed(Duration(milliseconds: 300), () {
                if (mounted) {
                  print('🎯 Showing badges after ad failed');
                  _showBadgePopups();
                }
              });
            },
          );
          widget.interstitialAd!.show();
        } catch (e) {
          print('🎯 Error showing ad: $e');
          // 광고 표시 실패 시 바로 뱃지 팝업 표시
          _showBadgePopups();
        }
      } else {
        print('🎯 No ad, showing badges directly');
        _showBadgePopups();
      }
    });
  }
  
  /// 뱃지 팝업 표시
  void _showBadgePopups() {
    if (!mounted) {
      print('🎯 _showBadgePopups: widget not mounted');
      return;
    }
    
    if (_hasShownBadges) {
      print('🎯 _showBadgePopups: badges already shown, skipping');
      return;
    }
    
    _hasShownBadges = true;
    
    print('🎯 _showBadgePopups called');
    print('🎯 newlyAcquiredBadges is null: ${widget.newlyAcquiredBadges == null}');
    print('🎯 newlyAcquiredBadges length: ${widget.newlyAcquiredBadges?.length}');
    
    // 중복 뱃지 제거
    final uniqueBadges = <String, BadgeModel.Badge>{};
    if (widget.newlyAcquiredBadges != null) {
      for (final badge in widget.newlyAcquiredBadges!) {
        uniqueBadges[badge.id] = badge;
      }
    }
    final uniqueBadgeList = uniqueBadges.values.toList();
    
    print('🎯 Unique badges count: ${uniqueBadgeList.length}');
    for (int i = 0; i < uniqueBadgeList.length; i++) {
      final badge = uniqueBadgeList[i];
      print('🎯 Unique Badge $i: ${badge.name} - ${badge.imagePath}');
    }
    
    // 새로운 뱃지 팝업 위젯 사용
    if (mounted && uniqueBadgeList.isNotEmpty) {
      print('🎯 Showing badge popup with new widget');
      _showNextBadgePopup(0, uniqueBadgeList);
    } else {
      print('🎯 No unique badges to show');
    }
  }
  
  /// 뱃지 팝업을 순차적으로 표시
  void _showNextBadgePopup(int index, List<BadgeModel.Badge> badgeList) {
    print('🎯 _showNextBadgePopup called with index: $index');
    
    if (index >= badgeList.length) {
      print('🎯 No more badges to show - index: $index, length: ${badgeList.length}');
      return; // 모든 뱃지를 표시했음
    }
    
    final badge = badgeList[index];
    print('🎯 Showing badge: ${badge.name}');
    
    try {
      BadgeUnlockPopupWidget.show(
        context,
        badge,
        onConfirm: () {
          print('🎯 Badge confirmed, checking for next badge');
          // 다음 뱃지가 있으면 표시
          final nextIndex = index + 1;
          if (nextIndex < badgeList.length) {
            print('🎯 Showing next badge with index: $nextIndex');
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) _showNextBadgePopup(nextIndex, badgeList);
            });
          } else {
            print('🎯 All badges shown');
          }
        },
      );
      print('🎯 BadgeUnlockPopupWidget.show called successfully');
    } catch (e) {
      print('🎯 Error showing badge popup: $e');
    }
  }

  Map<String, String> _getRandomTitle() {
    final titles = [
      {'title': '오늘의 요리 완성!', 'subtitle': '이 정도면 자랑해도 되잖아? 😎'},
      {'title': '요리 인증샷📸', 'subtitle': '이 요리, 친구한테도 추천해볼까? 🍳'},
      {'title': '오늘 만든 요리', 'subtitle': '한 끼 완성! 공유하고 추억으로 남겨봐요 🙌'},
      {'title': '#오늘의_요리', 'subtitle': '이 요리는 SNS행 급입니다 🍽️✨'},
      {'title': 'Cooking Complete', 'subtitle': '요리 끝! 자, 이제 자랑할 차례 👀'},
      {'title': '내 요리 성과', 'subtitle': '한 걸음 성장한 요리 실력, 공유로 마무리! 📈'},
    ];
    final random = Random();
    final selected = titles[random.nextInt(titles.length)];
    return {'title': selected['title']!, 'subtitle': selected['subtitle']!};
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // 마이페이지로 이동
          Provider.of<TabStatus>(context, listen: false).setIndex(4);
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),

                        // 간단한 헤더 영역
                        Builder(
                          builder: (context) {
                            final titleData = _getRandomTitle();
                            return AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 24.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12.r,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                    child: Stack(
                                      children: [
                                        // 메인 컨테이너
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEEDDF),
                                          ),
                                          child: Column(
                                            children: [
                                              // 상단 갈색 띠
                                              Container(
                                                width: double.infinity,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF5E3009),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 4.r,
                                                      offset: Offset(0, 2.h),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // 컨텐츠
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    24.w, 20.h, 24.w, 20.h),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            titleData['title']!,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Colors
                                                                  .grey[900],
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4.h),
                                                          Text(
                                                            titleData[
                                                                'subtitle']!,
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .grey[600],
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 16.w),
                                                    // 건너뛰기 버튼
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Provider.of<TabStatus>(
                                                                  context,
                                                                  listen: false)
                                                              .setIndex(4);
                                                          context.go('/');
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16.w,
                                                                  vertical:
                                                                      10.h),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.r),
                                                            border: Border.all(
                                                              color: const Color(
                                                                      0xFF8B4513)
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.w,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.05),
                                                                blurRadius: 4.r,
                                                                offset: Offset(
                                                                    0, 2.h),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.skip_next,
                                                                size: 18.sp,
                                                                color: const Color(
                                                                    0xFF8B4513),
                                                              ),
                                                              SizedBox(
                                                                  width: 4.w),
                                                              Text(
                                                                '건너뛰기',
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color(
                                                                      0xFF8B4513),
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 반짝이는 애니메이션 효과
                                        Positioned.fill(
                                          child: Transform.translate(
                                            offset: Offset(
                                                _shimmerAnimation.value * 400.w,
                                                0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white
                                                        .withOpacity(0.1),
                                                    Colors.white
                                                        .withOpacity(0.2),
                                                    Colors.white
                                                        .withOpacity(0.1),
                                                    Colors.transparent,
                                                  ],
                                                  stops: const [
                                                    0.0,
                                                    0.3,
                                                    0.5,
                                                    0.7,
                                                    1.0
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // 갈색 헤더 + 리갈패드 영역 (한번에 캡처)
                        RepaintBoundary(
                          key: _legalPadKey,
                          child: Column(
                            children: [
                              // 갈색 헤더
                              Container(
                                width: double.infinity,
                                height: 30.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5E3009),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4.r,
                                      offset: Offset(0, 2.h),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 16.w,
                                      top: 0,
                                      bottom: 0,
                                      child: Consumer<UserStatus>(
                                        builder: (context, userStatus, child) {
                                          return Center(
                                            child: Text(
                                              '${userStatus.nickname}\'s cooking',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontFamily: 'Nanum',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 리갈패드 영역
                              Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                child: Stack(
                                  children: [
                                    // 베이스 컨테이너 (전체 크기)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEEDDF),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20.r),
                                            bottomRight: Radius.circular(20.r),
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF5E3009)
                                                .withOpacity(0.3),
                                            width: 1.w,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                              blurRadius: 8.r,
                                              offset: Offset(0, 4.h),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // 리갈패드 빨간 두줄 (컨텐츠 뒤에)
                                    Positioned(
                                      left: 40.w,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 1.w,
                                        color: const Color(0xFFE57373),
                                      ),
                                    ),
                                    Positioned(
                                      left: 48.w,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 1.w,
                                        color: const Color(0xFFE57373),
                                      ),
                                    ),
                                    // 컨텐츠
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 30.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // 제목 (중앙 정렬) - 레시피 이름
                                          Column(
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  widget.recipe.title,
                                                  style: TextStyle(
                                                    fontSize: 28.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFF8B4513),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // 파란 밑줄
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 8.h, bottom: 15.h),
                                                height: 1.h,
                                                width:
                                                    widget.recipe.title.length *
                                                            20.w +
                                                        60.w,
                                                color: const Color(0xFF4A90E2),
                                              ),
                                            ],
                                          ),

                                          // 날짜
                                          RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: const Color(0xFF5E3009),
                                              ),
                                              children:
                                                  _buildConsecutiveDaysText(),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: 25.h),

                                          // 음식 이미지
                                          Container(
                                            width: double.infinity,
                                            height: 220.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
                                              border: Border.all(
                                                color: const Color(0xFF8B4513)
                                                    .withOpacity(0.8),
                                                width: 2.w,
                                              ),
                                              image: DecorationImage(
                                                image: _getDisplayImage(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 30.h),

                                          // 통계 정보들을 왼쪽 정렬로 변경
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLegalPadStatItem(
                                                iconPath:
                                                    'assets/imgs/items/point_yellow.png',
                                                label: '난이도',
                                                value: widget.recipe.difficulty,
                                                showProgress: true,
                                                difficulty:
                                                    widget.recipe.difficulty,
                                              ),
                                              // 경험치 지급 내역 추가
                                              Consumer<UserStatus>(
                                                builder: (context, userStatus,
                                                    child) {
                                                  final exp = userStatus
                                                      .getDifficultyExperience(
                                                          widget.recipe
                                                              .difficulty);
                                                  return _buildLegalPadStatItem(
                                                    iconPath:
                                                        'assets/imgs/items/point_blue.png',
                                                    label: '경험치',
                                                    value: '+${exp}XP 획득!',
                                                    showProgress: false,
                                                    valueColor: Colors.blue,
                                                  );
                                                },
                                              ),
                                              _buildLegalPadStatItem(
                                                iconPath:
                                                    'assets/imgs/items/point_orange.png',
                                                label: '소요시간',
                                                value:
                                                    '총 ${widget.cookingTime}분 걸렸어요!',
                                                highlightText:
                                                    '${widget.cookingTime}분',
                                                showProgress: false,
                                                valueColor: Colors.orange,
                                              ),
                                              Consumer2<BadgeStatus,
                                                  QuestStatus>(
                                                builder: (context, badgeStatus,
                                                    questStatus, child) {
                                                  return _buildAchievementDisplay(
                                                      badgeStatus, questStatus);
                                                },
                                              ),
                                              _buildLegalPadStatItem(
                                                iconPath:
                                                    'assets/imgs/food/unknownFood.png',
                                                label: '요리재료',
                                                value: widget.recipe.ingredients
                                                    .map((ingredient) =>
                                                        ingredient.food)
                                                    .join(', '),
                                                showProgress: false,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        // 모던한 하단 컨트롤 영역
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.r)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20.r,
                                offset: Offset(0, -4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 상단 핸들 인디케이터
                              Container(
                                margin: EdgeInsets.only(top: 12.h),
                                width: 48.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),

                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 사진 선택 섹션
                                    Text(
                                      '사진 선택',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(3.w),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDE7E2),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _onPhotoOptionTap(true),
                                              child: _buildPhotoOption(
                                                '레시피 사진',
                                                '기본 제공된 요리 이미지',
                                                Icons.restaurant,
                                                _isRecipePhotoSelected,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _onPhotoOptionTap(false),
                                              child: _buildPhotoOption(
                                                '직접 촬영',
                                                '내가 만든 요리 사진',
                                                Icons.camera_alt,
                                                !_isRecipePhotoSelected,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 24.h),

                                    // 하단 액션 버튼들 - 갤러리 저장/공유 반반
                                    Row(
                                      children: [
                                        // 갤러리 저장 버튼
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF8B4513)
                                                      .withOpacity(0.3),
                                                  blurRadius: 12.r,
                                                  offset: Offset(0, 4.h),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: const Color(0xFF8B4513),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              child: InkWell(
                                                onTap: _saveToGallery,
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 18.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.download_rounded,
                                                        color: Colors.white,
                                                        size: 22.sp,
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Text(
                                                        '갤러리 저장',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        // 공유 버튼
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.3),
                                                  blurRadius: 12.r,
                                                  offset: Offset(0, 4.h),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.orange[500],
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              child: InkWell(
                                                onTap: _shareImage,
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 18.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.share_rounded,
                                                        color: Colors.white,
                                                        size: 22.sp,
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Text(
                                                        '공유하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16.h),

                                    // 완료 버튼
                                    Container(
                                      width: double.infinity,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Provider.of<TabStatus>(context,
                                                    listen: false)
                                                .setIndex(4);
                                            context.go('/');
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 14.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              border: Border.all(
                                                color: const Color(0xFF8B4513)
                                                    .withOpacity(0.3),
                                                width: 1.w,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4.r,
                                                  offset: Offset(0, 2.h),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_rounded,
                                                  size: 18.sp,
                                                  color:
                                                      const Color(0xFF8B4513),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  '완료',
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF8B4513),
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalPadStatItem({
    required String iconPath,
    required String label,
    required String value,
    required bool showProgress,
    Color? valueColor,
    String? highlightText,
    String? difficulty,
  }) {
    // 요리재료인 경우 특별 처리
    if (label == '요리재료') {
      return _buildIngredientsItem(iconPath: iconPath, value: value);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 20.w,
                height: 20.w,
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 80.w,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF5E3009),
                    fontFamily: 'Mapo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              if (showProgress && label == '난이도')
                Expanded(
                  child: Container(
                    height: 8.h,
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1.w,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _getDifficultyProgress(difficulty ?? value),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(difficulty ?? value),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        highlightText != null && value.contains(highlightText)
                            ? RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5E3009),
                                  ),
                                  children: [
                                    TextSpan(
                                      style: TextStyle(fontFamily: 'Mapo',),
                                      text: value.substring(
                                          0, value.indexOf(highlightText)),
                                    ),
                                    TextSpan(
                                      text: highlightText,
                                      style: TextStyle(color: Colors.orange,fontFamily: 'Mapo',),
                                    ),
                                    TextSpan(
                                      style: TextStyle(fontFamily: 'Mapo',),
                                      text: value.substring(
                                          value.indexOf(highlightText) +
                                              highlightText.length),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: valueColor ?? const Color(0xFF5E3009),
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                  ),
                ),
            ],
          ),
          // 파란 가로줄
          Container(
            margin: EdgeInsets.only(top: 10.h),
            height: 1.h,
            width: double.infinity,
            color: const Color(0xFF4A90E2),
          ),
        ],
      ),
    );
  }

  // 요리재료를 위한 특별한 빌드 메서드
  Widget _buildIngredientsItem({
    required String iconPath,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconPath,
                width: 20.w,
                height: 20.w,
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 80.w,
                child: Text(
                  '요리재료',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF5E3009),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5E3009),
                    height: 1.4, // 줄 간격 추가
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // 파란 가로줄
          Container(
            margin: EdgeInsets.only(top: 8.h),
            height: 1.h,
            width: double.infinity,
            color: const Color(0xFF4A90E2),
          ),
        ],
      ),
    );
  }

  // 텍스트가 여러 줄인지 확인하는 메서드
  bool _isTextMultiLine(String text) {
    // 간단한 추정: 텍스트 길이가 25자 이상이면 두 줄 이상으로 간주
    // 실제로는 TextPainter를 사용해서 정확히 계산할 수 있지만, 성능을 위해 간단한 방법 사용
    return text.length > 25;
  }

  Widget _buildTag(String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B4513) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildModernToggle(String text, bool isSelected, IconData icon) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: 토글 상태 변경
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF8B4513) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 20.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImprovedToggle(String text, bool isSelected, IconData icon) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: 토글 상태 변경
            },
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B4513) : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF8B4513) : Colors.grey[300]!,
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 2.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 18.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String text, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 프리셋 선택 시 토글 업데이트
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B4513).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B4513) : Colors.grey[400]!,
                width: 1.w,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF8B4513) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetOption(
      String title, String subtitle, List<String> items, bool isSelected) {
    final iconMap = {
      '요리명': Icons.restaurant_menu,
      '소요시간': Icons.timer,
      '사용재료': Icons.kitchen,
      '획득뱃지': Icons.emoji_events,
      '연속일': Icons.local_fire_department,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 프리셋 선택
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF8B4513) : Colors.transparent,
                width: 2.w,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B4513).withOpacity(0.1),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // 선택 인디케이터
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B4513)
                          : Colors.grey[400]!,
                      width: 2.w,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B4513),
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                // 타이틀과 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected ? Colors.grey[900] : Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // 포함된 항목들
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: items
                            .map((item) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF8B4513)
                                            .withOpacity(0.08)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        iconMap[item] ?? Icons.check,
                                        size: 12.sp,
                                        color: isSelected
                                            ? const Color(0xFF8B4513)
                                            : Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? const Color(0xFF8B4513)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPreset(
      String title, List<String> items, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 프리셋 선택 시 위의 토글들 업데이트
            // 미니멀: 요리명만
            // 베이직: 요리명, 시간
            // 디테일: 요리명, 시간, 재료
            // 풀세트: 모든 항목
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B4513) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B4513) : Colors.grey[300]!,
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 2.r,
                  offset: Offset(0, 1.h),
                ),
              ],
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOption(
      String text, Color color, bool isSelected, IconData icon) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: 배경 선택
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF8B4513) : Colors.grey[300]!,
                  width: isSelected ? 2.w : 1.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B4513).withOpacity(0.2),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24.sp,
                    color:
                        isSelected ? const Color(0xFF8B4513) : Colors.grey[600],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF8B4513)
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
      String title, String subtitle, IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B4513).withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: isSelected ? const Color(0xFF8B4513) : Colors.grey[600],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.grey[900] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 연속 요리 텍스트 빌드
  List<TextSpan> _buildConsecutiveDaysText() {
    final userStatus = Provider.of<UserStatus>(context, listen: false);
    final consecutiveDays = userStatus.getConsecutiveCookingDays();
    final totalCookCount = userStatus.cookingHistory.length;

    // 연속 요리인 경우 (1일 이상 연속)
    if (consecutiveDays > 1) {
      return [
        TextSpan(
          text: '${consecutiveDays}일 연속',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontFamily: 'Mapo'),
        ),
        TextSpan(text: '으로 요리했어요!', style: TextStyle(fontFamily: 'Mapo')),
      ];
    } else {
      // 연속이 아닌 경우 (총 요리 횟수)
      return [
        TextSpan(text: '냉털이로 총 ', style: TextStyle(fontFamily: 'Mapo')),
        TextSpan(
          text: '${totalCookCount}번',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontFamily: 'Mapo'),
        ),
        TextSpan(text: ' 요리했어요', style: TextStyle(fontFamily: 'Mapo')),
      ];
    }
  }

  // 현재 표시할 이미지 가져오기
  ImageProvider _getDisplayImage() {
    if (!_isRecipePhotoSelected && _selectedImagePath != null) {
      return FileImage(File(_selectedImagePath!));
    }

    if (widget.completedImagePath != null) {
      return AssetImage(widget.completedImagePath!) as ImageProvider;
    }

    // 썸네일이 유효한지 확인
    if (_hasValidThumbnail()) {
      return NetworkImage(widget.recipe.thumbnail);
    } else {
      // 썸네일이 없는 경우 기본 레시피 아이콘 이미지 사용
      return AssetImage('assets/imgs/icons/custom_recipe.png');
    }
  }

  // 썸네일이 유효한지 확인하는 메서드
  bool _hasValidThumbnail() {
    return widget.recipe.thumbnail.isNotEmpty &&
        widget.recipe.thumbnail != '' &&
        !widget.recipe.thumbnail.contains('null') &&
        Uri.tryParse(widget.recipe.thumbnail) != null;
  }

  // 난이도별 진행도 반환 (0.0 ~ 1.0)
  double _getDifficultyProgress(String difficulty) {
    switch (difficulty) {
      case '매우 쉬움':
        return 0.2;
      case '쉬움':
        return 0.4;
      case '보통':
        return 0.6;
      case '어려움':
        return 0.8;
      case '매우 어려움':
        return 1.0;
      default:
        return 0.6;
    }
  }

  // 난이도별 색상 반환
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '매우 쉬움':
        return Colors.green[400]!;
      case '쉬움':
        return Colors.lightGreen[400]!;
      case '보통':
        return Colors.yellow[700]!;
      case '어려움':
        return Colors.orange[600]!;
      case '매우 어려움':
        return Colors.red[600]!;
      default:
        return Colors.yellow[700]!;
    }
  }

  // 뱃지/퀘스트 달성 표시
  Widget _buildAchievementDisplay(
      BadgeStatus badgeStatus, QuestStatus questStatus) {
    // 이번 요리로 새로 획득한 뱃지 확인
    if (widget.newlyAcquiredBadgeIds != null &&
        widget.newlyAcquiredBadgeIds!.isNotEmpty) {
      final badgeId = widget.newlyAcquiredBadgeIds!.first; // 첫 번째 새로 획득한 뱃지
      final badge = badgeStatus.getBadgeById(badgeId);
      if (badge != null) {
        return _buildLegalPadStatItem(
          iconPath: 'assets/imgs/items/point_pink.png',
          label: '획득뱃지',
          value: '${badge.name} 뱃지를 획득했어요!',
          showProgress: false,
          valueColor: Colors.orange,
        );
      }
    }

    // 이번 요리로 새로 완료된 퀘스트 확인
    if (widget.newlyCompletedQuestIds != null &&
        widget.newlyCompletedQuestIds!.isNotEmpty) {
      final questId = widget.newlyCompletedQuestIds!.first; // 첫 번째 새로 완료된 퀘스트
      final quest = questStatus.findQuestById(questId);
      if (quest != null) {
        return _buildLegalPadStatItem(
          iconPath: 'assets/imgs/items/point_pink.png',
          label: '퀘스트',
          value: '${quest.title} 퀘스트를 완료했어요!',
          showProgress: false,
          valueColor: Colors.green,
        );
      }
    }

    // 둘 다 아닌 경우 빈 컨테이너 반환 (생략)
    return Container();
  }

  // 갤러리 저장 기능
  Future<void> _saveToGallery() async {
    try {
      // mounted 확인
      if (!mounted) return;

      // 리갈패드 영역을 이미지로 캡처
      final RenderRepaintBoundary boundary = _legalPadKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/recipe_${widget.recipe.title}_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // gal 패키지를 사용하여 갤러리에 저장
      await Gal.putImage(imagePath);

      // 성공 메시지 표시 - Overlay 사용
      _showMessage('이미지가 갤러리에 저장되었습니다!', isSuccess: true);
    } catch (e) {
      print('갤러리 저장 오류: $e'); // 디버그용 로그

      // 에러 메시지 표시
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        _showMessage('갤러리 저장 권한이 필요합니다', isSuccess: false, showSettings: true);
      } else {
        _showMessage('이미지 저장에 실패했습니다', isSuccess: false);
      }
    }
  }

  // 오버레이를 사용한 메시지 표시
  void _showMessage(String message,
      {required bool isSuccess, bool showSettings = false}) {
    final overlay = Overlay.of(context);

    // 애니메이션을 위한 변수들
    double topPosition = -100.h;
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // 애니메이션 시작
          Future.delayed(Duration(milliseconds: 100), () {
            if (overlayEntry.mounted) {
              setState(() {
                topPosition = MediaQuery.of(context).padding.top + 20.h;
              });
            }
          });

          return AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            top: topPosition,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isSuccess)
                      Icon(Icons.check_circle,
                          color: Colors.white, size: 24.sp),
                    if (!isSuccess)
                      Icon(Icons.error, color: Colors.white, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (showSettings)
                      TextButton(
                        onPressed: () => openAppSettings(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          '설정',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
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
    );

    overlay.insert(overlayEntry);

    // 3초 후 위로 올라가면서 사라지기
    Future.delayed(Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        // StatefulBuilder 내부의 setState를 사용할 수 없으므로 새로운 OverlayEntry로 교체
        final fadeOutEntry = OverlayEntry(
          builder: (context) => AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInBack,
            top: -100.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isSuccess)
                      Icon(Icons.check_circle,
                          color: Colors.white, size: 24.sp),
                    if (!isSuccess)
                      Icon(Icons.error, color: Colors.white, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        overlayEntry.remove();
        overlay.insert(fadeOutEntry);

        Future.delayed(Duration(milliseconds: 300), () {
          fadeOutEntry.remove();
        });
      }
    });
  }

  // 소셜 공유 기능
  Future<void> _shareImage() async {
    try {
      // 리갈패드 영역을 이미지로 캡처
      final RenderRepaintBoundary boundary = _legalPadKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/recipe_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 공유하기 - ShareResult를 확인하여 성공 여부 판단
      final ShareResult result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: '냉장고 털이로 ${widget.recipe.title}을(를) 완성했어요! 🍳',
      );

      // 공유 결과에 따라 메시지 표시 (선택사항)
      if (mounted && result.status == ShareResultStatus.success) {
        // 성공 메시지는 표시하지 않음 (사용자 경험 개선)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('공유가 완료되었습니다!')),
        // );
      }
    } catch (e) {
      // 실제 오류가 발생한 경우에만 에러 메시지 표시
      if (mounted) {
        CustomSnackBar.showError(context, '공유하기에 실패했습니다: $e');
      }
    }
  }

  // 사진 선택 처리
  Future<void> _onPhotoOptionTap(bool isRecipePhoto) async {
    setState(() {
      _isRecipePhotoSelected = isRecipePhoto;
    });

    if (!isRecipePhoto) {
      // 직접 촬영 옵션 선택 시 갤러리/카메라 선택 다이얼로그 표시
      _showImagePickerDialog();
    }
  }

  // 이미지 선택 다이얼로그
  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '사진 선택',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('카메라'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo_library),
                    label: Text('갤러리'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[500],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // 이미지 선택 처리
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, '이미지 선택에 실패했습니다: $e');
      }
    }
  }
}
