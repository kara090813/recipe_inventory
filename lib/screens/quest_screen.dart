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
      title: "한식 10회 도전",
      progress: 5,
      maxProgress: 10,
      reward: 20,
      status: QuestStatus.inProgress,
    ),
    QuestData(
      title: "한식 10회 도전",
      progress: 9,
      maxProgress: 10,
      reward: 30,
      status: QuestStatus.canReceive,
    ),
    QuestData(
      title: "한식 10회 도전",
      progress: 10,
      maxProgress: 10,
      reward: 10,
      status: QuestStatus.completed,
    ),
    QuestData(
      title: "한식 10회 도전",
      progress: 10,
      maxProgress: 10,
      reward: 10,
      status: QuestStatus.received,
    ),
    QuestData(
      title: "한식 10회 도전",
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
      body: ScaffoldPaddingWidget(
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
                          '광고를 시청하고 얻을 포인트를 얻어온!',
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

            // 탭바
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                indicatorPadding: EdgeInsets.all(4.w),
                labelColor: Color(0xFF7D674B),
                unselectedLabelColor: Color(0xFF999999),
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Mapo',
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
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

            // 퀘스트 리스트
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filteredQuests.length,
                itemBuilder: (context, index) {
                  final quest = filteredQuests[index];
                  return _buildQuestCard(quest);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(QuestData quest) {
    final progressPercentage = (quest.progress / quest.maxProgress * 100).round();

    // 배경 이미지 선택
    String backgroundImage;
    String pointerImage;
    Color progressColor;
    String statusText;
    Color statusTextColor;
    Color statusBackgroundColor;
    bool isReceived = quest.status == QuestStatus.received;

    switch (quest.status) {
      case QuestStatus.inProgress:
        backgroundImage = 'assets/imgs/background/ticket_default.png';
        if (progressPercentage <= 30) {
          progressColor = Color(0xFFFFD700);
          pointerImage = 'assets/imgs/items/point_yellow.png';
        } else if (progressPercentage <= 60) {
          progressColor = Color(0xFFFF8C00);
          pointerImage = 'assets/imgs/items/point_orange.png';
        } else {
          progressColor = Color(0xFFFF6347);
          pointerImage = 'assets/imgs/items/point_orange.png';
        }
        statusText = '진행중';
        statusTextColor = Color(0xFFFF8B27);
        statusBackgroundColor = Colors.transparent;
        break;
      case QuestStatus.canReceive:
        backgroundImage = 'assets/imgs/background/ticket_default.png';
        progressColor = Color(0xFFFF0000);
        pointerImage = 'assets/imgs/items/point_pink.png';
        statusText = '받을 보상';
        statusTextColor = Color(0xFF999999);
        statusBackgroundColor = Colors.transparent;
        break;
      case QuestStatus.completed:
        backgroundImage = 'assets/imgs/background/ticket_reward.png';
        progressColor = Color(0xFFFF0000);
        pointerImage = 'assets/imgs/items/point_pink.png';
        statusText = '보상받기';
        statusTextColor = Colors.white;
        statusBackgroundColor = Color(0xFFFF8B27);
        break;
      case QuestStatus.received:
        backgroundImage = 'assets/imgs/background/ticket_done.png';
        progressColor = Color(0xFFCCCCCC);
        pointerImage = 'assets/imgs/items/point_yellow.png';
        statusText = '진행중';
        statusTextColor = Color(0xFF999999);
        statusBackgroundColor = Colors.transparent;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 120.h,
      child: Stack(
        children: [
          // 배경 티켓 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 컨텐츠
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Row(
              children: [
                // 왼쪽 퀘스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3009),
                          fontFamily: 'Mapo',
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 진행률 표시
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${progressPercentage}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Mapo',
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // 프로그레스 바
                      Stack(
                        children: [
                          Container(
                            height: 8.h,
                            width: 200.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            height: 8.h,
                            width: 200.w * (quest.progress / quest.maxProgress),
                            decoration: BoxDecoration(
                              color: progressColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Positioned(
                            left: (200.w * (quest.progress / quest.maxProgress)) - 8.w,
                            top: -4.h,
                            child: Image.asset(
                              pointerImage,
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Color(0xFF666666),
                              fontFamily: 'Mapo',
                            ),
                          ),
                          SizedBox(width: 185.w),
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

                // 오른쪽 보상 섹션
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/items/ice.png',
                      width: 32.w,
                      height: 32.w,
                      color: isReceived ? Colors.grey : null,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${quest.reward}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isReceived ? Color(0xFF999999) : Color(0xFF5E3009),
                        fontFamily: 'Mapo',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (quest.status == QuestStatus.completed)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: statusBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Mapo',
                          ),
                        ),
                      )
                    else
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mapo',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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