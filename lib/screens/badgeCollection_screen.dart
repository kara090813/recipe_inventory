// lib/screens/badge_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/_widgets.dart';

// 뱃지 모델 (임시)
class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String type;
  final bool isUnlocked;
  final bool isSelected; // 메인 뱃지로 선택되었는지

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

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _selectedBadgeType = '전체';

  // 더미 데이터
  final List<Badge> _badges = [
    Badge(
      id: '1',
      name: '열정적인 주방장',
      description: '2일연속 요리성공',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '요리마스터',
      isUnlocked: true,
      isSelected: true,
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
      name: '전설의 요리사',
      description: '모든 뱃지 획득',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '셰프',
      isUnlocked: false,
    ),
    Badge(
      id: '6',
      name: '다국적 셰프',
      description: '중, 양, 일식 3종 도전',
      imagePath: 'assets/imgs/badge/type/korean1.png',
      type: '셰프',
      isUnlocked: true,
    ),
  ];

  final List<String> _badgeTypes = ['전체', '요리마스터', '요리사', '셰프'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 메인 뱃지 가져오기
  Badge get _mainBadge {
    return _badges.firstWhere(
          (badge) => badge.isSelected,
      orElse: () => _badges.first,
    );
  }

  // 필터링된 뱃지 리스트
  List<Badge> get _filteredBadges {
    List<Badge> filtered = _badges;

    // 타입 필터링
    if (_selectedBadgeType != '전체') {
      filtered = filtered.where((badge) => badge.type == _selectedBadgeType).toList();
    }

    // 탭 필터링
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
  int get _totalCount => _selectedBadgeType == '전체'
      ? _badges.length
      : _badges.where((badge) => badge.type == _selectedBadgeType).length;

  int get _unlockedCount => _selectedBadgeType == '전체'
      ? _badges.where((badge) => badge.isUnlocked).length
      : _badges.where((badge) => badge.type == _selectedBadgeType && badge.isUnlocked).length;

  int get _progressCount => _selectedBadgeType == '전체'
      ? _badges.where((badge) => !badge.isUnlocked).length
      : _badges.where((badge) => badge.type == _selectedBadgeType && !badge.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              color: Color(0xFFF5F5F5),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  _buildHeader(),
                  SizedBox(height: 10.h),
                  DottedBarWidget(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // 메인 뱃지 영역
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildMainBadgeSection(),
            ),

            SizedBox(height: 30.h),

            // 뱃지 타입 드롭다운
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildBadgeTypeDropdown(),
            ),

            SizedBox(height: 16.h),

            // 탭바
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildTabBar(),
            ),

            SizedBox(height: 16.h),

            // 뱃지 리스트
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildBadgeGrid(),
              ),
            ),
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
            ),
          ),
        ),
        SizedBox(width: 46.w), // BackButton과 균형 맞추기
      ],
    );
  }

  Widget _buildMainBadgeSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFFBB885E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFBB885E).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 메인 뱃지 이미지와 선택 효과
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFFF8B27),
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF8B27).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFE0B2),
                      Color(0xFFFFF3E6),
                    ],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    _mainBadge.imagePath,
                    width: 80.w,
                    height: 80.w,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8B27),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 40.w,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 뱃지 이름
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFFFF8B27),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _mainBadge.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mapo',
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // 뱃지 설명
          Text(
            _mainBadge.description,
            style: TextStyle(
              color: Color(0xFF7D674B),
              fontSize: 14.sp,
              fontFamily: 'Mapo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFBB885E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedBadgeType,
        isExpanded: true,
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF7D674B)),
        style: TextStyle(
          color: Color(0xFF7D674B),
          fontSize: 16.sp,
          fontFamily: 'Mapo',
        ),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedBadgeType = newValue;
            });
          }
        },
        items: _badgeTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Color(0xFF7D674B),
          borderRadius: BorderRadius.circular(20.r),
        ),
        indicatorPadding: EdgeInsets.all(2.w),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF999999),
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Mapo',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontFamily: 'Mapo',
        ),
        tabs: [
          Tab(text: '전체 ($_totalCount)'),
          Tab(text: '획득 ($_unlockedCount)'),
          Tab(text: '진행중 ($_progressCount)'),
        ],
      ),
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

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredBadges.length,
      itemBuilder: (context, index) {
        final badge = filteredBadges[index];
        return _buildBadgeCard(badge);
      },
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    final isSelected = badge.isSelected;

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Color(0xFFFF8B27) : Color(0xFFE0E0E0),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Color(0xFFFF8B27).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 뱃지 이미지
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? (isSelected ? Color(0xFFFFE0B2) : Color(0xFFF5F5F5))
                    : Colors.grey[300],
              ),
              child: Center(
                child: badge.isUnlocked
                    ? Image.asset(
                  badge.imagePath,
                  width: 40.w,
                  height: 40.w,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events,
                      color: isSelected ? Color(0xFFFF8B27) : Color(0xFF7D674B),
                      size: 30.w,
                    );
                  },
                )
                    : Icon(
                  Icons.lock,
                  color: Colors.grey[600],
                  size: 30.w,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // 뱃지 이름
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                badge.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: badge.isUnlocked
                      ? (isSelected ? Color(0xFFFF8B27) : Color(0xFF333333))
                      : Colors.grey[600],
                  fontFamily: 'Mapo',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 4.h),

            // 뱃지 설명
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                badge.description,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: badge.isUnlocked ? Colors.grey[700] : Colors.grey[500],
                  fontFamily: 'Mapo',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 선택 표시
            if (isSelected && badge.isUnlocked) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Color(0xFFFF8B27),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '선택됨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mapo',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}