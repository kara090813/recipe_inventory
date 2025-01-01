import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/status/_status.dart';
import '../widgets/_widgets.dart';
import '../components/_components.dart';
import '_screens.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {



  final List<List<dynamic>> barList = [
    ['assets/imgs/icons/bar_home.png', '냉장고',],
    ['assets/imgs/icons/bar_recomanded.png', '추천'],
    ['assets/imgs/icons/bar_cart.png', '식재료 추가'],
    ['assets/imgs/icons/bar_search.png', '탐색'],
    ['assets/imgs/icons/bar_my.png', '마이페이지']
  ];

  final List<Widget> _widgetOptions = <Widget>[
    InventoryComponents(),
    RecommendedRecipeComponent(),
    Container(),
    SearchRecipeComponent(),
    MyPageComponent()
  ];

  @override
  Widget build(BuildContext context) {
    final tabState = Provider.of<TabStatus>(context);


    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: IndexedStack(
          index: tabState.selectedIndex,
          children: _widgetOptions,
        ),
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
              blurRadius: 15, // 그림자 방향 조정
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
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(barList.length, (index) {
                  final element = barList[index];
                  final bool _selected = tabState.selectedIndex == index;

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        if (index == 2) {
                          context.read<SelectedFoodProvider>().clearSelection();
                          context.push('/foodAdd');
                        } else {
                          tabState.setIndex(index);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30.h,
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    _selected ? Color(0xFF5E3009) : Color(0xFFAAAAAA),
                                    BlendMode.srcIn
                                ),
                                child: Image(
                                  image:AssetImage(element[0]),
                                  width: 30.w,
                                )
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            element[1],
                            style: TextStyle(
                                color: _selected ? Color(0xFF5E3009) : Color(0xFFAAAAAA),
                                fontSize: 12.sp
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
      ),
    );
  }
}

