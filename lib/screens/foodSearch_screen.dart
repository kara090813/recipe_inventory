import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';
import 'package:recipe_inventory/status/_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../models/data.dart';
import '../funcs/_funcs.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Food> searchResults = [];
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        searchResults.clear();
      } else {
        searchResults = FOOD_LIST.where((food) {
          final name = food.name.toLowerCase();
          if (isChosungOrMixedString(query)) {
            return matchChosungOrMixed(query, name);
          } else {
            return name.contains(query);
          }
        }).toList();
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches.remove(search); // 이미 존재하는 경우 제거
      recentSearches.insert(0, search);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
    });
    await prefs.setStringList('recentSearches', recentSearches);
  }

  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: recentSearches.map((search) =>
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _onSearchChanged();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    search,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                ),
              ),
            )
        ).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<SelectedFoodProvider>(
      builder: (context, selectedFoodProvider, child) {
        return ListView.builder(
          padding: EdgeInsets.only(top:2.h),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final food = searchResults[index];
            final isSelected = selectedFoodProvider.isSelected(food);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                  child: Row(
                    children: [
                      Image.asset(food.img, width: 30.w,),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              food.name,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              food.type,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40.w,
                        height: 40.h,
                        child: GestureDetector(
                          onTap: () {
                            selectedFoodProvider.toggleFood(food);
                            if (!isSelected) {
                              _saveRecentSearch(food.name);
                            }
                          },
                          child: isSelected
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.green, size: 20.w),
                              Text('추가됨', style: TextStyle(fontSize: 10.sp, color: Colors.green)),
                            ],
                          )
                              : Icon(Icons.add_circle_outline, color: Colors.orange, size: 24.w),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < searchResults.length - 1) Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }


  void showCustomAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: Colors.white,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '최근 검색어를 모두 삭제할까요?',
              style: TextStyle(
                fontFamily: 'Mapo',
                color: Color(0xFF7D674B),
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFE8E8E8),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('닫기',style: TextStyle(color:Color(0xFF7D674B),fontSize: 16.sp,
                        fontWeight: FontWeight.bold,fontFamily: 'Mapo'),),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFFA7B1C),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        recentSearches.clear();
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('recentSearches');
                      Navigator.of(context).pop();
                    },
                    child: Text('삭제하기',style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight
                        .bold,fontFamily: 'Mapo')),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Image.asset('assets/imgs/icons/back_arrow.png', width: 26.w),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF5E3009)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 2.h),
                              hintText: '식재료 검색',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 16.sp,fontFamily:'Mapo'),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Image.asset(
                            'assets/imgs/icons/search.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_searchController.text.isEmpty) ...[
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 검색어', style: TextStyle(fontSize: 16.sp, color: Color(0xFF5E3009))),
                  GestureDetector(
                    onTap: (){
                      showCustomAlert(context);
                    },
                    child: Image.asset('assets/imgs/icons/trash.png', width: 18.w),
                  )
                ],
              ),
              SizedBox(height: 8.h),
              _buildRecentSearches(),
            ],
            Expanded(
              child: _searchController.text.isEmpty
                  ? Container() // 검색어가 없을 때는 빈 컨테이너
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
}