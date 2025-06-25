import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import '../models/_models.dart';

class RecipeWishListScreen extends StatefulWidget {
  const RecipeWishListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeWishListScreen> createState() => _RecipeWishListScreenState();
}

class _RecipeWishListScreenState extends State<RecipeWishListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (_searchQuery.isEmpty) return recipes;
    return recipes.where((recipe) =>
        recipe.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isSearching) ...[
                  BackButtonWidget(context),
                  Text(
                    '레시피 위시리스트',
                    style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Color(0xFF5E3009)),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(width: 1, color: Color(0xFF707070)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬 추가
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            padding: EdgeInsets.zero, // 패딩 제거로 정렬 보정
                            constraints: BoxConstraints(), // 기본 제약 조건 제거
                            onPressed: () {
                              setState(() {
                                _isSearching = false;
                                _searchQuery = "";
                                _searchController.clear();
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center, // 텍스트필드 세로 중앙 정렬
                              style: TextStyle(fontSize: 14.sp),
                              decoration: InputDecoration(
                                hintText: '레시피 검색',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                                isDense: true, // 텍스트필드 높이 최적화
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              padding: EdgeInsets.zero, // 패딩 제거로 정렬 보정
                              constraints: BoxConstraints(), // 기본 제약 조건 제거
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = "";
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 20.h),
            Expanded(
              child: Consumer<RecipeStatus>(
                builder: (context, recipeStatus, child) {
                  final favoriteRecipes = _filterRecipes(recipeStatus.favoriteRecipes);

                  if (favoriteRecipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/items/cookLoading.png',
                            width: 80.w,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _searchQuery.isEmpty
                                ? '위시리스트가 비어있습니다.'
                                : '검색 결과가 없습니다.',
                            style: TextStyle(
                              color: Color(0xFFACACAC),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];
                      return RecipeListItem(recipe: recipe);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeListItem({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/recipeInfo', extra: recipe);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(color: Color(0xFFBB885E), width: 1.w),
        ),
        elevation: 4,
        child: Row(
          children: [
            RecipeThumbnailWidget(
              recipe: recipe,
              width: 120.w,
              height: 120.w,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                bottomLeft: Radius.circular(10.r),
              ),
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8B27),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<RecipeStatus>().toggleFavorite(recipe.id);
                          },
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24.w,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      recipe.sub_title,
                      style: TextStyle(fontSize: 12.sp, color: Color(0xFF707070)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: recipe.recipe_tags.map((tag) => Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFEAE5DF),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Color(0xFF5E3009),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}