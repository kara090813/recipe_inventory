// lib/screens/badgeCollection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import '../widgets/_widgets.dart';

// 뱃지 모델 (확장됨)
class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final BadgeCategory category; // 뱃지 종류
  final BadgeDifficulty difficulty; // 뱃지 난이도
  final bool isUnlocked;
  final bool isSelected;
  final int currentProgress;
  final int maxProgress;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.difficulty,
    required this.isUnlocked,
    this.isSelected = false,
    this.currentProgress = 0,
    this.maxProgress = 100,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    BadgeCategory? category,
    BadgeDifficulty? difficulty,
    bool? isUnlocked,
    bool? isSelected,
    int? currentProgress,
    int? maxProgress,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isSelected: isSelected ?? this.isSelected,
      currentProgress: currentProgress ?? this.currentProgress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
}

// 뱃지 카테고리 enum
enum BadgeCategory {
  count('요리 횟수', '🏅', 'count'),
  continuous('연속 요리', '🔁', 'continuous'),
  difficulty('난이도', '🎯', 'difficulty'),
  type('레시피 타입', '🍱', 'type'),
  time('요리 시간', '⏰', 'time'),
  special('스페셜', '🌟', 'spec');

  const BadgeCategory(this.displayName, this.icon, this.folderName);
  final String displayName;
  final String icon;
  final String folderName;
}

// 뱃지 난이도 enum
enum BadgeDifficulty {
  weak('약불', '🔥', Color(0xFF4CAF50)),
  medium('중불', '🔥🔥', Color(0xFFFF9800)),
  strong('강불', '🔥🔥🔥', Color(0xFFFF5722)),
  hell('지옥불', '🔥🔥🔥🔥', Color(0xFF9C27B0));

  const BadgeDifficulty(this.displayName, this.icon, this.color);
  final String displayName;
  final String icon;
  final Color color;
}

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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  // 더미 데이터 (확장됨)
  List<Badge> _badges = [
    Badge(
      id: '1',
      name: '열정적인 주방장',
      description: '2일연속 요리성공',
      imagePath: 'assets/imgs/badge/continuous/continuous1.png',
      category: BadgeCategory.continuous,
      difficulty: BadgeDifficulty.weak,
      isUnlocked: true,
      isSelected: true,
      currentProgress: 100,
      maxProgress: 100,
    ),
    Badge(
      id: '2',
      name: '한식의 대가',
      description: '한식 10종 요리 달성',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      category: BadgeCategory.type,
      difficulty: BadgeDifficulty.medium,
      isUnlocked: true,
      currentProgress: 100,
      maxProgress: 100,
    ),
    Badge(
      id: '3',
      name: '냉장고 정복자',
      description: '재료 100개 달성',
      imagePath: 'assets/imgs/badge/count/count5.png',
      category: BadgeCategory.count,
      difficulty: BadgeDifficulty.hell,
      isUnlocked: true,
      currentProgress: 100,
      maxProgress: 100,
    ),
    Badge(
      id: '4',
      name: '전설의 요리사',
      description: '모든 뱃지 획득',
      imagePath: 'assets/imgs/badge/spec/collector.png',
      category: BadgeCategory.special,
      difficulty: BadgeDifficulty.hell,
      isUnlocked: false,
      currentProgress: 15,
      maxProgress: 30,
    ),
    Badge(
      id: '5',
      name: '신입 요리사',
      description: '첫 요리 완성',
      imagePath: 'assets/imgs/badge/count/count1.png',
      category: BadgeCategory.count,
      difficulty: BadgeDifficulty.weak,
      isUnlocked: false,
      currentProgress: 0,
      maxProgress: 1,
    ),
    Badge(
      id: '6',
      name: '다국적 셰프',
      description: '중, 양, 일식 3종 도전',
      imagePath: 'assets/imgs/badge/type/western1.png',
      category: BadgeCategory.type,
      difficulty: BadgeDifficulty.strong,
      isUnlocked: true,
      currentProgress: 100,
      maxProgress: 100,
    ),
    Badge(
      id: '7',
      name: '모닝 셰프',
      description: '오전 7시 이전 15회',
      imagePath: 'assets/imgs/badge/time/morning.png',
      category: BadgeCategory.time,
      difficulty: BadgeDifficulty.medium,
      isUnlocked: false,
      currentProgress: 8,
      maxProgress: 15,
    ),
    Badge(
      id: '8',
      name: '극한 마스터',
      description: '어려움 15개 완료',
      imagePath: 'assets/imgs/badge/difficulty/hard3.png',
      category: BadgeCategory.difficulty,
      difficulty: BadgeDifficulty.strong,
      isUnlocked: false,
      currentProgress: 3,
      maxProgress: 15,
    ),
  ];

  // 메인 뱃지 가져오기
  Badge? get _mainBadge {
    try {
      return _badges.firstWhere((badge) => badge.isSelected);
    } catch (e) {
      return null;
    }
  }

  // 필터링된 뱃지 리스트
  List<Badge> get _filteredBadges {
    List<Badge> filtered = _badges;

    // 카테고리 필터링
    if (_selectedCategory != null) {
      filtered = filtered.where((badge) => badge.category == _selectedCategory).toList();
    }

    // 난이도 필터링
    if (_selectedDifficulty != null) {
      filtered = filtered.where((badge) => badge.difficulty == _selectedDifficulty).toList();
    }

    // 상태별 필터링
    switch (_selectedTabIndex) {
      case 0: // 전체
        break;
      case 1: // 획득
        filtered = filtered.where((badge) => badge.isUnlocked).toList();
        break;
      case 2: // 진행중
        filtered = filtered.where((badge) => !badge.isUnlocked).toList();
        break;
    }

    // 선택된 뱃지를 맨 앞으로 정렬
    filtered.sort((a, b) {
      if (a.isSelected && !b.isSelected) return -1;
      if (!a.isSelected && b.isSelected) return 1;
      return 0;
    });

    return filtered;
  }

  // 각 탭별 개수
  int get _totalCount => _getCountByFilter(_badges);
  int get _unlockedCount => _getCountByFilter(_badges.where((badge) => badge.isUnlocked).toList());
  int get _progressCount => _getCountByFilter(_badges.where((badge) => !badge.isUnlocked).toList());

  int _getCountByFilter(List<Badge> badges) {
    List<Badge> filtered = badges;

    if (_selectedCategory != null) {
      filtered = filtered.where((badge) => badge.category == _selectedCategory).toList();
    }

    if (_selectedDifficulty != null) {
      filtered = filtered.where((badge) => badge.difficulty == _selectedDifficulty).toList();
    }

    return filtered.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  _buildHeader(),
                  SizedBox(height: 10.h),
                  DottedBarWidget(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),

            // 상태 탭바
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildStatusSelector(),
            ),

            SizedBox(height: 12.h),

            // 스마트 필터 영역 (접을 수 있음)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSmartFilter(),
            ),

            SizedBox(height: 16.h),

            // 뱃지 리스트
            Expanded(child: _buildBadgeList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final mainBadge = _mainBadge;

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
                '${_badges.where((b) => b.isUnlocked).length}/${_badges.length} 획득',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.sp,
                  fontFamily: 'Mapo',
                ),
              ),
            ],
          ),
        ),

        // 메인 뱃지
        Container(
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
                child: mainBadge != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    mainBadge.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.emoji_events,
                        color: Color(0xFFFF8B27),
                        size: 32.w,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.add,
                  color: Color(0xFF999999),
                  size: 32.w,
                ),
              ),
              if (mainBadge != null)
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
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
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
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
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
          _buildTab('전체', 0, _totalCount),
          _buildTab('획득', 1, _unlockedCount),
          _buildTab('진행중', 2, _progressCount),
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
          // 필터 헤더 (항상 보임)
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
                  // 필터 아이콘
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF8B27),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 18.w,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 필터 정보
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

                  // 필터 개수 표시
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

                  // 화살표
                  AnimatedRotation(
                    turns: _isFilterExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF7D674B),
                      size: 20.w,
                    ),
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
                  // 구분선
                  Container(
                    height: 1,
                    color: Color(0xFFE8DCC8),
                    margin: EdgeInsets.only(bottom: 16.h),
                  ),

                  // 뱃지 종류 필터
                  _buildCategoryFilter(),

                  SizedBox(height: 16.h),

                  // 뱃지 난이도 필터
                  _buildDifficultyFilter(),

                  SizedBox(height: 12.h),

                  // 필터 리셋 버튼
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
                      // 카테고리 변경 시 난이도 필터 초기화
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
                        Text(
                          category.icon,
                          style: TextStyle(fontSize: 14.sp),
                        ),
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
                    Text(
                      difficulty.icon,
                      style: TextStyle(fontSize: 12.sp),
                    ),
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
        icon: Icon(
          Icons.refresh,
          size: 16.w,
          color: Color(0xFF666666),
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
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

  Widget _buildBadgeList() {
    final filteredBadges = _filteredBadges;

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
        padding: EdgeInsets.only(bottom: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.85,
        ),
        itemCount: filteredBadges.length,
        itemBuilder: (context, index) {
          final badge = filteredBadges[index];
          return _buildBadgeCard(badge, index);
        },
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge, int index) {
    final imagePath = badge.isUnlocked
        ? badge.imagePath
        : badge.imagePath.replaceAll('.png', '_disable.png');

    return GestureDetector(
      onTap: () {
        _showBadgeDetailPopup(badge);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? Color(0xFFFAF0E6) // 활성화된 뱃지 - 주황톤 베이지
              : Color(0xFFF0F0F0), // 비활성화된 뱃지 - 회색톤
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: badge.isSelected
                ? Color(0xFFFF8B27)
                : badge.isUnlocked
                ? Color(0xFFBB885E)
                : Color(0xFFCCCCCC), // 비활성화된 뱃지는 회색 보더
            width: badge.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked
                  ? Colors.grey.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.4), // 비활성화된 뱃지는 연한 섀도우
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
              padding: EdgeInsets.all(8.w), // 패딩 최소화
              child: Column(
                children: [
                  // 뱃지 이미지 (배경 제거, 크기 확대)
                  Container(
                    width: double.infinity,
                    height: 120.h, // 고정 높이 설정
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 뱃지 이미지 (더 큰 크기)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.emoji_events,
                                color: badge.isUnlocked
                                    ? Color(0xFFFF8B27)
                                    : Color(0xFF999999),
                                size: 70.w, // 뱃지 크기 더 증가
                              );
                            },
                          ),
                        ),
                        // 잠금 오버레이
                        if (!badge.isUnlocked)
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
                                  borderRadius: BorderRadius.circular(30.r), // 원형 유지
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

                  SizedBox(height: 8.h), // 간격 줄임

                  // 구분선 추가
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: badge.isUnlocked
                        ? Color(0xFFE8DCC8).withOpacity(0.6)
                        : Color(0xFFDDDDDD).withOpacity(0.6),
                  ),

                  SizedBox(height: 8.h),

                  // 뱃지 정보 배경
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: badge.isUnlocked
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 뱃지 이름에 하이라이트 효과 적용
                        Stack(
                          children: [
                            if (badge.isUnlocked) // 활성화된 뱃지만 하이라이트
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
                              badge.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: badge.isUnlocked
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
                          badge.description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: badge.isUnlocked
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

            // 선택된 뱃지 표시
            if (badge.isSelected && badge.isUnlocked)
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

            // 첫 번째 뱃지 (선택된 뱃지) 표시
            if (index == 0 && badge.isSelected)
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

  // 뱃지 상세 팝업 (기존과 동일하지만 난이도 정보 추가)
  void _showBadgeDetailPopup(Badge badge) {
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
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      badge.isUnlocked ? badge.imagePath : badge.imagePath.replaceAll('.png', '_disable.png'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: badge.isUnlocked ? Color(0xFFFF8B27) : Color(0xFF999999),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 70.w,
                          ),
                        );
                      },
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
                            Text(badge.category.icon, style: TextStyle(fontSize: 10.sp)),
                            SizedBox(width: 4.w),
                            Text(
                              badge.category.displayName,
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
                          color: badge.difficulty.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: badge.difficulty.color, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(badge.difficulty.icon, style: TextStyle(fontSize: 10.sp)),
                            SizedBox(width: 4.w),
                            Text(
                              badge.difficulty.displayName,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: badge.difficulty.color,
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
                        badge.name,
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
                  badge.description,
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
                            '${((badge.currentProgress / badge.maxProgress) * 100).round()}%',
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

                      _buildProgressBarWithPointer(badge),

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
                            '${badge.maxProgress}',
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

                      if (badge.isUnlocked)
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0; i < _badges.length; i++) {
                                  _badges[i] = _badges[i].copyWith(isSelected: false);
                                }

                                final badgeIndex = _badges.indexWhere((b) => b.id == badge.id);
                                if (badgeIndex != -1) {
                                  _badges[badgeIndex] = _badges[badgeIndex].copyWith(isSelected: true);
                                }
                              });

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '메인 뱃지가 "${badge.name}"로 설정되었습니다!',
                                    style: TextStyle(fontFamily: 'Mapo'),
                                  ),
                                  backgroundColor: Color(0xFF4CAF50),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF8B27),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '메인뱃지로 선택하기',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Mapo',
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildProgressBarWithPointer(Badge badge) {
    final double progressRatio = badge.maxProgress > 0
        ? (badge.currentProgress / badge.maxProgress).clamp(0.0, 1.0)
        : 0.0;

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
                  border: Border.all(
                    color: Color(0xFF707070),
                    width: 1.0,
                  ),
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
                    border: Border.all(
                      color: Color(0xFF707070),
                      width: 1.0,
                    ),
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
}