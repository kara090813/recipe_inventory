import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';
import '../data/badgeData.dart';

class BadgeUnlockedWidget extends StatefulWidget {
  final Badge badge;
  final VoidCallback? onConfirm;

  const BadgeUnlockedWidget({
    Key? key,
    required this.badge,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<BadgeUnlockedWidget> createState() => _BadgeUnlockedWidgetState();
}

class _BadgeUnlockedWidgetState extends State<BadgeUnlockedWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 스케일 애니메이션 컨트롤러
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 페이드 애니메이션 컨트롤러
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 스케일 애니메이션 (탄성 효과)
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // 페이드 애니메이션
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (widget.onConfirm != null) {
      widget.onConfirm!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 300.w,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 축하 메시지
                      Text(
                        '🎉 축하합니다!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF8B27),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '새로운 뱃지를 획득했습니다!',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF7D674B),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // 뱃지 이미지
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFF3E6),
                              const Color(0xFFFFE4C4),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8B27).withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            widget.badge.imagePath,
                            width: 70.w,
                            height: 70.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // 뱃지 이름
                      Text(
                        widget.badge.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7D674B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      
                      // 뱃지 설명
                      Text(
                        widget.badge.description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF969696),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      
                      // 뱃지 카테고리 및 난이도
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8B27).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFFF8B27).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.badge.category.displayName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFFFF8B27),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: widget.badge.difficulty.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: widget.badge.difficulty.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.badge.difficulty.displayName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: widget.badge.difficulty.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      
                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8B27),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 뱃지 획득 팝업을 표시하는 헬퍼 함수
Future<void> showBadgeUnlockedDialog({
  required BuildContext context,
  required Badge badge,
  VoidCallback? onConfirm,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return BadgeUnlockedWidget(
        badge: badge,
        onConfirm: () {
          Navigator.of(context).pop();
          if (onConfirm != null) {
            onConfirm();
          }
        },
      );
    },
  );
}