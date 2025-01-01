import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/status/_status.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

class RecipeFilterScreen extends StatefulWidget {
  const RecipeFilterScreen({Key? key}) : super(key: key);

  @override
  _RecipeFilterScreenState createState() => _RecipeFilterScreenState();
}

class _RecipeFilterScreenState extends State<RecipeFilterScreen> {
  late FilterStatus _filterStatus;
  Map<String, FilterOption> _tempFilters = {};

  @override
  void initState() {
    super.initState();
    _filterStatus = Provider.of<FilterStatus>(context, listen: false);
    _initTempFilters();
  }

  void _initTempFilters() {
    _tempFilters = Map.from(_filterStatus.getAllFilters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldPaddingWidget(
          child: Column(
        children: [
          SizedBox(
            height: 4.h,
          ),
          SizedBox(
            height: 40.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80.w,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Image.asset(
                        'assets/imgs/icons/back_arrow.png',
                        width: 26.w,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 6.h,
                      ),
                      Text(
                        '전체 필터',
                        style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80.w,
                  child: TextButton(
                    onPressed: () {
                      _resetFilters();
                    },
                    child: Text(
                      '초기화',
                      style: TextStyle(color: Color(0xFFDB2222)),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          DottedBarWidget(),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection('음식 종류', ['전체', '한식', '양식', '중식', '일식', '아시안', '기타']),
                  SizedBox(
                    height: 20.h,
                  ),
                  _buildFilterSection('조리 난이도', ['전체', '쉬움', '보통', '어려움']),
                  SizedBox(
                    height: 20.h,
                  ),
                  _buildRangeFilterSection(
                    '재료 개수',
                    0,
                    30,
                    '개',
                    ['1~5개', '5~10개', '10~15개', '15~20개', '20~25개', '25~30개', '제한없음'],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  _buildRangeFilterSection(
                    '내 식재료 매치도',
                    0,
                    100,
                    '%',
                    ['제한없음', '0~20%', '20~40%', '40~60%', '60~80%', '80~100%', '100%'],
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: ElevatedButton(
          onPressed: _applyFilters,
          child: Text('필터 적용하기', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF8B27),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16.sp, color: Color(0xFF7D674B))),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) => _buildFilterButton(title, option)).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildFilterButton(String filterName, String option) {
    bool isSelected = _tempFilters[filterName]?.selectedValues.contains(option) ?? false;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (option == '전체' || option == '제한없음') {
            if (filterName == '재료 개수' || filterName == '내 식재료 매치도') {
              if (filterName == '재료 개수') {
                _tempFilters[filterName] = FilterOption(
                  name: filterName,
                  selectedValues: isSelected ? [] : [option],
                  rangeValues: RangeValues(0, 30),
                );
              } else {
                _tempFilters[filterName] = FilterOption(
                  name: filterName,
                  selectedValues: isSelected ? [] : [option],
                  rangeValues: RangeValues(0, 100),
                );
              }
            }
            _tempFilters[filterName] = FilterOption(
              name: filterName,
              selectedValues: isSelected ? [] : [option],
              rangeValues: null,
            );
          } else {
            List<String> currentValues = _tempFilters[filterName]?.selectedValues ?? [];
            if (isSelected) {
              currentValues.remove(option);
            } else {
              currentValues.remove('전체');
              currentValues.remove('제한없음');
              currentValues.add(option);
            }
            _tempFilters[filterName] = FilterOption(
              name: filterName,
              selectedValues: currentValues,
              rangeValues: _getRangeValuesFromSelectedOptions(filterName, currentValues),
            );
          }
        });
      },
      child: Text(
        option,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xFF505050),
          fontSize: 12.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF5E3009) : Color(0xFFEAE5DF),
        foregroundColor: isSelected ? Colors.white : Color(0xFF505050),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        minimumSize: Size(0, 24.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildRangeFilterSection(
      String title, double min, double max, String unit, List<String> options) {
    FilterOption? filterOption = _tempFilters[title];
    RangeValues currentRangeValues = filterOption?.rangeValues ?? RangeValues(min, max);

    bool showSlider = title != '음식 종류' && title != '조리 난이도';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, color: Color(0xFF7D674B))),
            SizedBox(width: 6.w),
            Text(
              _tempFilters[title]?.selectedValues.contains('제한없음') == true
                  ? '제한없음'
                  : '${currentRangeValues.start.round()} - ${currentRangeValues.end.round()}$unit',
              style: TextStyle(fontSize: 12.sp, color: Color(0xFFFF8B27)),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.round()}$unit',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
              Text(
                title == '재료 개수' ? '무제한' : '${max.round()}$unit',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (showSlider) ...[
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 1.h,
              rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 7.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
            ),
            child: RangeSlider(
              values: currentRangeValues,
              min: min,
              max: max,
              divisions: ((max - min) / 5).round(),
              labels: RangeLabels(
                "${currentRangeValues.start.round()}$unit",
                "${currentRangeValues.end.round()}$unit",
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  List<String> newSelectedOptions =
                      _getSelectedOptionsFromRangeValues(title, values, options);
                  _tempFilters[title] = FilterOption(
                    name: title,
                    selectedValues: newSelectedOptions,
                    rangeValues: values,
                  );
                });
              },
              activeColor: Color(0xFF5E3009),
              inactiveColor: Color(0xFFEAE5DF),
            ),
          ),
        ],
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) => _buildFilterButton(title, option)).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  RangeValues? _getRangeValuesFromSelectedOptions(String filterName, List<String> selectedOptions) {
    if (selectedOptions.isEmpty ||
        selectedOptions.contains('제한없음') ||
        selectedOptions.contains('전체')) {
      return null;
    }

    if (filterName == '음식 종류' || filterName == '조리 난이도') {
      return null;
    }

    double minValue = double.infinity;
    double maxValue = -double.infinity;

    for (String option in selectedOptions) {
      List<String> range = option.replaceAll('%', '').replaceAll('개', '').split('~');
      double start = double.parse(range[0]);
      double end = range.length > 1 ? double.parse(range[1]) : start;

      if (start < minValue) minValue = start;
      if (end > maxValue) maxValue = end;
    }

    return RangeValues(minValue, maxValue);
  }

  List<String> _getSelectedOptionsFromRangeValues(
      String filterName, RangeValues values, List<String> options) {
    List<String> newSelectedOptions = [];

    for (String option in options) {
      if (option == '제한없음' || option == '전체') continue;
      List<String> range = option.replaceAll('%', '').replaceAll('개', '').split('~');
      double start = double.parse(range[0]);
      double end = range.length > 1 ? double.parse(range[1]) : start;

      if ((values.start <= start && start <= values.end) ||
          (values.start <= end && end <= values.end) ||
          (start <= values.start && values.end <= end)) {
        newSelectedOptions.add(option);
      }
    }

    return newSelectedOptions.isEmpty ? ['제한없음'] : newSelectedOptions;
  }

  void _resetFilters() {
    setState(() {
      _tempFilters = FilterStatus.initfilters;
    });
  }

  void _applyFilters() {
    _filterStatus.clearFilters();
    _tempFilters.forEach((key, value) {
      _filterStatus.updateFilter(key, value.selectedValues, rangeValues: value.rangeValues);
    });
    Navigator.of(context).pop();
  }
}
