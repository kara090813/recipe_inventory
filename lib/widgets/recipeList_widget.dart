import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/_models.dart';
import 'recipeCard_widget.dart';

class RecipeListWidget extends StatefulWidget {
  final List<Recipe> recipes;
  final int recipesPerPage;

  const RecipeListWidget({
    Key? key,
    required this.recipes,
    this.recipesPerPage = 10,
  }) : super(key: key);

  @override
  State<RecipeListWidget> createState() => _RecipeListWidgetState();
}

class _RecipeListWidgetState extends State<RecipeListWidget> {
  List<Recipe> _loadedRecipes = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;


  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreRecipes();
    _scrollController.addListener(_scrollListener);
  }


  @override
  void didUpdateWidget(RecipeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipes != oldWidget.recipes) {
      setState(() {
        _loadedRecipes = [];
        _currentPage = 0;
        _hasMore = true;
      });
      _loadMoreRecipes();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 100) {
      _loadMoreRecipes();
      print('test');
    }
  }

  void _loadMoreRecipes() {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final int start = _currentPage * widget.recipesPerPage;
    final int end = start + widget.recipesPerPage;

    if (start < widget.recipes.length) {
      final List<Recipe> newRecipes = widget.recipes.sublist(
          start,
          end > widget.recipes.length ? widget.recipes.length : end
      );
      setState(() {
        _loadedRecipes.addAll(newRecipes);
        _currentPage++;
        _hasMore = end < widget.recipes.length;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
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
            padding: EdgeInsets.only(top:10.h),
            controller: _scrollController,
            itemCount: _loadedRecipes.length,
            itemBuilder: (context, index) {
              return RecipeCardWidget(recipe: _loadedRecipes[index]);
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
}