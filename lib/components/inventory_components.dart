import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import '../models/_models.dart';

class InventoryComponents extends StatefulWidget {
  const InventoryComponents({super.key});

  @override
  State<InventoryComponents> createState() => _InventoryComponentsState();
}

class _InventoryComponentsState extends State<InventoryComponents> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const HeaderWidget(),
      SizedBox(height: 6.h,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "식재료 종류",
            style: TextStyle(color: Color(0xFF6C3311), fontSize: 18.sp),
          ),
          InkWell(
            onTap: () {
              context.push('/foodDel');
            },
            child: Image.asset('assets/imgs/icons/trash.png',width: 18.w,)
          )
        ],
      ),
      CategoryWidget(onTabSelected: _onTabSelected),
    ],);
  }
}
