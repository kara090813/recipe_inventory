import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRecipeScreen extends StatefulWidget {
  const CustomRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CustomRecipeScreen> createState() => _CustomRecipeScreenState();
}

class _CustomRecipeScreenState extends State<CustomRecipeScreen> {
  int currentStep = 1;
  final PageController _pageController = PageController();

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

  final List<String> foodTypes = ['한식', '중식', '양식', '일식', '아시안'];
  final List<String> difficulties = ['매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];

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

  void _nextStep() {
    if (currentStep < 5) {
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 24.w, color: Colors.black),
          ),
          Expanded(
            child: Text(
              '나만의 레시피 만들기',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 24.w),
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
        child: Container(color: Color(0xFFFF8B27)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['기본정보', '재료추가', '요리과정', '추가정보', '미리보기'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          final stepNumber = index + 1;
          final isCompleted = currentStep > stepNumber;
          final isCurrent = currentStep == stepNumber;

          return Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? Color(0xFFFF8B27)
                      : Color(0xFFE0E0E0),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 18.w)
                      : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Color(0xFF888888),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '레시피의 기본정보를 알려주세요!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8B27),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '😊 맛있게 만들어주세요 :)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFFFF8B27),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 레시피 이름
          Text(
            '레시피 이름 😊',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _recipeNameController,
            decoration: InputDecoration(
              hintText: '진한한 토스트',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFFF8B27)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          TextField(
            controller: _recipeDescController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '우리 과자에 어린 시절에 대한 간단한 소개를 적어주세요 :)\n예) 소담한당 연변을 만나보실 것 같아요 토스트',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFFF8B27)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 24.h),

          // 음식 종류
          Text(
            '음식 종류 😊',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [...foodTypes, '기타'].map((type) =>
                _buildSelectionButton(type, selectedFoodType == type, () {
                  setState(() {
                    selectedFoodType = type;
                  });
                })
            ).toList(),
          ),
          SizedBox(height: 24.h),

          // 조리 난이도
          Text(
            '조리 난이도 😊',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: difficulties.map((difficulty) =>
                _buildSelectionButton(difficulty, selectedDifficulty == difficulty, () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                })
            ).toList(),
          ),
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
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '레시피의 재료를 추가해주세요!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8B27),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '😊 맛있게 만들어주세요 :)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFFFF8B27),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '재료 이름 😊',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _ingredientNameController,
                      decoration: InputDecoration(
                        hintText: '식빵',
                        hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFFF8B27)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                    Text(
                      '재료 양 😊',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _ingredientAmountController,
                      decoration: InputDecoration(
                        hintText: '2개, 200g 등등',
                        hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0xFFFF8B27)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          ElevatedButton(
            onPressed: _addIngredient,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8A634C),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
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
          SizedBox(height: 24.h),

          if (ingredients.isNotEmpty) ...[
            Text(
              '추가된 재료',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 12.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ingredient['name']}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${ingredient['amount']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _removeIngredient(index),
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요리과정을 작성해주세요!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8B27),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '😊 맛있게 만들어주세요 :)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFFFF8B27),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            '조리단계 작성 😊',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _cookingStepController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '식빵을 토스터기에 구워줍니다.',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFFF8B27)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 16.h),

          ElevatedButton(
            onPressed: _addCookingStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8A634C),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
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
          SizedBox(height: 24.h),

          if (cookingSteps.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: cookingSteps.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFF8B27)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF8B27),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '조리과정 기록',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFF8B27),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeCookingStep(index),
                            child: Icon(
                              Icons.close,
                              size: 20.w,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        cookingSteps[index],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // 주의사항
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              border: Border.all(color: Color(0xFFFF8B27)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Color(0xFFFF8B27), size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '조리하는데 기름을 투료 안하로 사람들이 쉽게 따라할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFFFF8B27),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              border: Border.all(color: Color(0xFFFF8B27)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Color(0xFFFF8B27), size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '노코빙에 식품 안전에 효과때려서 설딜 미디어.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFFFF8B27),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추가 정보를 작성해주세요!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8B27),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '😊 맛있게 만들어주세요 :)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFFFF8B27),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

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
            height: 200.h,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0), width: 2),
              borderRadius: BorderRadius.circular(8.r),
              color: Color(0xFFF9F9F9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 40.w,
                    color: Color(0xFF888888),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '여기를 눌러 이미지를 추가하세요',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF888888),
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    // 이미지 선택 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8A634C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  child: Text(
                    '이미지 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 태그 추가
          Text(
            '태그 추가',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              hintText: '간편함   토스트   자주스트',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFFF8B27)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
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
          TextField(
            controller: _youtubeLinkController,
            decoration: InputDecoration(
              hintText: 'https://www.youtube.com/@HUBOG',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFFFF8B27)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Preview() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Color(0xFFFF8B27),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Center(
                child: Text(
                  '레시피 미리보기',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 영역
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: AssetImage('assets/imgs/recipe_placeholder.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedFoodType,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  selectedDifficulty,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 레시피 제목
                  Text(
                    _recipeNameController.text.isEmpty
                        ? '진한한 토스트'
                        : _recipeNameController.text,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 레시피 설명
                  Text(
                    _recipeDescController.text.isEmpty
                        ? '전남친의 명예를 걸고쪽 요리를 받이용하겠 맛있는 토스트'
                        : _recipeDescController.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 재료
                  Text(
                    '재료',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F0E8),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Color(0x405E3009)),
                    ),
                    child: Column(
                      children: ingredients.isEmpty
                          ? [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('식빵', style: TextStyle(fontSize: 14.sp)),
                            Text('2개', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('블루베리잼', style: TextStyle(fontSize: 14.sp)),
                            Text('30g', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ]
                          : ingredients.map((ingredient) =>
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ingredient['name']!,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                Text(
                                  ingredient['amount']!,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                          )
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 조리과정
                  Text(
                    '조리과정',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (cookingSteps.isNotEmpty) ...[
                    ...cookingSteps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String step = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFFF8B27)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF8B27),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '조리과정 기록',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color(0xFFFF8B27),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              step,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFF8B27)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF8B27),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '조리과정 기록',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color(0xFFFF8B27),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '식빵을 토스터기에 구워줍니다.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 16.h),

                  // 주의사항
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3E6),
                      border: Border.all(color: Color(0xFFFF8B27)),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Color(0xFFFF8B27), size: 16.w),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '조리하는데 기름을 투료 안하로 사람들이 쉽게 따라할 수 있습니다.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Color(0xFFFF8B27),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3E6),
                      border: Border.all(color: Color(0xFFFF8B27)),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Color(0xFFFF8B27), size: 16.w),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '노코빙에 식품 안전에 효과때려서 설딜 미디어.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Color(0xFFFF8B27),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFA7B10) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? Color(0xFFFA7B10) : Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF505050),
            fontSize: 12.sp,
            fontFamily: 'Mapo',
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          if (currentStep > 1) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF888888),
                  minimumSize: Size(0, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
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
                  ? () {
                // 레시피 저장 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('레시피가 저장되었습니다!')),
                );
              }
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8B27),
                minimumSize: Size(0, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                currentStep == 5 ? '레시피 저장하기' : '다음',
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
}