import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGuide extends StatefulWidget {
  final List<GuideContent> contents;
  final VoidCallback onFinish;

  const OnboardingGuide({
    Key? key,
    required this.contents,
    required this.onFinish,
  }) : super(key: key);

  static Future<void> showIfNeeded(BuildContext context, List<GuideContent> contents) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownGuide = prefs.getBool('has_shown_guide') ?? false;

    if (!hasShownGuide) {
      if (context.mounted) {
        await showGuide(context, contents);
      }
      await prefs.setBool('has_shown_guide', true);
    }
  }

  static Future<void> showGuide(BuildContext context, List<GuideContent> contents) {
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return OnboardingGuide(
            contents: contents,
            onFinish: () => Navigator.of(context).pop(),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        });
  }

  @override
  State<OnboardingGuide> createState() => _OnboardingGuideState();
}

class _OnboardingGuideState extends State<OnboardingGuide> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.contents.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF201D1C),
      body: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: widget.contents.map((content) {
                  return Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 10.h),
                      Text(
                        content.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: Image.asset(
                          content.imagePath,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).padding.bottom + 10.h,
                top: 20.h,
              ),
              child: _currentPage == widget.contents.length - 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 이전으로 버튼 유지
                        IconButton(
                          onPressed: _previousPage,
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        // 중앙에 시작하기 버튼
                        Container(
                          width: 200.w, // 페이징 도트가 있던 영역 정도의 너비
                          child: ElevatedButton(
                            onPressed: widget.onFinish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF88828),
                              minimumSize: Size(0, 40.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              '냉장고 털이 시작하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // 우측 공간 유지를 위한 빈 IconButton 크기의 SizedBox
                        SizedBox(width: 48.w), // IconButton의 기본 크기
                      ],
                    )
                  : Row(
                      // 마지막 페이지가 아닐 때는 기존 네비게이션 표시
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            widget.contents.length,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? Color(0xFFFF8B27) : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _nextPage,
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideContent {
  final String title;
  final String imagePath;

  const GuideContent({
    required this.title,
    required this.imagePath,
  });
}
