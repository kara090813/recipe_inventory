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

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen> {
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

  final List<String> _badgeTypes = ['전체', '요리마스터', '요리사', '으르신'];

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

    if (_selectedBadgeType != '전체') {
      filtered = filtered.where((badge) => badge.type == _selectedBadgeType).toList();
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

            // 메인 뱃지 영역 (심플하게)
            _buildMainBadgeSection(),

            SizedBox(height: 60.h),

            // 폴더 컨테이너
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    // 폴더 탭들
                    _buildFolderTabs(),

                    // 폴더 내용
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F1E8),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                            topLeft: _selectedTabIndex == 0 ? Radius.zero : Radius.circular(20.r),
                            topRight: _selectedTabIndex == 2 ? Radius.zero : Radius.circular(20.r),
                          ),
                          border: Border.all(color: Color(0xFFD4C4A8), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            // 뱃지 타입 선택기
                            _buildBadgeTypeSelector(),
                            SizedBox(height: 20.h),
                            // 뱃지 리스트
                            Expanded(child: _buildBadgeGrid()),
                          ],
                        ),
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

  Widget _buildFolderTabs() {
    return Row(
      children: [
        _buildFolderTab('전체', 0, _totalCount),
        _buildFolderTab('획득', 1, _unlockedCount),
        _buildFolderTab('진행중', 2, _progressCount),
      ],
    );
  }

  Widget _buildFolderTab(String title, int index, int count) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFF5F1E8) : Color(0xFFE8DCC8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            border: Border(
              top: BorderSide(color: Color(0xFFD4C4A8), width: 1.5),
              left: BorderSide(color: Color(0xFFD4C4A8), width: 1.5),
              right: BorderSide(color: Color(0xFFD4C4A8), width: 1.5),
              bottom: isSelected ? BorderSide.none : BorderSide(color: Color(0xFFD4C4A8), width: 1.5),
            ),
          ),
          child: Center(
            child: Text(
              '$title($count)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Color(0xFF7D674B) : Color(0xFF999999),
                fontFamily: 'Mapo',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeTypeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: _badgeTypes.map((type) {
          final isSelected = _selectedBadgeType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBadgeType = type;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Color(0xFFBB885E),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Color(0xFFBB885E),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Color(0xFF7D674B) : Colors.white,
                      fontFamily: 'Mapo',
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 20.h,
          childAspectRatio: 0.7,
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFFE8DCC8), width: 1.5),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // 뱃지 이미지 (큼직하게)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: badge.isUnlocked ? Color(0xFFFF8B27) : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 30.w,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // 뱃지 이름 (형광펜 효과)
            Stack(
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
                  badge.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Mapo',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // 뱃지 설명 (작게)
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 10.sp,
                color: badge.isUnlocked ? Color(0xFF666666) : Colors.grey[500],
                fontFamily: 'Mapo',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}