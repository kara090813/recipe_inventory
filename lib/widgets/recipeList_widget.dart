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

class _RecipeListWidgetState extends State<RecipeListWidget> {
  final ScrollController _scrollController = ScrollController();
  static const int pageSize = 10;
  List<Recipe> _loadedRecipes = [];
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreRecipes();
  }

  // 두 리스트의 레시피 ID를 비교하여 실제로 변경되었는지 확인
  bool _recipesChanged(List<Recipe> newRecipes, List<Recipe> oldRecipes) {
    if (newRecipes.length != oldRecipes.length) return true;
    for (int i = 0; i < newRecipes.length; i++) {
      if (newRecipes[i].id != oldRecipes[i].id) return true;
    }
    return false;
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

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _loadedRecipes.addAll(
        widget.recipes.sublist(
          start,
          min(end, widget.recipes.length),
        ),
      );
      _hasMore = end < widget.recipes.length;
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200) {
      _loadMoreRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _loadedRecipes.isEmpty && _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.only(top: 10.h),
                  controller: _scrollController,
                  itemCount: _loadedRecipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCardWidget(recipe: _loadedRecipes[index],node:widget.node);
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
