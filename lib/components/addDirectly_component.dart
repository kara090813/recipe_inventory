import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/components/_components.dart';
import 'package:recipe_inventory/funcs/_funcs.dart';
import 'package:recipe_inventory/status/_status.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import 'package:recipe_inventory/widgets/category_widget.dart';

class AddDirectlyComponent extends StatefulWidget {
  const AddDirectlyComponent({super.key});

  @override
  State<AddDirectlyComponent> createState() => _AddDirectlyComponentState();
}

class _AddDirectlyComponentState extends State<AddDirectlyComponent> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _widgetOptions = <Widget>[
    AddDirectlyAllComponent(),
    AddDirectlySelected_component(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (index == 0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double tabWidth = (MediaQuery.of(context).size.width - 44.w) / 2; // 패딩 고려

    return Column(
      children: [
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFFEAE5DF),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    left: 4.w + (tabWidth - 8.w) * _animation.value,
                    top: 4.h,
                    child: Container(
                      width: tabWidth - 8.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  _buildTab('전체 식재료', 0, tabWidth),
                  _buildTab('선택된 식재료', 1, tabWidth),
                ],
              ),
            ],
          ),
        ),
        if(isTablet(context))
          SizedBox(height: 10.h,),
        Expanded(child: _widgetOptions[_selectedTabIndex]),
        SizedBox(height: 10.h,),
        Consumer<SelectedFoodProvider>(
            builder: (context, provider, child) {
              return provider.selectedFoods.isEmpty ? SizedBox.shrink() : RoundedButtonPairWidget(
                  onLeftButtonPressed: () {
                    resetFoodFunc(context);
                  },
                  onRightButtonPressed: () {
                    addFoodFunc(provider.selectedFoods, context);
                  }
              );
            }
        ),
        SizedBox(height: 16.h,),
      ],
    );
  }

  Widget _buildTab(String text, int index, double width) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        width: width,
        height: 48.h,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF5E3009),
            fontSize: 14.sp,
            fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
