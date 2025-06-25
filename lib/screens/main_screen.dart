import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/status/_status.dart';
import '../funcs/_funcs.dart';
import '../models/data.dart';
import '../widgets/_widgets.dart';
import '../components/_components.dart';
import '_screens.dart';
import '../utils/custom_snackbar.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<List<dynamic>> barList = [
    [
      'assets/imgs/icons/bar_home.png',
      '냉장고',
    ],
    ['assets/imgs/icons/bar_cart.png', '식재료 추가'],
    ['assets/imgs/icons/bar_recomanded.png', '추천'],
    ['assets/imgs/icons/bar_search.png', '탐색'],
    ['assets/imgs/icons/bar_my.png', '마이페이지']
  ];

  final List<Widget> _widgetOptions = <Widget>[
    InventoryComponents(),
    Container(),
    RecommendedRecipeComponent(),
    SearchRecipeComponent(),
    MyPageComponent()
  ];

  @override
  void initState() {
    super.initState();
    // 화면이 완전히 빌드된 후 가이드 표시 및 BadgeStatus 컨텍스트 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingGuide.showIfNeeded(context, guideContents);
      
      // BadgeStatus에 현재 컨텍스트 설정 (뱃지 팝업 표시용)
      Provider.of<BadgeStatus>(context, listen: false).setCurrentContext(context);
    });
  }

  DateTime? _lastPressedAt;
  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabStatus>(context);

    return PopScope(
      canPop: false, // 기본적으로 pop 동작 방지
      onPopInvoked: (didPop) async {
        // didPop이 false인 경우에만 처리 (canPop이 false이므로 항상 false)
        if (!didPop) {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
            _lastPressedAt = DateTime.now();

            CustomSnackBar.showInfo(context, '뒤로가기를 한 번 더 누르면 앱이 종료됩니다');
          } else {
            // 2초 이내에 두 번째 클릭 시 앱 종료
            SystemNavigator.pop(); // 앱 종료를 위해 SystemNavigator.pop() 사용
          }
        }
      },
      child: Scaffold(
          body: Stack(
            children: [
              ScaffoldPaddingWidget(
                child: IndexedStack(
                  index: tabState.selectedIndex,
                  children: _widgetOptions,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF573E3E).withOpacity(0.33),
                  spreadRadius: 1,
                  blurRadius: 15,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BottomAppBar(
                padding: EdgeInsets.zero,
                color: Colors.white,
                elevation: 0,
                child: SizedBox(
                  // 태블릿일 경우 적당한 높이로 조정
                  height: isTablet(context) ? 70.h : 60.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(barList.length, (index) {
                      final element = barList[index];
                      final bool _selected = tabState.selectedIndex == index;
      
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            if (index == 1) {
                              context.read<SelectedFoodProvider>().clearSelection();
                              context.push('/foodAdd');
                            } else {
                              tabState.setIndex(index);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 태블릿일 경우 위쪽 여백 약간만 추가
                              SizedBox(height: isTablet(context) ? 2.h : 0),
                              SizedBox(
                                height: isTablet(context) ? 28.h : 30.h, // 아이콘 크기 약간만 증가
                                child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        _selected ? Color(0xFF5E3009) : Color(0xFFAAAAAA),
                                        BlendMode.srcIn),
                                    child: Image(
                                      image: AssetImage(element[0]),
                                      width: isTablet(context) ? 32.w : 30.w,
                                    )),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                element[1],
                                style: TextStyle(
                                    color: _selected ? Color(0xFF5E3009) : Color(0xFFAAAAAA),
                                    fontSize: isTablet(context) ? 8.sp : 12.sp // 텍스트 크기 약간만 증가
                                    ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
