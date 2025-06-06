import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/_widgets.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({Key? key}) : super(key: key);

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<QuestData> quests = [
    QuestData(
      title: "한식 10회 도전",
      progress: 2,
      maxProgress: 10,
      reward: 20,
      status: QuestStatus.inProgress,
    ),
    QuestData(
      title: "양식 5회 도전",
      progress: 5,
      maxProgress: 10,
      reward: 20,
      status: QuestStatus.inProgress,
    ),
    QuestData(
      title: "중식 8회 도전",
      progress: 9,
      maxProgress: 10,
      reward: 30,
      status: QuestStatus.canReceive,
    ),
    QuestData(
      title: "일식 완주하기",
      progress: 10,
      maxProgress: 10,
      reward: 10,
      status: QuestStatus.completed,
    ),
    QuestData(
      title: "아시안 요리 마스터",
      progress: 10,
      maxProgress: 10,
      reward: 10,
      status: QuestStatus.received,
    ),
    QuestData(
      title: "초보 요리사",
      progress: 0,
      maxProgress: 10,
      reward: 20,
      status: QuestStatus.inProgress,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  List<QuestData> get filteredQuests {
    switch (_selectedTabIndex) {
      case 0: // 전체
        return quests;
      case 1: // 진행 중
        return quests.where((q) => q.status == QuestStatus.inProgress).toList();
      case 2: // 보상 가능
        return quests.where((q) => q.status == QuestStatus.canReceive).toList();
      case 3: // 보상 수령
        return quests.where((q) => q.status == QuestStatus.received).toList();
      default:
        return quests;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 고정 헤더 영역
            Container(
              color: Color(0xFFF5F5F5),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  // 헤더
                  Row(
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
                            '120',
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
                  ),
                  SizedBox(height: 10.h),
                  DottedBarWidget(),
                  SizedBox(height: 16.h),

                  // 광고 시청 카드
                  Container(
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
                  ),

                  SizedBox(height: 20.h),

                  // 개선된 탭바
                  Container(
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
                        Tab(text: '전체'),
                        Tab(text: '진행 중'),
                        Tab(text: '보상 가능'),
                        Tab(text: '보상 수령'),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),

            // 스크롤 가능한 퀘스트 리스트 영역
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: filteredQuests.isEmpty
                    ? Center(
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
                        '해당하는 퀘스트가 없습니다',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14.sp,
                          fontFamily: 'Mapo',
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredQuests.length,
                  itemBuilder: (context, index) {
                    final quest = filteredQuests[index];
                    return _buildQuestCard(quest);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(QuestData quest) {
    final progressPercentage = quest.maxProgress > 0
        ? (quest.progress / quest.maxProgress * 100).round()
        : 0;

    // 우측 이미지 선택
    String rightTicketImage;
    Color progressColor;
    String statusText;
    Color statusTextColor;
    Color statusBackgroundColor;
    bool isReceived = quest.status == QuestStatus.received;

    switch (quest.status) {
      case QuestStatus.inProgress:
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
        statusBackgroundColor = Colors.transparent;
        break;
      case QuestStatus.canReceive:
        rightTicketImage = 'assets/imgs/background/ticketRight_active.png';
        progressColor = Color(0xFFFF0000);
        statusText = '보상 가능';
        statusTextColor = Color(0xFFFF8B27);
        statusBackgroundColor = Colors.transparent;
        break;
      case QuestStatus.completed:
        rightTicketImage = 'assets/imgs/background/ticketRight_active.png';
        progressColor = Color(0xFFFF0000);
        statusText = '보상받기';
        statusTextColor = Colors.white;
        statusBackgroundColor = Color(0xFFFF8B27);
        break;
      case QuestStatus.received:
        rightTicketImage = 'assets/imgs/background/ticketRight_done.png';
        progressColor = Color(0xFFCCCCCC);
        statusText = '완료됨';
        statusTextColor = Color(0xFF999999);
        statusBackgroundColor = Colors.transparent;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 110.h,
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
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E3009),
                        fontFamily: 'Mapo',
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // 진행률과 프로그레스 바를 한 줄에
                    Row(
                      children: [
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
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildProgressBarWithPointer(quest, progressColor),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${quest.progress}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Color(0xFF666666),
                            fontFamily: 'Mapo',
                          ),
                        ),
                        Text(
                          '${quest.maxProgress}',
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 14.h, 20.w, 14.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/items/ice.png',
                      width: 28.w,
                      height: 28.w,
                      color: isReceived ? Colors.grey : null,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${quest.reward}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isReceived ? Color(0xFF999999) : Color(0xFF5E3009),
                        fontFamily: 'Mapo',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (quest.status == QuestStatus.completed)
                      GestureDetector(
                        onTap: () {
                          // 보상 받기 로직
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('보상을 받았습니다!')),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 9.sp,
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
          ),
        ],
      ),
    );
  }

// 포인터가 있는 프로그레스 바 위젯
  Widget _buildProgressBarWithPointer(QuestData quest, Color progressColor) {
    final double progressRatio = quest.maxProgress > 0
        ? (quest.progress / quest.maxProgress).clamp(0.0, 1.0)
        : 0.0;

    // 진행도에 따른 포인터 이미지 선택
    String pointerImage;
    if (quest.status == QuestStatus.received) {
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
        final double pointerSize = 12.w;
        // 포인터가 바 영역을 벗어나지 않도록 위치 계산
        final double maxPointerPosition = barWidth - pointerSize;
        final double pointerPosition = (progressRatio * maxPointerPosition).clamp(0.0, maxPointerPosition);

        return Container(
          height: 16.h, // 포인터를 포함할 수 있도록 높이 증가
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 프로그레스 바
              Container(
                height: 6.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              // 진행된 프로그레스 바
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 6.h,
                  width: barWidth * progressRatio,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3.r),
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

enum QuestStatus {
  inProgress,
  canReceive,
  completed,
  received,
}

class QuestData {
  final String title;
  final int progress;
  final int maxProgress;
  final int reward;
  final QuestStatus status;

  QuestData({
    required this.title,
    required this.progress,
    required this.maxProgress,
    required this.reward,
    required this.status,
  });
}