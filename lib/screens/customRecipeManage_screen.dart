import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/backButton_widget.dart';
import '../status/recipeStatus.dart';
import '../models/_models.dart';
import '../utils/custom_snackbar.dart';

class CustomRecipeManageScreen extends StatefulWidget {
  const CustomRecipeManageScreen({Key? key}) : super(key: key);

  @override
  State<CustomRecipeManageScreen> createState() => _CustomRecipeManageScreenState();
}

class _CustomRecipeManageScreenState extends State<CustomRecipeManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeStatus>().loadCustomRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: Consumer<RecipeStatus>(
                builder: (context, recipeStatus, child) {
                  final customRecipes = recipeStatus.customRecipes
                      .where((recipe) => recipe.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (customRecipes.isEmpty) {
                    return _searchQuery.isNotEmpty
                        ? _buildNoSearchResults()
                        : _buildEmptyState();
                  }

                  return _buildRecipeList(customRecipes);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          BackButtonWidget(context),
          Expanded(
            child: Text(
              '나의 레시피 관리',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8B27), Color(0xFFFF6B1A)],
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF8B27).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/customRecipe'),
                borderRadius: BorderRadius.circular(25.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 18.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '레시피 추가',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Color(0xFF8E8E93),
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '레시피 검색...',
                hintStyle: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Icon(
                Icons.clear,
                color: Color(0xFF8E8E93),
                size: 20.w,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60.w,
            color: Color(0xFFCCCCCC),
          ),
          SizedBox(height: 16.h),
          Text(
            '검색 결과가 없어요',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '다른 키워드로 검색해보세요',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80.w,
            color: Color(0xFFDDDDDD),
          ),
          SizedBox(height: 16.h),
          Text(
            '만든 레시피가 없어요',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF999999),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '나만의 특별한 레시피를\n만들어보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFFBBBBBB),
              height: 1.4,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => context.push('/custom'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8B27),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              '레시피 만들기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFFFF8B27).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/recipeInfo', extra: recipe),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                _buildThumbnailSection(recipe),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.sub_title.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          recipe.sub_title,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          _buildCompactTag(
                            text: recipe.difficulty,
                            color: _getDifficultyColor(recipe.difficulty),
                          ),
                          _buildCompactTag(
                            text: '재료 ${recipe.ingredients_cnt}개',
                            color: Color(0xFF666666),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _buildCompactMenuButton(recipe),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection(Recipe recipe) {
    return Container(
      width: 64.w,
      height: 64.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: _hasValidThumbnail(recipe)
            ? Image.network(
                recipe.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Color(0xFFF5F5F5),
                    child: Center(
                      child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF8B27),
                        ),
                      ),
                    ),
                  );
                },
              )
            : _buildFallbackThumbnail(),
      ),
    );
  }

  bool _hasValidThumbnail(Recipe recipe) {
    return recipe.thumbnail.isNotEmpty && 
           recipe.thumbnail != '' && 
           !recipe.thumbnail.contains('null') &&
           Uri.tryParse(recipe.thumbnail) != null;
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8B27), Color(0xFFFF6B1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.restaurant_menu,
        color: Colors.white,
        size: 24.w,
      ),
    );
  }

  Widget _buildCompactTag({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '매우 쉬움':
        return Color(0xFF6ECB63);
      case '쉬움':
        return Color(0xFFFAD643);
      case '보통':
        return Color(0xFFFF8B27);
      case '어려움':
        return Color(0xFFE84855);
      case '매우 어려움':
        return Color(0xFFC22557);
      default:
        return Color(0xFFFF8B27);
    }
  }

  Widget _buildCompactMenuButton(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF8B27).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Color(0xFFFF8B27).withOpacity(0.3), width: 0.5),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, recipe),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16.w,
                  color: Color(0xFF4CAF50),
                ),
                SizedBox(width: 8.w),
                Text(
                  '수정하기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 16.w,
                  color: Color(0xFFF44336),
                ),
                SizedBox(width: 8.w),
                Text(
                  '삭제하기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF44336),
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          padding: EdgeInsets.all(6.w),
          child: Icon(
            Icons.more_vert,
            size: 16.w,
            color: Color(0xFFFF8B27),
          ),
        ),
      ),
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '날짜 없음';
    }
  }

  void _handleMenuAction(String action, Recipe recipe) {
    switch (action) {
      case 'edit':
        _editRecipe(recipe);
        break;
      case 'delete':
        _deleteRecipe(recipe);
        break;
    }
  }

  void _editRecipe(Recipe recipe) {
    context.push('/custom-edit/${recipe.id}');
  }

  void _deleteRecipe(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '레시피 삭제',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: Text(
          '${recipe.title} 레시피를 삭제하시겠습니까?\n삭제된 레시피는 복구할 수 없습니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 16.sp,
                color: Color(0xFF999999),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<RecipeStatus>().deleteCustomRecipe(recipe.id);
              CustomSnackBar.showSuccess(context, '레시피가 삭제되었습니다.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              '삭제',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}