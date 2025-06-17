import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import '../widgets/backButton_widget.dart';
import '../status/userStatus.dart';
import '../status/recipeStatus.dart';
import '../services/hive_service.dart';
import '../models/_models.dart';
import '../utils/custom_snackbar.dart';

class CustomRecipeEditScreen extends StatefulWidget {
  final String recipeId;
  
  const CustomRecipeEditScreen({
    Key? key, 
    required this.recipeId,
  }) : super(key: key);

  @override
  State<CustomRecipeEditScreen> createState() => _CustomRecipeEditScreenState();
}

class _CustomRecipeEditScreenState extends State<CustomRecipeEditScreen> {
  int currentStep = 1;
  final PageController _pageController = PageController();
  Recipe? originalRecipe;

  // 폼 데이터
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _recipeDescController = TextEditingController();
  final TextEditingController _ingredientNameController = TextEditingController();
  final TextEditingController _ingredientAmountController = TextEditingController();
  final TextEditingController _cookingStepController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();

  String selectedFoodType = '한식';
  String selectedDifficulty = '매우 쉬움';
  List<Map<String, String>> ingredients = [];
  List<String> cookingSteps = [];
  List<String> tags = [];
  String _currentTagInput = '';

  final List<String> foodTypes = ['한식', '중식', '일식', '양식', '아시안', '기타'];
  final List<String> difficulties = ['매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeForEdit();
    });
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeDescController.dispose();
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    _cookingStepController.dispose();
    _tagsController.dispose();
    _youtubeLinkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadRecipeForEdit() {
    try {
      final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
      final recipe = recipeStatus.customRecipes.firstWhere(
        (r) => r.id == widget.recipeId,
        orElse: () => throw Exception('레시피를 찾을 수 없습니다.'),
      );

      setState(() {
        originalRecipe = recipe;
        _recipeNameController.text = recipe.title;
        _recipeDescController.text = recipe.sub_title;
        selectedFoodType = recipe.recipe_type;
        selectedDifficulty = recipe.difficulty;
        ingredients = recipe.ingredients.map((ingredient) => {
          'name': ingredient.food,
          'amount': ingredient.cnt,
        }).toList();
        cookingSteps = List.from(recipe.recipe_method);
        tags = List.from(recipe.recipe_tags);
        _youtubeLinkController.text = recipe.youtubeUrl;
      });
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, '레시피를 불러올 수 없습니다.');
        context.go('/');
      }
    }
  }

  Future<void> _updateRecipe() async {
    // 필수 필드 검증
    if (_recipeNameController.text.isEmpty || 
        ingredients.isEmpty || 
        cookingSteps.isEmpty) {
      CustomSnackBar.showError(context, '필수 항목을 모두 입력해주세요.');
      return;
    }

    if (originalRecipe == null) {
      CustomSnackBar.showError(context, '원본 레시피 정보를 찾을 수 없습니다.');
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      
      final updatedRecipe = originalRecipe!.copyWith(
        title: _recipeNameController.text,
        sub_title: _recipeDescController.text,
        recipe_type: selectedFoodType,
        difficulty: selectedDifficulty,
        ingredients_cnt: ingredients.length,
        ingredients: ingredients.map((ingredient) => Ingredient(
          food: ingredient['name']!,
          cnt: ingredient['amount']!,
        )).toList(),
        recipe_method: cookingSteps,
        recipe_tags: tags,
        youtubeUrl: _youtubeLinkController.text,
        updatedAt: now,
      );
      
      // 커스텀 레시피 업데이트
      await HiveService.updateCustomRecipe(updatedRecipe);
      
      // RecipeStatus 업데이트
      if (mounted) {
        await Provider.of<RecipeStatus>(context, listen: false).loadCustomRecipes();
      }
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  '레시피 수정 완료!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${_recipeNameController.text} 레시피가\n성공적으로 수정되었습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/');
                },
                child: Text(
                  '홈으로 가기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('레시피 수정 실패: $e');
      if (mounted) {
        CustomSnackBar.showError(context, '레시피 수정에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 1:
        return _recipeNameController.text.isNotEmpty;
      case 2:
        return ingredients.isNotEmpty;
      case 3:
        return cookingSteps.isNotEmpty;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (currentStep < 5) {
      // 필수항목 검증
      if (!_validateCurrentStep()) {
        String message = '';
        switch (currentStep) {
          case 1:
            message = '레시피 이름을 입력해주세요.';
            break;
          case 2:
            message = '재료를 최소 1개 이상 추가해주세요.';
            break;
          case 3:
            message = '조리과정을 최소 1개 이상 추가해주세요.';
            break;
        }
        CustomSnackBar.showError(context, message);
        return;
      }

      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addIngredient() {
    if (_ingredientNameController.text.isNotEmpty &&
        _ingredientAmountController.text.isNotEmpty) {
      setState(() {
        ingredients.add({
          'name': _ingredientNameController.text,
          'amount': _ingredientAmountController.text,
        });
      });
      _ingredientNameController.clear();
      _ingredientAmountController.clear();
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void _addCookingStep() {
    if (_cookingStepController.text.isNotEmpty) {
      setState(() {
        cookingSteps.add(_cookingStepController.text);
      });
      _cookingStepController.clear();
    }
  }

  void _removeCookingStep(int index) {
    setState(() {
      cookingSteps.removeAt(index);
    });
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
      setState(() {
        tags.add(tag.trim());
      });
    }
  }

  void _onTagInputChanged(String value) {
    setState(() {
      _currentTagInput = value;
    });
    
    if (value.endsWith(' ') || value.endsWith(',')) {
      String tag = value.substring(0, value.length - 1).trim();
      if (tag.isNotEmpty) {
        _addTag(tag);
        _tagsController.clear();
        setState(() {
          _currentTagInput = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2Ingredients(),
                  _buildStep3CookingProcess(),
                  _buildStep4AdditionalInfo(),
                  _buildStep5Preview(),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          BackButtonWidget(context),
          Expanded(
            child: Text(
              '레시피 수정하기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D674B),
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 48.w), // BackButton과 균형을 맞추기 위한 공간
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4.h,
      color: Color(0xFFE0E0E0),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentStep / 5,
        child: Container(color: Color(0xFFFF8C00)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['기본정보', '재료수정', '요리과정', '추가정보', '미리보기'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Stack(
        children: [
          // 연결선
          Positioned(
            left: 60.w,
            right: 60.w,
            top: 20.w - 1.h,
            child: Container(
              height: 2.h,
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 2.h,
                      color: currentStep > index + 1
                          ? Color(0xFFFF8C00)
                          : Color(0xFFE0E0E0),
                    ),
                  );
                }),
              ),
            ),
          ),
          // 스텝 원형들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final stepNumber = index + 1;
              final isActive = currentStep == stepNumber;
              final isCompleted = currentStep > stepNumber;

              return Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive 
                          ? Colors.white
                          : isCompleted
                              ? Color(0xFFFF8C00)
                              : Color(0xFFE0E0E0),
                      border: isActive 
                          ? Border.all(color: Color(0xFFFF8C00), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20.w,
                            )
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                color: isActive 
                                    ? Color(0xFFFF8C00)
                                    : Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isActive ? Color(0xFFFF8C00) : Color(0xFF666666),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGuideHeader(String title, {bool showRequiredIndicator = true}) {
    return Column(
      children: [
        Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              child: Container(
                height: 14.h,
                color: Color(0xFFFFD8A8),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (showRequiredIndicator) ...[
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imgs/items/point_yellow.png',
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '은 필수입력 항목입니다',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildStepGuideHeader('레시피의 기본정보를 수정해주세요!')),
          SizedBox(height: 32.h),

          // 레시피 이름
          Row(
            children: [
              Text(
                '레시피 이름',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset(
                'assets/imgs/items/point_yellow.png',
                width: 16.w,
                height: 16.w,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _recipeNameController,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '전남친 토스트',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 레시피 소개
          Text(
            '레시피 소개',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _recipeDescController,
              maxLines: 4,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '우리 레시피에 대한 간단한 소개를 적어주세요 :)\n예) 달콤하면서 짭짤한 맛이 일품인 토스트예요',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 음식 종류
          Row(
            children: [
              Text(
                '음식 종류',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset(
                'assets/imgs/items/point_yellow.png',
                width: 16.w,
                height: 16.w,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: foodTypes.map((type) => 
                _buildSelectionChip(type, selectedFoodType == type, () {
                  setState(() {
                    selectedFoodType = type;
                  });
                })
            ).toList(),
          ),
          SizedBox(height: 24.h),

          // 조리 난이도
          Row(
            children: [
              Text(
                '조리 난이도',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset(
                'assets/imgs/items/point_yellow.png',
                width: 16.w,
                height: 16.w,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: difficulties.map((difficulty) => 
                _buildSelectionChip(difficulty, selectedDifficulty == difficulty, () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                })
            ).toList(),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildStep2Ingredients() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildStepGuideHeader('레시피의 재료를 수정해주세요!')),
          SizedBox(height: 32.h),

          // 재료 입력 필드
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '재료 이름',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Image.asset(
                          'assets/imgs/items/point_yellow.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _ingredientNameController,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '식빵',
                          hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFBB885E)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFBB885E)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '재료 양',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Image.asset(
                          'assets/imgs/items/point_yellow.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _ingredientAmountController,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '2개',
                          hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFBB885E)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFBB885E)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 재료 추가 버튼
          ElevatedButton(
            onPressed: _addIngredient,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5D4037),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '재료 추가하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // 추가된 재료 리스트
          if (ingredients.isNotEmpty) ...[
            Text(
              '추가된 재료',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 16.h),
            Column(
              children: List.generate(ingredients.length, (index) {
                final ingredient = ingredients[index];
                
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDF8F4),
                    border: Border.all(color: Color(0xFFDEB887), width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingredient['name']!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 20.h,
                        color: Color(0xFFDEB887),
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      Text(
                        ingredient['amount']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => _removeIngredient(index),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3CookingProcess() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildStepGuideHeader('요리과정을 수정해주세요!')),
          SizedBox(height: 16.h),

          // 안내 메시지
          if (cookingSteps.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Color(0xFFF0F8FF),
                border: Border.all(color: Color(0xFF87CEEB), width: 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF4682B4),
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '요리단계를 꾹 눌러서 드래그하면 순서를 변경할 수 있어요!',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF4682B4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(height: 16.h),

          // 조리단계 작성
          Row(
            children: [
              Text(
                '조리단계 작성',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset(
                'assets/imgs/items/point_yellow.png',
                width: 16.w,
                height: 16.w,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _cookingStepController,
              maxLines: 4,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '식빵을 프라이팬에 구워주다.',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 단계 추가하기 버튼
          ElevatedButton(
            onPressed: _addCookingStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5D4037),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '단계 추가하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // 추가된 조리과정 (드래그 앤 드롭 가능)
          if (cookingSteps.isNotEmpty) ...[
            Text(
              '추가된 조리과정',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 16.h),
            ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = cookingSteps.removeAt(oldIndex);
                  cookingSteps.insert(newIndex, item);
                });
              },
              children: cookingSteps.asMap().entries.map((entry) {
                int index = entry.key;
                String step = entry.value;
                
                return Container(
                  key: ValueKey('step_$index'),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFFDF8F4),
                      border: Border.all(color: Color(0xFFDEB887), width: 2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        // 드래그 핸들
                        Icon(
                          Icons.drag_handle,
                          color: Color(0xFF999999),
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF8C00),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xFF5D4037),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeCookingStep(index),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4AdditionalInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildStepGuideHeader('추가 정보를 수정해주세요!')),
          SizedBox(height: 32.h),

          // 썸네일 이미지
          Text(
            '썸네일 이미지',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              color: Color(0xFFF6E7DB),
              border: Border.all(width: 2, color: Color(0xFFA8927F)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: InkWell(
              onTap: () {
                // 이미지 선택 로직
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/items/camera.png',
                    width: 60.w,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    '여기를 눌러 이미지를 수정하세요',
                    style: TextStyle(
                      color: Color(0xFF6C3311),
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '갤러리에서 새로운 썸네일 이미지를\n선택해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF898989),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 태그 추가
          Text(
            '태그 수정',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          _buildTagInput(),
          SizedBox(height: 24.h),

          // 참고 영상 링크
          Text(
            '참고 영상 링크',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _youtubeLinkController,
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'https://www.youtube.com/HUBOG',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFBB885E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Preview() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Center(child: _buildStepGuideHeader('수정된 레시피 미리보기', showRequiredIndicator: false)),
          SizedBox(height: 32.h),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF8F5F0),
              border: Border.all(color: Color(0xFFDEB887), width: 1.5),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // 레시피 제목
              Text(
                _recipeNameController.text.isEmpty
                    ? '전남친 토스트'
                    : _recipeNameController.text,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              SizedBox(height: 8.h),
              
              // 레시피 설명
              if (_recipeDescController.text.isNotEmpty) ...[
                Text(
                  _recipeDescController.text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF8D6E63),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20.h),
              ] else
                SizedBox(height: 20.h),

              // 이미지
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 60.w,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 레시피 타입 | 난이도 섹션
              Text(
                '$selectedFoodType | $selectedDifficulty',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                ),
              ),
              SizedBox(height: 16.h),

              // 태그들
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: tags.map((tag) => _buildPreviewTag(tag)).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              // 재료 (개수)
              Text(
                '재료 (${ingredients.length}개)',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFDF8F4),
                  border: Border.all(color: Color(0xFFDEB887), width: 2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: ingredients.map((ingredient) => 
                    _buildPreviewIngredientRow(
                      ingredient['name']!,
                      ingredient['amount']!,
                    )
                  ).toList(),
                ),
              ),
              SizedBox(height: 32.h),

              // 조리과정
              Text(
                '조리과정',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                ),
              ),
              SizedBox(height: 16.h),
              ...cookingSteps.asMap().entries.map((entry) {
                int index = entry.key;
                String step = entry.value;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDF8F4),
                    border: Border.all(color: Color(0xFFDEB887), width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8C00),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5D4037) : Color(0xFFEAE5DF),
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected ? null : Border.all(color: Color(0xFFD0C5BA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF666666),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFE8DDD4),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Color(0xFF5D4037),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreviewIngredientRow(String name, String amount) {
    // 텍스트 길이에 따라 폰트 크기 조절
    final nameLength = name.length;
    final amountLength = amount.length;
    final baseFontSize = 16.sp;
    final nameFontSize = nameLength > 8 ? baseFontSize * 0.9 : baseFontSize;
    final amountFontSize = amountLength > 8 ? baseFontSize * 0.9 : baseFontSize;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Text(
              name,
              style: TextStyle(
                fontSize: nameFontSize,
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 1.w,
            height: 20.h,
            color: Color(0xFFDEB887),
            margin: EdgeInsets.symmetric(horizontal: 12.w),
          ),
          Expanded(
            flex: 3,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: amountFontSize,
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 1) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF888888),
                  minimumSize: Size(0, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '이전',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: currentStep == 5
                  ? () => _updateRecipe()
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8C00),
                minimumSize: Size(0, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                currentStep == 5 ? '레시피 수정 완료' : '다음',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagInput() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFBB885E)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: tags.map((tag) => 
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Color(0xFFB3D9FF)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tags.remove(tag);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 14.w,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                )
              ).toList(),
            ),
            SizedBox(height: 8.h),
          ],
          TextField(
            controller: _tagsController,
            onChanged: _onTagInputChanged,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _addTag(value.trim());
                _tagsController.clear();
                setState(() {
                  _currentTagInput = '';
                });
              }
            },
            decoration: InputDecoration(
              hintText: '태그를 입력하고 스페이스바 또는 엔터를 눌러주세요',
              hintStyle: TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}