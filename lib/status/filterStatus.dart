import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FilterOption {
  final String name;
  final List<String> selectedValues;
  final RangeValues? rangeValues;

  FilterOption({
    required this.name,
    required this.selectedValues,
    this.rangeValues,
  });
}

class FilterStatus extends ChangeNotifier {
  static final Map<String, FilterOption> initfilters={
    '음식 종류': FilterOption(
      name: '음식 종류',
      selectedValues: ['전체'],
    ),
    '조리 난이도': FilterOption(
      name: '조리 난이도',
      selectedValues: ['전체'],
    ),
    '재료 개수': FilterOption(
      name: '재료 개수',
      selectedValues: ['제한없음'],
      rangeValues: RangeValues(0, 30),
    ),
    '내 식재료 매치도': FilterOption(
      name: '내 식재료 매치도',
      selectedValues: ['제한없음'],
      rangeValues: RangeValues(0, 100),
    )
  };

  Map<String, FilterOption> _filters = {
    '음식 종류': FilterOption(
      name: '음식 종류',
      selectedValues: ['전체'],
    ),
    '조리 난이도': FilterOption(
      name: '조리 난이도',
      selectedValues: ['전체'],
    ),
    '재료 개수': FilterOption(
      name: '재료 개수',
      selectedValues: ['제한없음'],
      rangeValues: RangeValues(0, 30),
    ),
    '내 식재료 매치도': FilterOption(
      name: '내 식재료 매치도',
      selectedValues: ['제한없음'],
      rangeValues: RangeValues(0, 100),
    )
  };

  void updateFilter(String filterName, List<String> selectedValues, {RangeValues? rangeValues}) {
    _filters[filterName] = FilterOption(
      name: filterName,
      selectedValues: selectedValues,
      rangeValues: rangeValues,
    );
    notifyListeners();
  }

  void clearFilters() {
    _filters.clear();
    notifyListeners();
  }

  // 특정 필터만 초기화하는 메서드
  void clearFilter(String filterName) {
    _filters.remove(filterName);
    notifyListeners();
  }

  FilterOption? getFilter(String filterName) {
    return _filters[filterName];
  }

  List<String> getSelectedValues(String filterName) {
    return _filters[filterName]?.selectedValues ?? [];
  }

  RangeValues? getRangeValues(String filterName) {
    return _filters[filterName]?.rangeValues;
  }

  Map<String, FilterOption> getAllFilters() {
    return Map.from(_filters);
  }

  bool isFilterSelected(String filterName) {
    if (!_filters.containsKey(filterName)) {
      return false;
    }

    final filter = _filters[filterName]!;

    // 선택된 값이 비어있거나, '전체' 또는 '제한없음'만 포함하고 있는 경우 선택되지 않은 것으로 간주
    bool isValueSelected = filter.selectedValues.isNotEmpty &&
        !filter.selectedValues.every((value) => value == '전체' || value == '제한없음');


    return isValueSelected;
  }
}
