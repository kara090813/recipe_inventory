import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/data.dart';

class CategoryWidget extends StatefulWidget {
  final Function(int) onTabSelected;

  CategoryWidget({super.key, required this.onTabSelected});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(FOOD_CATEGORY.length, (index) {
            return [
              ElevatedButton(
                onPressed: () {
                  widget.onTabSelected(index);
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Text(
                  FOOD_CATEGORY[index],
                  style: TextStyle(
                    fontFamily: 'Mapo',
                      color: _selectedIndex == index ? Colors.white : Color(0xFF707070),
                      fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == index ? Color(0xFF6C3311) : Color(0xFFE4E4E4),
                  padding: EdgeInsets.symmetric(vertical: 4.h,horizontal: 16.w), // 패딩을 없앰
                  minimumSize: Size.zero,
                ),
              ),
              SizedBox(
                width: 8.w,
              )
            ];
          }).expand((element) => element).toList()),
    );
  }
}
