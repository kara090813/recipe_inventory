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

    // 임시 데이터 (실제로는 UserStatus에서 가져올 예정)
    final currentLevel = _calculateLevel(userStatus.cookingHistory.length);
    final currentXP = _calculateCurrentXP(userStatus.cookingHistory.length);
    final nextLevelXP = _calculateNextLevelXP(currentLevel);
    final xpProgress = currentXP / nextLevelXP;

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
                _buildEnhancedProfile(context, userStatus, currentLevel, xpProgress, currentXP, nextLevelXP, cookHistoryDays),

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

  // 🆕 강화된 프로필 섹션 (레벨 + XP)
  Widget _buildEnhancedProfile(BuildContext context,UserStatus userStatus, int level, double progress, int currentXP, int nextLevelXP, int cookHistoryDays) {
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFBB885E), width: 3),
                    ),
                    child: userStatus.profileImage != null
                        ? ClipOval(child: Image.network(userStatus.profileImage!, width: 80.w, height: 80.w, fit: BoxFit.cover))
                        : ClipOval(child: Image.asset('assets/imgs/items/baseProfile.png', width: 80.w)),
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
                ],
              ),

              SizedBox(width: 16.w),

              // 닉네임 + XP 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(userStatus.nickname, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
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

                    SizedBox(height: 8.h),

                    // XP 진행바
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('XP: $currentXP / $nextLevelXP', style: TextStyle(fontSize: 12.sp, color: Color(0xFF666666))),
                            Text('다음 레벨까지 ${nextLevelXP - currentXP}XP', style: TextStyle(fontSize: 10.sp, color: Color(0xFF999999))),
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
        ],
      ),
    );
  }

  // 🆕 퀘스트 & 뱃지 섹션 (심플한 티저 카드)
  // 🆕 완전히 다른 방식 - 심플한 리스트 스타일
  Widget _buildQuestAndBadgeSection(BuildContext context) {
    return Column(
      children: [
        // 퀘스트 항목
        InkWell(
          onTap: () => context.push('/quest'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Color(0xFFBB885E), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Text('🏆', style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '퀘스트',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7D674B),
                        ),
                      ),
                      Text(
                        '완료된 보상 3개 수령 가능',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF8B27),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: Color(0xFFBB885E),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // 뱃지 항목
        InkWell(
          onTap: () => context.push('/badge'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Color(0xFFBB885E), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 20.sp)),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF3333),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '뱃지 컬렉션',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7D674B),
                        ),
                      ),
                      Text(
                        '새 뱃지가 있어요! (15/30)',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: Color(0xFFBB885E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(String emoji, bool isUnlocked, bool isNew) {
    return Stack(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: isUnlocked ? Color(0xFFFFF3E6) : Color(0xFFE8E8E8),
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? Color(0xFFBB885E) : Color(0xFFCCCCCC),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        if (isNew)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Color(0xFFFF8B27),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  // 기존 섹션들 (간소화된 버전들)
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

  // 헬퍼 함수들
  int _calculateLevel(int cookingCount) {
    return (cookingCount / 5).floor() + 1; // 5번 요리할 때마다 레벨업
  }

  int _calculateCurrentXP(int cookingCount) {
    return (cookingCount % 5) * 20; // 요리 1번당 20XP
  }

  int _calculateNextLevelXP(int level) {
    return 100; // 각 레벨마다 100XP 필요
  }
}