// lib/screens/badgeCollection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import '../widgets/_widgets.dart';

// 뱃지 모델
class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String type;
  final bool isUnlocked;
  final bool isSelected;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.type,
    required this.isUnlocked,
    this.isSelected = false,
  });
}

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({Key? key}) : super(key: key);

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  Set<String> _selectedBadgeTypes = {'전체'}; // 토글식으로 변경
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // 더미 데이터
  final List<Badge> _badges = [
    Badge(
      id: '1',
      name: '열정적인 주방장',
      description: '2일연속 요리성공',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요리마스터',
      isUnlocked: true,
    ),
    Badge(
      id: '2',
      name: '한식의 대가',
      description: '한식 10종 요리 달성',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요리마스터',
      isUnlocked: true,
    ),
    Badge(
      id: '3',
      name: '냉장고 정복자',
      description: '재료 100개 달성',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요리사',
      isUnlocked: true,
    ),
    Badge(
      id: '4',
      name: '전설의 요리사',
      description: '모든 뱃지 획득',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요리사',
      isUnlocked: false,
    ),
    Badge(
      id: '5',
      name: '신입 요리사',
      description: '첫 요리 완성',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요린이',
      isUnlocked: false,
    ),
    Badge(
      id: '6',
      name: '다국적 셰프',
      description: '중, 양, 일식 3종 도전',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요르신',
      isUnlocked: true,
    ),
  ];

  final List<String> _badgeTypes = ['전체', '요리사', '요린이', '요르신'];

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

    // 토글식 필터링
    if (!_selectedBadgeTypes.contains('전체')) {
      filtered = filtered.where((badge) =>
          _selectedBadgeTypes.contains(badge.type)).toList();
    }

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

    return filtered;
  }

  // 각 탭별 개수
  int get _totalCount => _getCountByFilter(_badges);
  int get _unlockedCount => _getCountByFilter(_badges.where((badge) => badge.isUnlocked).toList());
  int get _progressCount => _getCountByFilter(_badges.where((badge) => !badge.isUnlocked).toList());

  int _getCountByFilter(List<Badge> badges) {
    if (_selectedBadgeTypes.contains('전체')) {
      return badges.length;
    }
    return badges.where((badge) => _selectedBadgeTypes.contains(badge.type)).length;
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
                  SizedBox(height: 40.h),
                ],
              ),
            ),

            // 메인 뱃지 영역 (포인트 카드)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF8F0), Color(0xFFF0E6D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7D674B).withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Color(0xFFE8DCC8).withOpacity(0.5)),
              ),
              padding: EdgeInsets.symmetric(vertical: 35.h),
              child: _buildMainBadgeSection(),
            ),

            SizedBox(height: 30.h),

            // 컨트롤 영역 (포인트 카드)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Color(0xFFE8DCC8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // 모던한 상태 선택기
                  _buildModernStatusSelector(),
                  SizedBox(height: 20.h),
                  // 토글식 뱃지 타입 선택기
                  _buildToggleBadgeTypeSelector(),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // 뱃지 그리드 영역
            Expanded(child: _buildBadgeGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        BackButtonWidget(context),
        Expanded(
          child: Text(
            '뱃지 컬렉션',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7D674B),
              fontSize: 20.sp,
              fontFamily: 'Mapo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 46.w),
      ],
    );
  }

  Widget _buildMainBadgeSection() {
    final mainBadge = _mainBadge;

    return Column(
      children: [
        // 메인 뱃지 (심플한 도트 원형 + 물음표)
        DottedBorder(
          borderType: BorderType.Circle,
          dashPattern: [12, 8],
          color: Color(0xFFBB885E),
          strokeWidth: 3,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Color(0xFFBB885E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // 설명 텍스트
        Text(
          '메인 뱃지를 선택해주세요!',
          style: TextStyle(
            fontSize: 16.sp,
            color: Color(0xFF666666),
            fontFamily: 'Mapo',
          ),
        ),
      ],
    );
  }

  // 모던한 상태 선택기 (세그먼트 컨트롤 스타일)
  Widget _buildModernStatusSelector() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: Color(0xFFE8DCC8), width: 1.5),
      ),
      child: Row(
        children: [
          _buildModernTab('전체', 0, _totalCount),
          _buildModernTab('획득', 1, _unlockedCount),
          _buildModernTab('진행중', 2, _progressCount),
        ],
      ),
    );
  }

  Widget _buildModernTab(String title, int index, int count) {
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
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(21.r),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Color(0xFF7D674B).withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Color(0xFF7D674B) : Color(0xFF999999),
                fontFamily: 'Mapo',
              ),
              child: Text('$title ($count)'),
            ),
          ),
        ),
      ),
    );
  }

  // 토글식 뱃지 타입 선택기
  Widget _buildToggleBadgeTypeSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _badgeTypes.map((type) {
        final isSelected = _selectedBadgeTypes.contains(type);
        final isAll = type == '전체';

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isAll) {
                // 전체 선택 시 다른 모든 선택 해제
                _selectedBadgeTypes.clear();
                _selectedBadgeTypes.add('전체');
              } else {
                if (_selectedBadgeTypes.contains('전체')) {
                  // 전체가 선택되어 있으면 전체 해제하고 현재 타입 선택
                  _selectedBadgeTypes.clear();
                  _selectedBadgeTypes.add(type);
                } else {
                  // 토글
                  if (isSelected) {
                    _selectedBadgeTypes.remove(type);
                    // 아무것도 선택되지 않으면 전체 선택
                    if (_selectedBadgeTypes.isEmpty) {
                      _selectedBadgeTypes.add('전체');
                    }
                  } else {
                    _selectedBadgeTypes.add(type);
                  }
                }
              }
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(
                colors: [Color(0xFFFF8B27), Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? Color(0xFFFF8B27) : Color(0xFFE8DCC8),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Color(0xFFFF8B27).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF7D674B),
                fontFamily: 'Mapo',
              ),
              child: Text(type),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadgeGrid() {
    final filteredBadges = _filteredBadges;

    if (filteredBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '해당하는 뱃지가 없습니다',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 16.sp,
                fontFamily: 'Mapo',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2열로 변경
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 20.h,
          childAspectRatio: 1.0, // 비율 조정 (정사각형에 가깝게)
        ),
        itemCount: filteredBadges.length,
        itemBuilder: (context, index) {
          final badge = filteredBadges[index];
          return _buildBadgeCard(badge);
        },
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    final imagePath = badge.isUnlocked
        ? badge.imagePath
        : badge.imagePath.replaceAll('.png', '_disable.png');

    return GestureDetector(
      onTap: () {
        if (badge.isUnlocked) {
          setState(() {
            // 기존 선택 해제
            for (int i = 0; i < _badges.length; i++) {
              if (_badges[i].isSelected) {
                _badges[i] = Badge(
                  id: _badges[i].id,
                  name: _badges[i].name,
                  description: _badges[i].description,
                  imagePath: _badges[i].imagePath,
                  type: _badges[i].type,
                  isUnlocked: _badges[i].isUnlocked,
                  isSelected: false,
                );
              }
            }

            // 새로운 뱃지 선택
            final badgeIndex = _badges.indexWhere((b) => b.id == badge.id);
            if (badgeIndex != -1) {
              _badges[badgeIndex] = Badge(
                id: badge.id,
                name: badge.name,
                description: badge.description,
                imagePath: badge.imagePath,
                type: badge.type,
                isUnlocked: badge.isUnlocked,
                isSelected: true,
              );
            }
          });

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
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: badge.isUnlocked ? Color(0xFFE8DCC8) : Color(0xFFE0E0E0),
              width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked
                  ? Color(0xFF7D674B).withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: badge.isUnlocked ? 10 : 5,
              offset: Offset(0, badge.isUnlocked ? 5 : 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(6.w), // 패딩 더 줄임
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 뱃지 이미지 (더욱 크게)
            Expanded(
              flex: 6, // 더 큰 비율로 확장
              child: Container(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 뱃지 이미지만 표시 (배경 제거)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: badge.isUnlocked ? Color(0xFFFF8B27) : Colors.grey[400],
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 60.w, // 아이콘도 더 크게
                            ),
                          );
                        },
                      ),
                    ),
                    // 잠금 오버레이 (뱃지 이미지 위에만)
                    if (!badge.isUnlocked)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 50.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // 뱃지 이름 (형광펜 효과 적용)
            Container(
              height: 28.h, // 고정 높이로 위치 일치
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -1,
                    child: Container(
                      height: 12.h,
                      color: Color(0xFFFFD8A8),
                    ),
                  ),
                  Text(
                    badge.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked ? Colors.black : Colors.grey[600],
                      fontFamily: 'Mapo',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // 뱃지 설명 (위치 고정, ... 처리)
            Container(
              height: 18.h, // 고정 높이로 위치 일치
              alignment: Alignment.center,
              child: Text(
                badge.description,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: badge.isUnlocked ? Color(0xFF999999) : Colors.grey[500],
                  fontFamily: 'Mapo',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // ... 처리
              ),
            ),
          ],
        ),
      ),
    );
  }
}