// lib/screens/badgeCollection_screen.dart
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/_widgets.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../funcs/_funcs.dart';
import '../utils/custom_snackbar.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({Key? key}) : super(key: key);

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  BadgeCategory? _selectedCategory;
  BadgeDifficulty? _selectedDifficulty;
  bool _isFilterExpanded = false;

  late AnimationController _pulseController;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // 성능 최적화를 위한 ScrollController
  late ScrollController _scrollController;

  // 이미지 캐시 최적화
  final Set<String> _preloadedImages = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController = ScrollController();

    // 뱃지 상태 초기화 후 이미지 프리로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadVisibleImages();
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _expandController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 이미지 프리로딩 최적화
  void _preloadVisibleImages() {
    final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
    final visibleBadges = _getFilteredBadges(badgeStatus).take(20); // 처음 20개만 프리로드

    for (final combinedBadge in visibleBadges) {
      final imagePath = _getImagePath(combinedBadge);
      if (!_preloadedImages.contains(imagePath)) {
        _preloadImage(imagePath);
        _preloadedImages.add(imagePath);
      }
    }
  }

  void _preloadImage(String imagePath) {
    try {
      final image = AssetImage(imagePath);
      precacheImage(image, context);
    } catch (e) {
      print('Failed to preload image: $imagePath');
    }
  }

  // 뱃지와 진행도를 합친 데이터 구조 (BadgeStatus를 매개변수로 받음)
  List<CombinedBadgeData> _getFilteredBadges(BadgeStatus badgeStatus) {
    final badges = badgeStatus.badges;
    final userProgressList = badgeStatus.userBadgeProgressList;
    final mainBadge = badgeStatus.mainBadge;

    // Badge와 UserBadgeProgress를 결합
    List<CombinedBadgeData> combinedData = badges.map((badge) {
      final progress = userProgressList.firstWhere(
            (p) => p.badgeId == badge.id,
        orElse: () => UserBadgeProgress(
          badgeId: badge.id,
          currentProgress: 0,
          isUnlocked: false,
        ),
      );

      final isMainBadge = mainBadge?.badgeId == badge.id;

      return CombinedBadgeData(
        badge: badge,
        progress: progress,
        isMainBadge: isMainBadge,
      );
    }).toList();

    // 필터링 적용
    List<CombinedBadgeData> filtered = combinedData;

    // 카테고리 필터링
    if (_selectedCategory != null) {
      filtered = filtered.where((data) => data.badge.category == _selectedCategory).toList();
    }

    // 난이도 필터링
    if (_selectedDifficulty != null) {
      filtered = filtered.where((data) => data.badge.difficulty == _selectedDifficulty).toList();
    }

    // 상태별 필터링
    switch (_selectedTabIndex) {
      case 0: // 전체
        break;
      case 1: // 획득
        filtered = filtered.where((data) => data.progress.isUnlocked).toList();
        break;
      case 2: // 진행중
        filtered = filtered.where((data) => !data.progress.isUnlocked).toList();
        break;
    }

    // 정렬: 메인 뱃지 > 잠금 해제된 뱃지 > 진행도 순 > sortOrder 순
    filtered.sort((a, b) {
      // 1. 메인 뱃지 우선
      if (a.isMainBadge && !b.isMainBadge) return -1;
      if (!a.isMainBadge && b.isMainBadge) return 1;

      // 2. 잠금 해제 여부
      if (a.progress.isUnlocked && !b.progress.isUnlocked) return -1;
      if (!a.progress.isUnlocked && b.progress.isUnlocked) return 1;

      // 3. 진행도 (높은 순)
      final progressDiff = b.progress.currentProgress.compareTo(a.progress.currentProgress);
      if (progressDiff != 0) return progressDiff;

      // 4. sortOrder
      return a.badge.sortOrder.compareTo(b.badge.sortOrder);
    });

    return filtered;
  }

  // 메인 뱃지 데이터 가져오기 (필터와 무관하게)
  CombinedBadgeData? _getMainBadgeData(BadgeStatus badgeStatus) {
    final badges = badgeStatus.badges;
    final userProgressList = badgeStatus.userBadgeProgressList;
    final mainBadge = badgeStatus.mainBadge;
    
    if (mainBadge == null) return null;
    
    try {
      final badge = badges.firstWhere((b) => b.id == mainBadge.badgeId);
      final progress = userProgressList.firstWhere(
        (p) => p.badgeId == badge.id,
        orElse: () => UserBadgeProgress(
          badgeId: badge.id,
          currentProgress: 0,
          isUnlocked: false,
        ),
      );
      
      return CombinedBadgeData(
        badge: badge,
        progress: progress,
        isMainBadge: true,
      );
    } catch (e) {
      return null;
    }
  }

  // 각 탭별 개수 계산 (성능 최적화)
  Map<String, int> _getTabCounts(BadgeStatus badgeStatus) {
    final badges = badgeStatus.badges;
    final userProgressList = badgeStatus.userBadgeProgressList;

    List<CombinedBadgeData> allData = badges.map((badge) {
      final progress = userProgressList.firstWhere(
            (p) => p.badgeId == badge.id,
        orElse: () => UserBadgeProgress(badgeId: badge.id),
      );
      return CombinedBadgeData(badge: badge, progress: progress);
    }).toList();

    // 카테고리/난이도 필터 적용
    if (_selectedCategory != null) {
      allData = allData.where((data) => data.badge.category == _selectedCategory).toList();
    }
    if (_selectedDifficulty != null) {
      allData = allData.where((data) => data.badge.difficulty == _selectedDifficulty).toList();
    }

    final total = allData.length;
    final unlocked = allData.where((data) => data.progress.isUnlocked).length;
    final inProgress = allData.where((data) => !data.progress.isUnlocked).length;

    return {
      'total': total,
      'unlocked': unlocked,
      'inProgress': inProgress,
    };
  }

  // 이미지 경로 계산 (최적화)
  String _getImagePath(CombinedBadgeData data) {
    if (data.progress.isUnlocked) {
      return data.badge.imagePath;
    } else {
      // _disable.png 파일이 있는지 확인
      final basePath = data.badge.imagePath.replaceAll('.png', '');
      return '${basePath}_disable.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<BadgeStatus>(
          builder: (context, badgeStatus, child) {
            if (badgeStatus.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF8B27)),
                    SizedBox(height: 16.h),
                    Text(
                      '뱃지를 불러오는 중...',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14.sp,
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // 헤더
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      _buildOptimizedHeader(badgeStatus),
                      SizedBox(height: 10.h),
                      DottedBarWidget(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),

                // 상태 탭바
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildOptimizedStatusSelector(badgeStatus),
                ),

                SizedBox(height: 12.h),

                // 스마트 필터 영역
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildSmartFilter(),
                ),

                SizedBox(height: 16.h),

                // 뱃지 리스트
                Expanded(child: _buildOptimizedBadgeList(badgeStatus)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptimizedHeader(BadgeStatus badgeStatus) {
    final mainBadgeData = _getMainBadgeData(badgeStatus);
    final tabCounts = _getTabCounts(badgeStatus);

    return Row(
      children: [
        // 뒤로가기 버튼
        BackButtonWidget(context),

        // 제목과 통계
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '뱃지 컬렉션',
                style: TextStyle(
                  color: Color(0xFF7D674B),
                  fontSize: 20.sp,
                  fontFamily: 'Mapo',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${tabCounts['unlocked']}/${tabCounts['total']} 획득',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.sp,
                  fontFamily: 'Mapo',
                ),
              ),
            ],
          ),
        ),

        // 메인 뱃지 (최적화된 렌더링)
        _buildOptimizedMainBadge(mainBadgeData),
      ],
    );
  }

  Widget _buildOptimizedMainBadge(CombinedBadgeData? mainBadgeData) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFFBB885E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFBB885E).withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: mainBadgeData != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: _buildOptimizedImage(
                _getImagePath(mainBadgeData),
                size: 64.w,
              ),
            )
                : Icon(
              Icons.add,
              color: Color(0xFF999999),
              size: 32.w,
            ),
          ),
          if (mainBadgeData != null)
            Positioned(
              top: -2,
              right: -2,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8B27),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12.w,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptimizedStatusSelector(BadgeStatus badgeStatus) {
    final tabCounts = _getTabCounts(badgeStatus);

    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab('전체', 0, tabCounts['total']!),
          _buildTab('획득', 1, tabCounts['unlocked']!),
          _buildTab('진행중', 2, tabCounts['inProgress']!),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, int count) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF7D674B) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Color(0xFF999999),
                fontFamily: 'Mapo',
              ),
              child: Text('$title ($count)'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFE8DCC8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 필터 헤더
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
                if (_isFilterExpanded) {
                  _expandController.forward();
                } else {
                  _expandController.reverse();
                }
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF8B27),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.tune, color: Colors.white, size: 18.w),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상세 필터',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E3009),
                            fontFamily: 'Mapo',
                          ),
                        ),
                        if (_selectedCategory != null || _selectedDifficulty != null)
                          Text(
                            _buildFilterDescription(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Color(0xFF666666),
                              fontFamily: 'Mapo',
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_selectedCategory != null || _selectedDifficulty != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8B27),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_getActiveFilterCount()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mapo',
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isFilterExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF7D674B), size: 20.w),
                  ),
                ],
              ),
            ),
          ),

          // 확장 가능한 필터 영역
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: Color(0xFFE8DCC8),
                    margin: EdgeInsets.only(bottom: 16.h),
                  ),
                  _buildCategoryFilter(),
                  SizedBox(height: 16.h),
                  _buildDifficultyFilter(),
                  SizedBox(height: 12.h),
                  if (_selectedCategory != null || _selectedDifficulty != null)
                    _buildResetButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '뱃지 종류',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5E3009),
            fontFamily: 'Mapo',
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BadgeCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = isSelected ? null : category;
                      if (!isSelected) _selectedDifficulty = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFFF8B27) : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? Color(0xFFFF8B27) : Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getCategoryIcon(category),
                        SizedBox(width: 6.w),
                        Text(
                          category.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Color(0xFF666666),
                            fontFamily: 'Mapo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '뱃지 난이도',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5E3009),
            fontFamily: 'Mapo',
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: BadgeDifficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDifficulty = isSelected ? null : difficulty;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? difficulty.color : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isSelected ? difficulty.color : Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getDifficultyIcon(difficulty),
                    SizedBox(width: 6.w),
                    Text(
                      difficulty.displayName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Color(0xFF666666),
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _selectedCategory = null;
            _selectedDifficulty = null;
          });
        },
        icon: Icon(Icons.refresh, size: 16.w, color: Color(0xFF666666)),
        label: Text(
          '필터 초기화',
          style: TextStyle(
            fontSize: 12.sp,
            color: Color(0xFF666666),
            fontFamily: 'Mapo',
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFFF5F5F5),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
    );
  }

  String _buildFilterDescription() {
    List<String> parts = [];
    if (_selectedCategory != null) {
      parts.add(_selectedCategory!.displayName);
    }
    if (_selectedDifficulty != null) {
      parts.add(_selectedDifficulty!.displayName);
    }
    return parts.join(' • ');
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedDifficulty != null) count++;
    return count;
  }

  Widget _buildOptimizedBadgeList(BadgeStatus badgeStatus) {
    final filteredBadges = _getFilteredBadges(badgeStatus);

    if (filteredBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/imgs/items/empty_logo.png',
              width: 80.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '해당하는 뱃지가 없습니다',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 14.sp,
                fontFamily: 'Mapo',
              ),
            ),
            if (_selectedCategory != null || _selectedDifficulty != null) ...[
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedDifficulty = null;
                  });
                },
                child: Text(
                  '필터 초기화',
                  style: TextStyle(
                    color: Color(0xFFFF8B27),
                    fontSize: 12.sp,
                    fontFamily: 'Mapo',
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.85,
        ),
        itemCount: filteredBadges.length,
        cacheExtent: 1000, // 성능 최적화: 캐시 범위 설정
        itemBuilder: (context, index) {
          final combinedBadge = filteredBadges[index];
          return _buildOptimizedBadgeCard(combinedBadge, index);
        },
      ),
    );
  }

  Widget _buildOptimizedBadgeCard(CombinedBadgeData data, int index) {
    final imagePath = _getImagePath(data);
    final targetCount = _getTargetCount(data.badge);

    return GestureDetector(
      onTap: () => _showBadgeDetailPopup(data),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: data.progress.isUnlocked
              ? Color(0xFFFAF0E6)
              : Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: data.isMainBadge
                ? Color(0xFFFF8B27)
                : data.progress.isUnlocked
                ? Color(0xFFBB885E)
                : Color(0xFFCCCCCC),
            width: data.isMainBadge ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: data.progress.isUnlocked
                  ? Colors.grey.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 메인 컨텐츠
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  // 뱃지 이미지
                  Container(
                    width: double.infinity,
                    height: 120.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildOptimizedImage(imagePath, size: 120.h),
                        // 잠금 오버레이
                        if (!data.progress.isUnlocked)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Center(
                              child: Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Icon(
                                  Icons.lock,
                                  color: Color(0xFF999999),
                                  size: 30.w,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: data.progress.isUnlocked
                        ? Color(0xFFE8DCC8).withOpacity(0.6)
                        : Color(0xFFDDDDDD).withOpacity(0.6),
                  ),

                  SizedBox(height: 8.h),

                  // 뱃지 정보
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: data.progress.isUnlocked
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 뱃지 이름
                        Stack(
                          children: [
                            if (data.progress.isUnlocked)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: -1,
                                child: Container(
                                  height: 8.h,
                                  color: Color(0xFFFFD8A8),
                                ),
                              ),
                            Text(
                              data.badge.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: data.progress.isUnlocked
                                    ? Color(0xFF5E3009)
                                    : Color(0xFF999999),
                                fontFamily: 'Mapo',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          data.badge.description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: data.progress.isUnlocked
                                ? Color(0xFF666666)
                                : Color(0xFF999999),
                            fontFamily: 'Mapo',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 메인 뱃지 표시
            if (data.isMainBadge && data.progress.isUnlocked)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.2),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8B27),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF8B27).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // MAIN 표시
            if (index == 0 && data.isMainBadge)
              Positioned(
                top: 8.w,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF8B27),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF8B27).withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'MAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mapo',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 최적화된 이미지 위젯
  Widget _buildOptimizedImage(String imagePath, {double? size}) {
    return Container(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load image: $imagePath');
          return Icon(
            Icons.emoji_events,
            color: Color(0xFFFF8B27),
            size: size != null ? size * 0.6 : 40.w,
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
    );
  }

  // 뱃지의 목표 수치 반환
  int _getTargetCount(Badge badge) {
    switch (badge.condition.type) {
      case BadgeType.totalCookingCount:
        return badge.condition.targetCookingCount ?? 1;
      case BadgeType.consecutiveCooking:
        return badge.condition.consecutiveDays ?? 1;
      case BadgeType.difficultyBasedCooking:
        return badge.condition.difficultyCount ?? 1;
      case BadgeType.recipeTypeCooking:
        return badge.condition.recipeTypeCount ?? 1;
      case BadgeType.timeBasedCooking:
        return badge.condition.timeBasedCount ?? 1;
      case BadgeType.wishlistCollection:
        return badge.condition.wishlistCount ?? 1;
      case BadgeType.recipeRetry:
        return badge.condition.sameRecipeRetryCount ?? 1;
    }
  }

  // 뱃지 상세 팝업 (최적화된 버전)
  void _showBadgeDetailPopup(CombinedBadgeData data) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),

                // 큰 뱃지 이미지
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: _buildOptimizedImage(
                      _getImagePath(data),
                      size: 140.w,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // 뱃지 카테고리 + 난이도
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 카테고리
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8DCC8),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getCategoryIcon(data.badge.category, size: 10.sp),
                            SizedBox(width: 4.w),
                            Text(
                              data.badge.category.displayName,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E3009),
                                fontFamily: 'Mapo',
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // 난이도
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: data.badge.difficulty.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: data.badge.difficulty.color, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getDifficultyIcon(data.badge.difficulty, size: 10.sp),
                            SizedBox(width: 4.w),
                            Text(
                              data.badge.difficulty.displayName,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: data.badge.difficulty.color,
                                fontFamily: 'Mapo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // 뱃지 이름
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE8CB),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -1,
                        child: Container(
                          height: 10.h,
                          color: Color(0xFFFFD8A8),
                        ),
                      ),
                      Text(
                        data.badge.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3009),
                          fontFamily: 'Mapo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // 뱃지 설명
                Text(
                  data.badge.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF666666),
                    fontFamily: 'Mapo',
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30.h),

                // 진행도 바
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${_calculateProgressPercentage(data).round()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mapo',
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      _buildProgressBarWithPointer(data),

                      SizedBox(height: 8.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF666666),
                              fontFamily: 'Mapo',
                            ),
                          ),
                          Text(
                            '${_getTargetCount(data.badge)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF666666),
                              fontFamily: 'Mapo',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // 버튼들
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE0E0E0),
                            foregroundColor: Color(0xFF666666),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '뒤로가기',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mapo',
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      if (data.progress.isUnlocked) ...[
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
                              final success = await badgeStatus.setMainBadge(data.badge.id);

                              Navigator.of(context).pop();

                              if (success) {
                                CustomSnackBar.showSuccess(context, '메인 뱃지가 "${data.badge.name}"로 설정되었습니다!');
                              } else {
                                CustomSnackBar.showError(context, '메인 뱃지 설정에 실패했습니다.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: data.isMainBadge ? Color(0xFFE0E0E0) : Color(0xFFFF8B27),
                              foregroundColor: data.isMainBadge ? Color(0xFF666666) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              data.isMainBadge ? '현재 메인뱃지' : '메인뱃지로 선택하기',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Mapo',
                              ),
                            ),
                          ),
                        ),
                        
                        if (data.isMainBadge) ...[
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
                                final success = await badgeStatus.clearMainBadge();

                                Navigator.of(context).pop();

                                if (success) {
                                  CustomSnackBar.showSuccess(context, '메인 뱃지가 해제되었습니다!');
                                } else {
                                  CustomSnackBar.showError(context, '메인 뱃지 해제에 실패했습니다.');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF4444),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                '메인뱃지 해제하기',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Mapo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateProgressPercentage(CombinedBadgeData data) {
    final targetCount = _getTargetCount(data.badge);
    if (targetCount == 0) return 0.0;
    return (data.progress.currentProgress / targetCount * 100).clamp(0.0, 100.0);
  }

  Widget _buildProgressBarWithPointer(CombinedBadgeData data) {
    final double progressRatio = _calculateProgressPercentage(data) / 100.0;

    String pointerImage;
    Color progressColor;

    if (progressRatio >= 0.8) {
      pointerImage = 'assets/imgs/items/point_pink.png';
      progressColor = Color(0xFFFF1744);
    } else if (progressRatio >= 0.4) {
      pointerImage = 'assets/imgs/items/point_orange.png';
      progressColor = Color(0xFFFF8B27);
    } else {
      pointerImage = 'assets/imgs/items/point_yellow.png';
      progressColor = Color(0xFFFFD700);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double pointerSize = 24.w;
        final double maxPointerPosition = barWidth - pointerSize;
        final double pointerPosition = (progressRatio * maxPointerPosition).clamp(0.0, maxPointerPosition);

        return Container(
          height: 24.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 12.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Color(0xFF707070), width: 1.0),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 12.h,
                  width: barWidth * progressRatio,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Color(0xFF707070), width: 1.0),
                  ),
                ),
              ),
              Positioned(
                left: pointerPosition,
                child: Image.asset(
                  pointerImage,
                  width: pointerSize,
                  height: pointerSize,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: pointerSize,
                      height: pointerSize,
                      decoration: BoxDecoration(
                        color: progressColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 카테고리 아이콘 위젯 반환
  Widget _getCategoryIcon(BadgeCategory category, {double? size}) {
    String imagePath;
    switch (category) {
      case BadgeCategory.count:
        imagePath = 'assets/imgs/icons/badge_count.png';
        break;
      case BadgeCategory.continuous:
        imagePath = 'assets/imgs/icons/badge_continous.png';
        break;
      case BadgeCategory.difficulty:
        imagePath = 'assets/imgs/icons/badge_difficulty.png';
        break;
      case BadgeCategory.type:
        imagePath = 'assets/imgs/icons/badge_type.png';
        break;
      case BadgeCategory.time:
        imagePath = 'assets/imgs/icons/badge_time.png';
        break;
      case BadgeCategory.special:
        imagePath = 'assets/imgs/icons/badge_spec.png';
        break;
    }

    return Image.asset(
      imagePath,
      width: size ?? 14.sp,
      height: size ?? 14.sp,
      errorBuilder: (context, error, stackTrace) {
        return Text(category.icon, style: TextStyle(fontSize: size ?? 14.sp));
      },
    );
  }

  // 난이도 아이콘 위젯 반환
  Widget _getDifficultyIcon(BadgeDifficulty difficulty, {double? size}) {
    String imagePath;
    switch (difficulty) {
      case BadgeDifficulty.weak:
        imagePath = 'assets/imgs/icons/fire1.png';
        break;
      case BadgeDifficulty.medium:
        imagePath = 'assets/imgs/icons/fire2.png';
        break;
      case BadgeDifficulty.strong:
        imagePath = 'assets/imgs/icons/fire3.png';
        break;
      case BadgeDifficulty.hell:
        imagePath = 'assets/imgs/icons/fire4.png';
        break;
    }

    return Image.asset(
      imagePath,
      width: size ?? 12.sp,
      height: size ?? 12.sp,
      errorBuilder: (context, error, stackTrace) {
        return Text(difficulty.icon, style: TextStyle(fontSize: size ?? 12.sp));
      },
    );
  }
}

// 뱃지와 진행도를 합친 데이터 구조
class CombinedBadgeData {
  final Badge badge;
  final UserBadgeProgress progress;
  final bool isMainBadge;

  CombinedBadgeData({
    required this.badge,
    required this.progress,
    this.isMainBadge = false,
  });
}