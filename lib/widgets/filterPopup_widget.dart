import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/filterButtons_widget.dart';
import '../funcs/_funcs.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class TopFullWidthPopup extends StatefulWidget {
  final String categoryTitle;
  final List<String> typeOptions;
  final bool hasSlider;
  final double? minSliderValue;
  final double? maxSliderValue;

  const TopFullWidthPopup({
    Key? key,
    required this.categoryTitle,
    required this.typeOptions,
    this.hasSlider = false,
    this.minSliderValue,
    this.maxSliderValue,
  }) : super(key: key);

  @override
  _TopFullWidthPopupState createState() => _TopFullWidthPopupState();
}

class _TopFullWidthPopupState extends State<TopFullWidthPopup> {
  List<String> selectedTypes = [];
  RangeValues? _currentRangeValues;
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterStatus = Provider.of<FilterStatus>(context, listen: false);
      final savedFilter = filterStatus.getFilter(widget.categoryTitle);

      if (savedFilter != null) {
        setState(() {
          selectedTypes = savedFilter.selectedValues;
          _currentRangeValues = savedFilter.rangeValues;
          isAllSelected = selectedTypes.contains('전체') || selectedTypes.contains('제한없음');
        });
      } else if (widget.hasSlider &&
          widget.minSliderValue != null &&
          widget.maxSliderValue != null) {
        _currentRangeValues = RangeValues(widget.minSliderValue!, widget.maxSliderValue!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterStatus = Provider.of<FilterStatus>(context, listen: false);
    final savedFilter = filterStatus.getFilter(widget.categoryTitle);

    // If there's a saved filter, update the local state
    if (savedFilter != null && selectedTypes.isEmpty) {
      selectedTypes = savedFilter.selectedValues;
      _currentRangeValues = savedFilter.rangeValues;
      isAllSelected = selectedTypes.contains('전체') || selectedTypes.contains('제한없음');
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        child: Container(
          color: Colors.black45.withOpacity(0.5),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ScaffoldPaddingWidget(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderWidget(title: '레시피 탐색'),
                  SizedBox(height: 10.h),
                  DottedBarWidget(),
                  SizedBox(height: 12.h),
                  _buildSearchAndFilter(),
                  SizedBox(height: 10.h),
                  _buildTypeSelection(),
                  if (widget.hasSlider) ...[
                    SizedBox(height: 10.h),
                    _buildSlider(),
                  ],
                  SizedBox(height: 10.h),
                  _buildButtons(),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          enabled: false,
          onChanged: (value) {},
          decoration: InputDecoration(
            filled: true,
              fillColor: Color(0xFFe6e6e6),
              hintText: '레시피 검색',
              hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Mapo',
                  fontSize: isTablet(context) ? 12.sp : 15.5.sp),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF5E3009),
                size: isTablet(context) ? 20.w : 30.w,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.w, vertical: isTablet(context) ? 5.h : 9.h),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Color(0xFF707070)),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Color(0xFF5E3009)))),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet(context) ? 50.h : 42.h,
          decoration: BoxDecoration(
            color: Color(0xFFEAE5DF),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 34.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/recipeFilter');
                  },
                  child: Image.asset(
                    'assets/imgs/icons/controlpanel.png',
                    width: 20.w,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
              Expanded(child: FilterButtonsWidget()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            widget.categoryTitle,
            style: TextStyle(color: Color(0xFF7D674B)),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: widget.typeOptions.map((type) => _buildTypeButton(type)).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    if (_currentRangeValues == null) {
      return SizedBox.shrink(); // 슬라이더 값이 없으면 아무것도 표시하지 않음
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
          ),
          child: RangeSlider(
            values: _currentRangeValues!,
            min: widget.minSliderValue!,
            max: widget.maxSliderValue!,
            divisions: ((widget.maxSliderValue! - widget.minSliderValue!) / 5).round(),
            activeColor: Color(0xFF5E3009),
            inactiveColor: Color(0xFFEAE5DF),
            labels: RangeLabels(
              _currentRangeValues!.start.round().toString(),
              _currentRangeValues!.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
                _updateSelectedTypesBasedOnSlider();
              });
            },
          ),
        ),
        Text(isAllSelected
            ? '제한없음'
            : '${_currentRangeValues!.start.round()} - ${_currentRangeValues!.end.round()}'),
      ],
    );
  }

  void _updateSelectedTypesBasedOnSlider() {
    selectedTypes.clear();
    isAllSelected = false;
    for (String option in widget.typeOptions) {
      if (option == '제한없음' || option == '전체') continue;
      List<String> range = option.replaceAll('%', '').replaceAll('개', '').split('~');
      double start = double.parse(range[0]);
      double end = range.length > 1 ? double.parse(range[1]) : start;
      if ((_currentRangeValues!.start <= start && start <= _currentRangeValues!.end) ||
          (_currentRangeValues!.start <= end && end <= _currentRangeValues!.end) ||
          (start <= _currentRangeValues!.start && _currentRangeValues!.end <= end)) {
        selectedTypes.add(option);
      }
    }
  }

  void _updateSliderBasedOnSelectedTypes() {
    if (selectedTypes.contains('제한없음') || selectedTypes.contains('전체')) {
      _currentRangeValues = RangeValues(widget.minSliderValue!, widget.maxSliderValue!);
      isAllSelected = true;
    } else if (selectedTypes.isNotEmpty) {
      double minValue = widget.maxSliderValue!;
      double maxValue = widget.minSliderValue!;
      for (String option in selectedTypes) {
        List<String> range = option.replaceAll('%', '').replaceAll('개', '').split('~');
        double start = double.parse(range[0]);
        double end = range.length > 1 ? double.parse(range[1]) : start;
        minValue = minValue < start ? minValue : start;
        maxValue = maxValue > end ? maxValue : end;
      }
      _currentRangeValues = RangeValues(minValue, maxValue);
      isAllSelected = false;
    }
  }

  Widget _buildTypeButton(String text) {
    bool isSelected = selectedTypes.contains(text);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (text == '전체' || text == '제한없음') {
            selectedTypes.clear();
            selectedTypes.add(text);
            isAllSelected = true;
          } else {
            if (isSelected) {
              selectedTypes.remove(text);
              // 여기서 수정: 모든 옵션이 선택 취소되면 기본값으로 돌아가도록 함
              if (selectedTypes.isEmpty) {
                if (widget.categoryTitle == '재료 개수' || widget.categoryTitle == '내 식재료 매치도') {
                  selectedTypes.add('제한없음');
                } else {
                  selectedTypes.add('전체');
                }
                isAllSelected = true;
              }
            } else {
              selectedTypes.remove('전체');
              selectedTypes.remove('제한없음');
              selectedTypes.add(text);
              isAllSelected = false;
            }
          }
          if (widget.hasSlider) {
            _updateSliderBasedOnSelectedTypes();
          }
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xFF505050),
          fontFamily: 'Mapo',
          fontSize: 12.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: isSelected ? Color(0xFFFA7B10) : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
        minimumSize: Size(0, 24.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "취소하기",
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'Mapo'),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Color(0xFF5E3009),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              minimumSize: Size.zero,
            ),
          ),
        ),
        Expanded(flex: 4, child: SizedBox.shrink()),
        Expanded(
          flex: 48,
          child: ElevatedButton(
            onPressed: () {

              final filterStatus = context.read<FilterStatus>();

              filterStatus.updateFilter(widget.categoryTitle, selectedTypes,
                  rangeValues: _currentRangeValues);
              context.pop();
            },
            child: Text(
              "적용하기",
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'Mapo'),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Color(0xFFFF8B27),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              minimumSize: Size.zero,
            ),
          ),
        ),
      ],
    );
  }
}

void showTopFullWidthPopup({
  required BuildContext context,
  required String categoryTitle,
  required List<String> typeOptions,
  bool hasSlider = false,
  double? minSliderValue,
  double? maxSliderValue,
}) {
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return TopFullWidthPopup(
          categoryTitle: categoryTitle,
          typeOptions: typeOptions,
          hasSlider: hasSlider,
          minSliderValue: minSliderValue,
          maxSliderValue: maxSliderValue,
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      routeSettings: RouteSettings(name: 'filterPopup'));
}
