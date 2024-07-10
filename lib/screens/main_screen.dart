import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/_widgets.dart';
import '../components/_components.dart';
import '_screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<List<dynamic>> barList = [
    ['assets/imgs/icons/bar_home.png', '냉장고 관리', 24.w],
    ['assets/imgs/icons/bar_cart.png', '식재료 추가', 34.w],
    ['assets/imgs/icons/bar_search.png', '레시피 탐색', 42.w],
    ['assets/imgs/icons/bar_recomanded.png', '레시피 추천', 34.w],

  ];

  final List<Widget> _widgetOptions = <Widget>[
    InventoryComponents(),
    Container(),
    Container(),
    Container(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
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
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomAppBar(
            padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 0),
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(barList.length, (index) {
                  final element = barList[index];
                  final bool _selected = _selectedIndex == index;
                  EdgeInsets _edge = EdgeInsets.only();

                  return Padding(
                    padding: _edge,
                    child: InkWell(
                      onTap: () => _onItemTapped(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 38.h,
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    _selected ? Theme.of(context).primaryColor : Color(0xFFAAAAAA),
                                    BlendMode.srcIn),
                                child: Image.asset(
                                  element[0],
                                  width: element[2],
                                )),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            element[1],
                            style: TextStyle(
                                color:
                                    _selected ? Theme.of(context).primaryColor : Color(0xFFAAAAAA),
                                fontSize: 12.sp),
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
