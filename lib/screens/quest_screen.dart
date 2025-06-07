import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/_widgets.dart';
import '../models/_models.dart';
import '../status/_status.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({Key? key}) : super(key: key);

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Consumer2<QuestStatus, UserStatus>(
          builder: (context, questStatus, userStatus, child) {
            if (questStatus.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF8B27)),
                    SizedBox(height: 16.h),
                    Text(
                      '퀘스트를 불러오는 중...',
                      style: TextStyle(
                        color: Color(0xFF7D674B),
                        fontSize: 16.sp,
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],
                ),
              );
            }

            // 탭별 퀘스트 필터링
            final filteredQuests = _getFilteredQuests(questStatus);

            return Column(
              children: [
                // 고정 헤더 영역
                Container(
                  color: Color(0xFFF5F5F5),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      // 헤더
                      _buildHeader(userStatus),
                      SizedBox(height: 10.h),
                      DottedBarWidget(),
                      SizedBox(height: 16.h),

                      // 광고 시청 카드 (기존 디자인 유지)
                      _buildAdCard(),
                      SizedBox(height: 20.h),

                      // 3개 탭바
                      _buildTabBar(questStatus),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),

                // 스크롤 가능한 퀘스트 리스트 영역
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: filteredQuests.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredQuests.length,
                      itemBuilder: (context, index) {
                        return _buildQuestCard(filteredQuests[index], questStatus, userStatus);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 헤더 빌드 (포인트, 레벨, 경험치 표시)
  Widget _buildHeader(UserStatus userStatus) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            color: Colors.transparent,
            child: Image.asset(
              'assets/imgs/icons/back_arrow.png',
              width: 26.w,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '요리퀘스트',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7D674B),
              fontSize: 20.sp,
              fontFamily: 'Mapo',
            ),
          ),
        ),
        Row(
          children: [
            // 포인트 표시
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: Color(0xFF6BB6FF),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF4A9EFF),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '${userStatus.currentPoints}',
              style: TextStyle(
                color: Color(0xFF7D674B),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mapo',
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
      ],
    );
  }

  /// 광고 시청 카드 (기존 디자인 유지)
  Widget _buildAdCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFBB885E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/imgs/items/tv.png',
            width: 60.w,
            height: 40.h,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Color(0xFF6BB6FF),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF4A9EFF),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' x5',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '광고를 시청하고 포인트를 얻어보세요!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF666666),
                    fontFamily: 'Mapo',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '10 / 10',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mapo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 탭바 빌드
  Widget _buildTabBar(QuestStatus questStatus) {
    // 각 탭별 개수 계산
    final inProgressCount = questStatus.inProgressQuests.length;
    final canReceiveCount = questStatus.canReceiveRewardQuests.length;
    final completedCount = questStatus.completedQuests.length;

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
          Tab(text: '진행 중 ($inProgressCount)'),
          Tab(text: '보상 수령 대기 ($canReceiveCount)'),
          Tab(text: '완료 ($completedCount)'),
        ],
      ),
    );
  }

  /// 탭별 퀘스트 필터링
  List<Quest> _getFilteredQuests(QuestStatus questStatus) {
    switch (_selectedTabIndex) {
      case 0: // 진행 중
        return questStatus.inProgressQuests;
      case 1: // 보상 수령 대기
        return questStatus.canReceiveRewardQuests;
      case 2: // 완료
        return questStatus.completedQuests;
      default:
        return questStatus.quests;
    }
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    String message;
    switch (_selectedTabIndex) {
      case 0:
        message = '진행 중인 퀘스트가 없습니다';
        break;
      case 1:
        message = '보상을 받을 수 있는 퀘스트가 없습니다';
        break;
      case 2:
        message = '완료된 퀘스트가 없습니다';
        break;
      default:
        message = '퀘스트가 없습니다';
    }

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
            message,
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

  /// 퀘스트 카드 빌드
  Widget _buildQuestCard(Quest quest, QuestStatus questStatus, UserStatus userStatus) {
    final progressPercentage = quest.targetCount > 0
        ? (quest.currentProgress / quest.targetCount * 100).round()
        : 0;

    // 퀘스트 상태에 따른 설정
    String rightTicketImage;
    Color progressColor;
    String statusText;
    Color statusTextColor;
    bool isCompleted = quest.isCompleted;
    bool isRewardReceived = quest.isRewardReceived;

    if (isRewardReceived) {
      // 완료됨 (보상까지 받음)
      rightTicketImage = 'assets/imgs/background/ticketRight_done.png';
      progressColor = Color(0xFFCCCCCC);
      statusText = '완료됨';
      statusTextColor = Color(0xFF999999);
    } else if (isCompleted) {
      // 보상 수령 대기
      rightTicketImage = 'assets/imgs/background/ticketRight_active.png';
      progressColor = Color(0xFFFF0000);
      statusText = '보상받기';
      statusTextColor = Colors.white;
    } else {
      // 진행 중
      rightTicketImage = 'assets/imgs/background/ticketRight_default.png';
      if (progressPercentage <= 30) {
        progressColor = Color(0xFFFFD700);
      } else if (progressPercentage <= 60) {
        progressColor = Color(0xFFFF8C00);
      } else {
        progressColor = Color(0xFFFF6347);
      }
      statusText = '진행중';
      statusTextColor = Color(0xFFFF8B27);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 120.h,
      child: Row(
        children: [
          // 좌측 티켓 (퀘스트 정보 영역)
          Expanded(
            flex: 78, // 78% 비율
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/imgs/background/ticketLeft.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 10.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 제목과 퍼센티지를 한 줄에 배치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5E3009),
                              fontFamily: 'Mapo',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${progressPercentage}%',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Mapo',
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // 프로그레스 바 (전체 너비 차지)
                    _buildProgressBarWithPointer(quest, progressColor),

                    SizedBox(height: 2.h),

                    // 프로그레스 바 아래 숫자 (0부터 maxProgress까지)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Color(0xFF666666),
                            fontFamily: 'Mapo',
                          ),
                        ),
                        Text(
                          '${quest.targetCount}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Color(0xFF666666),
                            fontFamily: 'Mapo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 우측 티켓 (보상 영역)
          Expanded(
            flex: 22, // 22% 비율
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(rightTicketImage),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 보상 아이콘 및 포인트
                  if (quest.rewardPoints > 0) ...[
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: isRewardReceived ? Colors.grey : Color(0xFF6BB6FF),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            color: isRewardReceived ? Colors.grey[400] : Color(0xFF4A9EFF),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${quest.rewardPoints}P',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: isRewardReceived ? Color(0xFF999999) : Color(0xFF5E3009),
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],

                  // 경험치 보상도 표시
                  if (quest.rewardExperience > 0) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '+${quest.rewardExperience}XP',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isRewardReceived ? Color(0xFF999999) : Color(0xFF5E3009),
                        fontFamily: 'Mapo',
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),

                  // 상태별 버튼/텍스트
                  if (isCompleted && !isRewardReceived)
                    GestureDetector(
                      onTap: () => _handleReceiveReward(quest, questStatus, userStatus),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Color(0xFFFF8B27),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: Color(0xFFFF8B27),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Mapo',
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Mapo',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 보상 받기 처리
  Future<void> _handleReceiveReward(Quest quest, QuestStatus questStatus, UserStatus userStatus) async {
    try {
      final success = await questStatus.receiveReward(quest.id, userStatus);

      if (success && mounted) {
        // 성공 알림 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '보상을 받았습니다! +${quest.rewardPoints}P +${quest.rewardExperience}XP',
                    style: TextStyle(fontFamily: 'Mapo'),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        // 실패 알림 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '보상 받기에 실패했습니다.',
              style: TextStyle(fontFamily: 'Mapo'),
            ),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      print('보상 받기 처리 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '오류가 발생했습니다: $e',
              style: TextStyle(fontFamily: 'Mapo'),
            ),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  /// 포인터가 있는 프로그레스 바 위젯
  Widget _buildProgressBarWithPointer(Quest quest, Color progressColor) {
    final double progressRatio = quest.targetCount > 0
        ? (quest.currentProgress / quest.targetCount).clamp(0.0, 1.0)
        : 0.0;

    // 진행도에 따른 포인터 이미지 선택
    String pointerImage;
    if (quest.isRewardReceived) {
      pointerImage = 'assets/imgs/items/point_yellow.png';
    } else if (progressRatio >= 0.8) {
      pointerImage = 'assets/imgs/items/point_pink.png';
    } else if (progressRatio >= 0.4) {
      pointerImage = 'assets/imgs/items/point_orange.png';
    } else {
      pointerImage = 'assets/imgs/items/point_yellow.png';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double pointerSize = 20.w;
        // 포인터가 바 영역을 벗어나지 않도록 위치 계산
        final double maxPointerPosition = barWidth - pointerSize;
        final double pointerPosition = (progressRatio * maxPointerPosition).clamp(0.0, maxPointerPosition);

        return Container(
          height: 20.h, // 포인터를 포함할 수 있도록 높이 증가
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 프로그레스 바
              Container(
                height: 9.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(
                    color: Color(0xFF707070), // 보더 색상
                    width: 1.0,               // 보더 두께
                  ),
                ),
              ),
              // 진행된 프로그레스 바
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 9.h,
                  width: barWidth * progressRatio,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3.r),
                    border: Border.all(
                      color: Color(0xFF707070), // 보더 색상
                      width: 1.0,               // 보더 두께
                    ),
                  ),
                ),
              ),
              // 포인터 이미지
              Positioned(
                left: pointerPosition,
                child: Image.asset(
                  pointerImage,
                  width: pointerSize,
                  height: pointerSize,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패 시 기본 원형 포인터
                    return Container(
                      width: pointerSize,
                      height: pointerSize,
                      decoration: BoxDecoration(
                        color: progressColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.w),
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