import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/models/data.dart';

import '../models/_models.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class MyPageComponent extends StatelessWidget {
  const MyPageComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final userStatus = context.watch<UserStatus>();
    final recipeStatus = context.watch<RecipeStatus>();
    final ongoingCooking = userStatus.ongoingCooking;
    final recentHistory = userStatus.cookingHistory.take(3).toList();
    final cookHistoryDays = userStatus.getConsecutiveCookingDays();

    // 실제 UserStatus의 메서드 사용
    final currentLevel = userStatus.currentLevel;
    final currentPoints = userStatus.currentPoints;
    final currentExperience = userStatus.currentExperience;
    final levelProgress = userStatus.calculateCurrentLevelProgress();
    final currentLevelRequiredExp = userStatus.calculateRequiredExpForLevel(currentLevel);
    final nextLevelRequiredExp = userStatus.calculateRequiredExpForLevel(currentLevel + 1);
    final currentLevelExp = currentExperience - currentLevelRequiredExp;
    final nextLevelExp = nextLevelRequiredExp - currentLevelRequiredExp;

    return Column(
      children: [
        HeaderWidget(title: '마이페이지'),
        SizedBox(height: 10.h),
        DottedBarWidget(),
        SizedBox(height: 8.h),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // 🆕 프로필 + 레벨 시스템
                _buildEnhancedProfile(
                  context,
                  userStatus,
                  currentLevel,
                  levelProgress,
                  currentLevelExp,
                  nextLevelExp,
                  cookHistoryDays,
                  currentPoints,
                ),

                SizedBox(height: 24.h),

                // 🆕 퀘스트 & 뱃지 (2개 카드)
                _buildQuestAndBadgeSection(context),

                SizedBox(height: 24.h),

                // 기존 진행 중인 요리 (유지)
                _buildOngoingCooking(context, ongoingCooking, userStatus),

                SizedBox(height: 24.h),

                // 기존 레시피 위시리스트 (유지)
                _buildWishList(context, recipeStatus),

                SizedBox(height: 24.h),

                // 기존 요리 히스토리 (유지)
                _buildCookingHistory(context, recentHistory),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🆕 강화된 프로필 섹션 (레벨 + XP + 포인트 + 뱃지)
  Widget _buildEnhancedProfile(
      BuildContext context,
      UserStatus userStatus,
      int level,
      double progress,
      int currentLevelExp,
      int nextLevelExp,
      int cookHistoryDays,
      int currentPoints,
      ) {
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
          Row(
            children: [
              // 프로필 이미지 + 레벨 뱃지
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 프로필 이미지 클릭 시 뱃지 선택 다이얼로그 표시
                      _showProfileBadgeDialog(context, userStatus);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: userStatus.userProfile?.isUsingBadgeProfile == true 
                            ? Color(0xFFFFB347) 
                            : Color(0xFFBB885E), 
                          width: 3
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          userStatus.getDisplayProfileImage(), 
                          width: 80.w, 
                          height: 80.w, 
                          fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF8B27)]),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [BoxShadow(color: Color(0xFFFF8B27).withOpacity(0.3), blurRadius: 6, offset: Offset(0, 2))],
                      ),
                      child: Text('Lv.$level', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // 프로필 타입 표시 아이콘
                  if (userStatus.userProfile?.isUsingBadgeProfile == true)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFB347),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0xFFFF8B27).withOpacity(0.3), blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Icon(Icons.star, size: 12.w, color: Colors.white),
                      ),
                    ),
                ],
              ),

              SizedBox(width: 16.w),

              // 닉네임 + XP 정보 + 포인트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userStatus.nickname,
                            style: TextStyle(
                              fontSize: userStatus.nickname.length > 8 ? 16.sp : 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        OutlinedButton(
                          onPressed: () => context.push('/profileSet'),
                          child: Text("설정", style: TextStyle(color: Color(0xFF7D674B), fontSize: 10.sp)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            side: BorderSide(color: Color(0xFF7D674B)),
                            minimumSize: Size(0, 0),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // 포인트 표시
                    Row(
                      children: [
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF6BB6FF),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Center(
                            child: Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: Color(0xFF4A9EFF),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$currentPoints P',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // XP 진행바
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('XP: $currentLevelExp / $nextLevelExp', style: TextStyle(fontSize: 12.sp, color: Color(0xFF666666))),
                            Text('다음 레벨까지 ${nextLevelExp - currentLevelExp}XP', style: TextStyle(fontSize: 10.sp, color: Color(0xFF999999))),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 0.8 ? Color(0xFF7D674B) : Color(0xFFFF8B27),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // 연속 요리일수
                    if (cookHistoryDays > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8B27),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text('🔥 $cookHistoryDays일 연속 요리!', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // 뱃지 정보 섹션 추가
          Consumer<BadgeStatus>(
            builder: (context, badgeStatus, child) {
              final unlockedCount = badgeStatus.unlockedBadges.length;
              final totalCount = badgeStatus.badges.length;
              final mainBadgeId = userStatus.userProfile?.mainBadgeId;
              final mainBadge = mainBadgeId != null ? badgeStatus.getBadgeById(mainBadgeId) : null;
              
              return Column(
                children: [
                  SizedBox(height: 16.h),
                  
                  // 구분선
                  Container(
                    height: 1,
                    color: Color(0xFFBB885E).withOpacity(0.3),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // 뱃지 정보
                  Row(
                    children: [
                      // 뱃지 획득 현황
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '뱃지 컬렉션',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xFF999999),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 16.w,
                                  color: Color(0xFFFFB347),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '$unlockedCount/$totalCount개 획득',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7D674B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // 메인 뱃지 정보
                      if (mainBadge != null) ...[
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Color(0xFFBB885E).withOpacity(0.3),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '메인 뱃지',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Image.asset(
                                    mainBadge.imagePath,
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      mainBadge.name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7D674B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // 뱃지 관리 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/badge'),
                          icon: Icon(Icons.collections_bookmark, size: 14.w),
                          label: Text('뱃지 컬렉션'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF7D674B),
                            side: BorderSide(color: Color(0xFF7D674B)),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showProfileBadgeDialog(context, userStatus),
                          icon: Icon(
                            mainBadge != null ? Icons.swap_horiz : Icons.star,
                            size: 14.w,
                          ),
                          label: Text(mainBadge != null ? '뱃지 변경' : '뱃지 설정'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFFFFB347),
                            side: BorderSide(color: Color(0xFFFFB347)),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 프로필 뱃지 선택 다이얼로그
  void _showProfileBadgeDialog(BuildContext context, UserStatus userStatus) {
    final badgeStatus = context.read<BadgeStatus>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '프로필 설정',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7D674B),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 현재 프로필 정보
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Color(0xFFBB885E)),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          userStatus.getDisplayProfileImage(),
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '현재 프로필',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xFF999999),
                              ),
                            ),
                            Text(
                              userStatus.getProfileType(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7D674B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // 베이스 프로필로 변경 버튼
                if (userStatus.userProfile?.isUsingBadgeProfile == true)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await userStatus.toggleBadgeProfile(null);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.person, size: 16.w),
                    label: Text('베이스 프로필로 변경'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB885E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                  ),
                
                SizedBox(height: 12.h),
                
                // 뱃지 프로필 선택 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showBadgeSelectionDialog(context, userStatus, badgeStatus);
                  },
                  icon: Icon(Icons.star, size: 16.w),
                  label: Text('뱃지 프로필 선택'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFB347),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '닫기',
                style: TextStyle(color: Color(0xFF7D674B)),
              ),
            ),
          ],
        );
      },
    );
  }

  // 뱃지 선택 다이얼로그
  void _showBadgeSelectionDialog(BuildContext context, UserStatus userStatus, BadgeStatus badgeStatus) {
    // 획득한 뱃지만 필터링
    final userBadges = badgeStatus.unlockedBadges;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '뱃지 프로필 선택',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7D674B),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 400.h,
            child: userBadges.isEmpty
                ? Center(
                    child: Text(
                      '획득한 뱃지가 없습니다.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF999999),
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: userBadges.length,
                    itemBuilder: (context, index) {
                      final userBadge = userBadges[index];
                      final badge = badgeStatus.getBadgeById(userBadge.badgeId);
                      if (badge == null) return Container();

                      final isSelected = userStatus.userProfile?.mainBadgeId == badge.id;

                      return GestureDetector(
                        onTap: () async {
                          await userStatus.toggleBadgeProfile(badge.id);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFFFFE0B2) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected ? Color(0xFFFFB347) : Color(0xFFE0E0E0),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(0xFFFFB347).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                badge.imagePath,
                                width: 50.w,
                                height: 50.w,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                badge.name,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Color(0xFF7D674B) : Color(0xFF666666),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected)
                                Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFB347),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '사용중',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(color: Color(0xFF7D674B)),
              ),
            ),
          ],
        );
      },
    );
  }

  // 퀘스트 및 뱃지 섹션 (뱃지 카드 업데이트)
  Widget _buildQuestAndBadgeSection(BuildContext context) {
    return Column(
      children: [
        // 퀘스트 그라데이션 카드
        Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Color(0xFFFF8B27), width: 1),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF8B27).withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push('/quest'),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF8B27),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF8B27).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('🏆', style: TextStyle(fontSize: 22.sp)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '냉털이 퀘스트',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B),
                            fontFamily: 'Mapo',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Consumer<QuestStatus>(
                          builder: (context, questStatus, child) {
                            final claimableCount = questStatus.quests
                                .where((q) => q.isCompleted && !q.isRewardReceived)
                                .length;
                            return Text(
                              claimableCount > 0
                                  ? "$claimableCount개의 보상을 수령할 수 있어요!"
                                  : "새로운 퀘스트에 도전하세요!",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xFF8D6E63),
                                fontFamily: 'Mapo',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Consumer<QuestStatus>(
                    builder: (context, questStatus, child) {
                      final claimableCount = questStatus.quests
                          .where((q) => q.isCompleted && !q.isRewardReceived)
                          .length;
                      if (claimableCount > 0) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF8B27),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '$claimableCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Mapo',
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // 뱃지 그라데이션 카드
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFEBE7), Color(0xFFF5F0E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Color(0xFF7D674B), width: 1),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF7D674B).withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push('/badge'),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: Color(0xFF7D674B),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF7D674B).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('⭐', style: TextStyle(fontSize: 22.sp)),
                        ),
                      ),
                      Consumer<BadgeStatus>(
                        builder: (context, badgeStatus, child) {
                          // 최근 획득한 뱃지가 있는지 확인 (예: 7일 이내)
                          final recentBadges = badgeStatus.unlockedBadges
                              .where((badge) => badge.unlockedAt != null &&
                                  DateTime.now().difference(badge.unlockedAt!).inDays <= 7)
                              .toList();
                          
                          if (recentBadges.isNotEmpty) {
                            return Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF3333),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '뱃지 컬렉션',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B),
                            fontFamily: 'Mapo',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Consumer<BadgeStatus>(
                          builder: (context, badgeStatus, child) {
                            final recentBadges = badgeStatus.unlockedBadges
                                .where((badge) => badge.unlockedAt != null &&
                                    DateTime.now().difference(badge.unlockedAt!).inDays <= 7)
                                .toList();
                            
                            return Text(
                              recentBadges.isNotEmpty
                                  ? '새로운 뱃지를 획득했어요!'
                                  : '다양한 뱃지를 모아보세요!',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xFF8D6E63),
                                fontFamily: 'Mapo',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Consumer<BadgeStatus>(
                    builder: (context, badgeStatus, child) {
                      final unlockedCount = badgeStatus.unlockedBadges.length;
                      final totalCount = badgeStatus.badges.length;
                      return Text(
                        '$unlockedCount/$totalCount',
                        style: TextStyle(
                          color: Color(0xFF7D674B),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mapo',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 기존 섹션들 (유지)
  Widget _buildOngoingCooking(BuildContext context, List<OngoingCooking> ongoingCooking, UserStatus userStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('진행 중인 요리', style: TextStyle(color: Color(0xFF3B3B3B), fontSize: 14.sp)),
            if (ongoingCooking.isNotEmpty)
              InkWell(
                onTap: () => userStatus.clearOngoingCooking(),
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 12.w, color: Color(0xFFDB2222)),
                    Text('초기화', style: TextStyle(color: Color(0xFFDB2222), fontSize: 12.sp)),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        ongoingCooking.isEmpty
            ? MypageShrinkWidget(
          child: Text('진행 중인 요리가 없어요.\n요리를 시작해보세요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC))),
        )
            : InkWell(
          onTap: () => context.push('/cookingStart', extra: ongoingCooking[0].recipe),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFBB885E)),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: ListTile(
              leading: Image.asset('assets/imgs/icons/history_icon1.png', width: 20.w),
              title: Text(ongoingCooking[0].recipe.title),
              subtitle: Text("요리 시작 일시 : ${ongoingCooking[0].startTime.year}. ${ongoingCooking[0].startTime.month.toString().padLeft(2, '0')}. ${ongoingCooking[0].startTime.day.toString().padLeft(2, '0')}"),
              trailing: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(ongoingCooking[0].recipe.thumbnail, width: 50.w, height: 50.w, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWishList(BuildContext context, RecipeStatus recipeStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('레시피 위시리스트', style: TextStyle(color: Color(0xFF3B3B3B), fontSize: 14.sp)),
            InkWell(
              onTap: () => context.push('/recipeWishList'),
              child: Text('전체보기', style: TextStyle(color: Color(0xFFFF8B27), fontSize: 12.sp)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        recipeStatus.favoriteRecipes.isEmpty
            ? MypageShrinkWidget(child: Text('레시피 위시리스트가 없어요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC))))
            : RecipeWishListWidget(recipes: recipeStatus.favoriteRecipes),
      ],
    );
  }

  Widget _buildCookingHistory(BuildContext context, List<CookingHistory> recentHistory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('요리 히스토리', style: TextStyle(color: Color(0xFF3B3B3B), fontSize: 14.sp)),
            InkWell(
              onTap: () => context.push('/cookHistory'),
              child: Text('달력보기', style: TextStyle(color: Color(0xFFFF8B27), fontSize: 12.sp)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        recentHistory.isEmpty
            ? MypageShrinkWidget(child: Text('요리 히스토리가 없어요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Color(0xFFACACAC))))
            : Column(
          children: recentHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final history = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: [Color(0xFFFFDD9E), Color(0xFFFFD1A9), Color(0xFFFFB4A9)][index],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ListTile(
                dense: true,
                leading: Image.asset('assets/imgs/icons/history_icon${index + 1}.png', width: 20.w),
                title: Text(history.recipe.title),
                trailing: Text('${history.dateTime.month.toString().padLeft(2, '0')}.${history.dateTime.day.toString().padLeft(2, '0')}'),
                onTap: () => context.push('/recipeInfo', extra: history.recipe),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}