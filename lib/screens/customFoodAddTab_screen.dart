import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../models/data.dart';
import '../widgets/_widgets.dart';

class CustomFoodAddTabScreen extends StatefulWidget {
  @override
  _CustomFoodAddTabScreenState createState() => _CustomFoodAddTabScreenState();
}

class _CustomFoodAddTabScreenState extends State<CustomFoodAddTabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'assets/imgs/food/unknownFood_a.png';
  String _selectedCategory = '기타';

  final Map<String, String> categoryIcons = {
    '과일': 'assets/imgs/food/fruit.png',
    '채소': 'assets/imgs/food/vegetable.png',
    '육류': 'assets/imgs/food/meat.png',
    '수산물': 'assets/imgs/food/seafood.png',
    '조미료/향신료': 'assets/imgs/food/condiment.png',
    '가공/유제품': 'assets/imgs/food/processed food.png',
    '기타': 'assets/imgs/food/unknownFood.png',
  };

  final List<String> availableIcons = [
    'assets/imgs/food/unknownFood_a.png',
    'assets/imgs/food/unknownFood_b.png',
    'assets/imgs/food/unknownFood_c.png',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: 16.h),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('아이콘 선택',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B))),
                    SizedBox(
                      height: 6.h,
                    ),
                    _buildIconSelector(),
                    SizedBox(height: 20.h),
                    Text('식재료명',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B))),
                    SizedBox(
                      height: 6.h,
                    ),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 14.sp,fontFamily: 'Mapo'),
                      decoration: InputDecoration(
                        hintText: '식재료 이름을 입력하세요',
                        contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 12.w),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(
                            color: Color(0xFF5E3009),
                          ),
                        ),
                        errorStyle: TextStyle(
                          fontFamily: 'Mapo',
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return '식재료 이름을 입력해주세요';
                        }

                        // 중복 검사
                        if (FOOD_LIST.any((food) => food.name == value)) {
                          _showDuplicateAlert(context);
                          return '이미 존재하는 식재료명입니다';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Text('카테고리 선택',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D674B))),
                    SizedBox(
                      height: 6.h,
                    ),
                    _buildCategorySelector(),
                    SizedBox(height: 30.h),
                    Expanded(child: SizedBox.shrink()),
                    ElevatedButton(
                      onPressed: _saveCustomFood,
                      child: Text(
                        '커스텀 식재료 추가하기',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: 'Mapo'),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF8B27),
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                    ),
                    SizedBox(
                      height: 20.h,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDuplicateAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.h),
                Text(
                  '중복된 식재료',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D674B)
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '이미 존재하는 식재료명입니다.\n다른 이름을 입력해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF707070),
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8B27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 10.w,
      children: availableIcons
          .map((icon) => GestureDetector(
        onTap: () {
          // 포커스 해제 추가
          FocusScope.of(context).unfocus();
          setState(() => _selectedIcon = icon);
        },
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _selectedIcon == icon ? Color(0xFF5E3009) : Color(0xFFEAE5DF),
            border: Border.all(
              color: _selectedIcon == icon ? Color(0xFFFFEFAD) : Color(0xFFEAE5DF),
              width: 2.w,
            ),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Image.asset(icon, width: 36.w, height: 36.w),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10.w,  // 가로 간격
      runSpacing: 10.h,  // 세로 간격 (줄 사이 간격)
      alignment: WrapAlignment.start,  // 시작점부터 정렬
      crossAxisAlignment: WrapCrossAlignment.center,  // 세로 정렬
      children: categoryIcons.entries
          .map((entry) => GestureDetector(
        onTap: () {
          // 포커스 해제 추가
          FocusScope.of(context).unfocus();
          setState(() => _selectedCategory = entry.key);
        },
        child: Container(
          margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,  // 필요한 만큼만 가로 공간 차지
            children: [
              Image.asset(entry.value, width: 30.w, height: 30.w),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  color: _selectedCategory == entry.key
                      ? Color(0xFF5E3009)
                      : Color(0xFFEAE5DF),
                  border: Border.all(
                    color: _selectedCategory == entry.key
                        ? Color(0xFFFFEFAD)
                        : Color(0xFFEAE5DF),
                    width: 2.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(entry.key,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: _selectedCategory == entry.key
                            ? Colors.white
                            : Color(0xFF5E3009))),
              ),
            ],
          ),
        ),
      ))
          .toList(),
    );
  }

  void _saveCustomFood() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newFood = Food(
        name: _nameController.text,
        type: _selectedCategory,
        img: _selectedIcon,
        isCustom: true,
      );

      final customFoodService = CustomFoodService();
      await customFoodService.addCustomFood(newFood);

      // FOOD_LIST에 추가
      FOOD_LIST.add(newFood);

      Navigator.pop(context);
      // foodAdd 화면도 닫아서 메인으로 돌아간 다음
      Navigator.pop(context);
      // 다시 foodAdd로 push
      context.push('/foodAdd');
    }
  }
}
