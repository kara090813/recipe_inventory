import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/backButton_widget.dart';
import '../widgets/dottedbar_widget.dart';
import '../status/userStatus.dart';
import '../utils/custom_snackbar.dart';

class CustomRecipePurchaseScreen extends StatefulWidget {
  const CustomRecipePurchaseScreen({Key? key}) : super(key: key);

  @override
  State<CustomRecipePurchaseScreen> createState() => _CustomRecipePurchaseScreenState();
}

class _CustomRecipePurchaseScreenState extends State<CustomRecipePurchaseScreen> {
  int selectedQuantity = 1;
  final int pricePerTicket = 200; // 1개당 200포인트

  // 패키지 옵션들
  final List<Map<String, dynamic>> packages = [
    {'quantity': 1, 'price': 200, 'bonus': 0},
    {'quantity': 3, 'price': 600, 'bonus': 0},
    {'quantity': 5, 'price': 900, 'bonus': 1}, // 5+1 이벤트
    {'quantity': 10, 'price': 1600, 'bonus': 4}, // 10+4 이벤트
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    SizedBox(height: 24.h),
                    _buildCurrentStatus(),
                    SizedBox(height: 28.h),
                    _buildPackageOptions(),
                    SizedBox(height: 28.h),
                    _buildPointGuide(),
                    SizedBox(height: 32.h),
                    _buildNoticeSection(),
                  ],
                ),
              ),
            ),
            _buildBottomPurchaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 백버튼 (왼쪽 정렬)
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/imgs/icons/back_arrow.png',
                        width: 28.w,
                        height: 28.w,
                      ),
                    ),
                  ),
                ),
              ),
              // 타이틀 (가운데 정렬)
              Text(
                '커스텀 레시피 생성권 구매',
                style: TextStyle(
                  color: Color(0xFF7D674B),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // DottedBar (전체 너비)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: DottedBarWidget(
            paddingSize: 0,
            lineColor: Color(0xFF8D6E63),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Center(
          child: Stack(
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
                '나만의 레시피를 만들어보세요!',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '커스텀 레시피 생성권으로\n특별한 레시피를 만들어보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus() {
    return Consumer<UserStatus>(
      builder: (context, userStatus, child) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F1EB),
                Color(0xFFEFE7DA),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF8D6E63).withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.receipt_long,
                  label: '보유 생성권',
                  value: '${userStatus.customRecipeTickets}개',
                  color: Color(0xFF8D6E63),
                ),
              ),
              SizedBox(width: 20.w),
              Container(
                width: 1,
                height: 50.h,
                color: Color(0xFF8D6E63).withOpacity(0.3),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildStatusCard(
                  iconWidget: Image.asset(
                    'assets/imgs/items/ice.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                  label: '보유 포인트',
                  value: '${userStatus.currentPoints}P',
                  color: Color(0xFFDEB887),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: iconWidget ?? Icon(
            icon,
            color: color,
            size: 24.w,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildPointGuide() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.asset(
                  'assets/imgs/items/ice.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '포인트가 부족하신가요?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildSimplePointMethod(
                  icon: Icons.restaurant_menu,
                  title: '조리하기',
                  reward: '경험치',
                  color: Color(0xFF8D6E63),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSimplePointMethod(
                  icon: Icons.trending_up,
                  title: '레벨업',
                  reward: '100P',
                  color: Color(0xFFFF8C00),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSimplePointMethod(
                  icon: Icons.task_alt,
                  title: '퀘스트',
                  reward: '다양한 보상',
                  color: Color(0xFFD4A574),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/quest'),
              icon: Icon(
                Icons.arrow_forward,
                size: 18.w,
                color: Colors.white,
              ),
              label: Text(
                '퀘스트 확인하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8D6E63),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePointMethod({
    required IconData icon,
    required String title,
    required String reward,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            reward,
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '패키지 선택',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5D4037),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '원하는 생성권 개수를 선택해주세요',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20.h),
        Column(
          children: packages.map((package) => _buildPackageCard(package)).toList(),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final quantity = package['quantity'] as int;
    final price = package['price'] as int;
    final bonus = package['bonus'] as int;
    final totalTickets = quantity + bonus;
    final isSelected = selectedQuantity == quantity;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuantity = quantity;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Color(0xFFFF8C00) : Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Color(0xFFFF8C00).withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFFFF8C00) : Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalTickets',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Color(0xFF374151),
                      ),
                    ),
                    Text(
                      '개',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white.withOpacity(0.8) : Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '생성권 ${totalTickets}개',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (bonus > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF8C00),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '+${bonus}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      bonus > 0 ? '${quantity}개 구매 + ${bonus}개 증정' : '기본 패키지',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/imgs/items/ice.png',
                        width: 16.w,
                        height: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$price',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  if (bonus > 0) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '개당 ${(price / totalTickets).round()}P',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF8D6E63),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF666666),
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '구매 안내',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '• 커스텀 레시피 생성권은 나만의 레시피를 만들 때 사용됩니다.\n'
            '• 생성권 1개로 레시피 1개를 만들 수 있습니다.\n'
            '• 구매한 생성권은 만료되지 않습니다.\n'
            '• 포인트가 부족한 경우 구매할 수 없습니다.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPurchaseButton() {
    return Consumer<UserStatus>(
      builder: (context, userStatus, child) {
        final selectedPackage = packages.firstWhere((p) => p['quantity'] == selectedQuantity);
        final totalPrice = selectedPackage['price'] as int;
        final totalTickets = selectedPackage['quantity'] + selectedPackage['bonus'];
        final canPurchase = userStatus.currentPoints >= totalPrice;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Color(0xFFEDE7D9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFAF7F3),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '총 구매 수량',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${totalTickets}개',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '사용 포인트',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/imgs/items/ice.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${totalPrice}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: canPurchase ? () => _handlePurchase(context, userStatus) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canPurchase ? Color(0xFFFF8C00) : Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    canPurchase ? '구매하기' : '포인트 부족',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePurchase(BuildContext context, UserStatus userStatus) async {
    final selectedPackage = packages.firstWhere((p) => p['quantity'] == selectedQuantity);
    final totalPrice = selectedPackage['price'] as int;
    final totalTickets = selectedPackage['quantity'] + selectedPackage['bonus'];

    final success = await userStatus.purchaseCustomRecipeTickets(totalTickets, totalPrice);

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  '구매 완료!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '커스텀 레시피 생성권 ${totalTickets}개를\n성공적으로 구매했습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/customRecipe');
                },
                child: Text(
                  '레시피 만들러 가기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        CustomSnackBar.showError(context, '구매에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }
}