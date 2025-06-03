import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/status/_status.dart';
import '_widgets.dart';

class FilterButtonsWidget extends StatelessWidget {
  const FilterButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterStatus>(
      builder: (context, filterStatus, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 2.w),
              _buildFilterButton(context, '음식 종류', filterStatus),
              SizedBox(width: 8.w),
              _buildFilterButton(context, '조리 난이도', filterStatus),
              SizedBox(width: 8.w),
              _buildFilterButton(context, '재료 개수', filterStatus),
              SizedBox(width: 8.w),
              _buildFilterButton(context, '내 식재료 매치도', filterStatus),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(BuildContext context, String text, FilterStatus filterStatus) {
    bool isSelected = filterStatus.isFilterSelected(text);
    String displayText = _getDisplayText(text, filterStatus);

    return ElevatedButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (ModalRoute.of(context)?.settings.name == 'filterPopup') {
          context.pop();
        }
        _showFilterPopup(context, text);
      },
      child: Text(
        displayText,
        style: TextStyle(
          fontFamily: 'Mapo',
          color: isSelected ? Colors.white : Color(0xFF505050),
          fontSize: 12.sp,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: isSelected ? Color(0xFFFA7B10) : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        minimumSize: Size.zero,
      ),
    );
  }

  String _getDisplayText(String filterName, FilterStatus filterStatus) {
    FilterOption? filter = filterStatus.getFilter(filterName);
    if (filter == null || !filterStatus.isFilterSelected(filterName)) {
      return filterName;
    }

    if (filter.rangeValues != null) {
      if (filterName == '재료 개수') {
        return '${filter.rangeValues!.start.round()}~${filter.rangeValues!.end.round()} 개';
      } else {
        return '${filter.rangeValues!.start.round()}~${filter.rangeValues!.end.round()} %';
      }
    } else {
      String selectedValues = filter.selectedValues.join(', ');
      return '$selectedValues';
    }
  }

  void _showFilterPopup(BuildContext context, String text) {
    List<String> typeOptions;
    bool hasSlider = false;
    double? minSliderValue;
    double? maxSliderValue;

    switch (text) {
      case '음식 종류':
        typeOptions = ['전체', '한식', '양식', '중식', '일식', '아시안', '기타'];
        break;
      case '조리 난이도':
        typeOptions = ['전체', '매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];
        break;
      case '재료 개수':
        typeOptions = ['1~5개', '5~10개', '10~15개', '15~20개', '20~25개', '25~30개', '제한없음'];
        hasSlider = true;
        minSliderValue = 0;
        maxSliderValue = 30;
        break;
      case '내 식재료 매치도':
        typeOptions = ['제한없음', '0~20%', '20~40%', '40~60%', '60~80%', '80~100%', '100%'];
        hasSlider = true;
        minSliderValue = 0;
        maxSliderValue = 100;
        break;
      default:
        typeOptions = [];
    }

    showTopFullWidthPopup(
      context: context,
      categoryTitle: text,
      typeOptions: typeOptions,
      hasSlider: hasSlider,
      minSliderValue: minSliderValue,
      maxSliderValue: maxSliderValue,
    );
  }
}
