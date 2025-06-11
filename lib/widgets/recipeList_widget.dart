import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import 'recipeCard_widget.dart';

class RecipeListWidget extends StatefulWidget {
  final List<Recipe> recipes;
  final FocusNode node;

  const RecipeListWidget({Key? key, required this.recipes, required this.node}) : super(key: key);

  @override
  State<RecipeListWidget> createState() => _RecipeListWidgetState();
}

class _RecipeListWidgetState extends State<RecipeListWidget> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  static const int pageSize = 15; // 페이지 크기 증가로 스크롤 성능 개선
  List<Recipe> _loadedRecipes = [];
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreRecipes();
  }

  // 두 리스트의 레시피 ID를 비교하여 실제로 변경되었는지 확인
  bool _recipesChanged(List<Recipe> newRecipes, List<Recipe> oldRecipes) {
    if (newRecipes.length != oldRecipes.length) return true;
    
    // ID 기반 Set으로 비교하여 중복 체크
    final newIds = newRecipes.map((recipe) => recipe.id).toSet();
    final oldIds = oldRecipes.map((recipe) => recipe.id).toSet();
    
    return newIds.length != oldIds.length || newIds.difference(oldIds).isNotEmpty;
  }

  @override
  void didUpdateWidget(RecipeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_recipesChanged(widget.recipes, oldWidget.recipes)) {
      // 레시피 리스트가 실제로 변경된 경우에만 초기화
      _loadedRecipes = [];
      _hasMore = true;
      _loadMoreRecipes();
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final start = _loadedRecipes.length;
    final end = start + pageSize;

    if (start >= widget.recipes.length) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    await Future.delayed(Duration(milliseconds: 100)); // 지연 시간 단축

    if (mounted) { // mounted 체크로 메모리 누수 방지
      final newRecipes = widget.recipes.sublist(
        start,
        min(end, widget.recipes.length),
      );
      
      // 중복 제거 - 이미 로드된 레시피 ID들
      final loadedIds = _loadedRecipes.map((r) => r.id).toSet();
      final uniqueNewRecipes = newRecipes.where((recipe) => !loadedIds.contains(recipe.id)).toList();
      
      setState(() {
        _loadedRecipes.addAll(uniqueNewRecipes);
        _hasMore = end < widget.recipes.length;
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 300) { // threshold 증가로 로드 빈도 감소
      _loadMoreRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    return Column(
      children: [
        Expanded(
          child: _loadedRecipes.isEmpty && _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.only(top: 10.h),
                  controller: _scrollController,
                  itemCount: _loadedRecipes.length,
                  cacheExtent: 500, // 캐시 영역 설정으로 스크롤 성능 개선
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    // Key 추가로 위젯 재사용 최적화
                    return RecipeCardWidget(
                      key: ValueKey(_loadedRecipes[index].id),
                      recipe: _loadedRecipes[index],
                      node: widget.node,
                    );
                  },
                ),
        ),
        if (_isLoading && _loadedRecipes.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0.h),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
