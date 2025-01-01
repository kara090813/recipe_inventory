import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/widgets/_widgets.dart';

import '../status/_status.dart';
import '../funcs/_funcs.dart';

class CookHistoryScreen extends StatefulWidget {
  const CookHistoryScreen({Key? key}) : super(key: key);

  @override
  _CookHistoryScreenState createState() => _CookHistoryScreenState();
}

class _CookHistoryScreenState extends State<CookHistoryScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaffoldPaddingWidget(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildHeader(),
            SizedBox(height: 10.h),
            DottedBarWidget(),
            SizedBox(height: 20.h),
            _buildCalendar(),
            Divider(color: Color(0xFFA8927F), thickness: 1),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_selectedDate.day}일 ${getKoreanWeekday(_selectedDate.weekday)}요일',
                  style: TextStyle(fontSize: 18.sp),
                )),
            SizedBox(
              height: 8.h,
            ),
            Expanded(child: _buildCookingHistoryList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Image.asset(
              "assets/imgs/icons/back_arrow.png",
              width: 22.w,
            ),
          ),
        ),
        Center(
          child: Text(
            '요리 히스토리',
            style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildMonthHeader(),
        SizedBox(height: 10.h),
        _buildWeekdayHeader(),
        Divider(color: Color(0xFFA8927F), thickness: 1),
        _buildCalendarDays(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF7D674B)),
          onPressed: _previousMonth,
        ),
        Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              child: FractionallySizedBox(
                widthFactor: 1.2,
                child: Container(
                  height: 18.h,
                  color: Color(0xFFFFD8A8),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 0, bottom: 4.h),
              child: Text(
                '${_currentMonth.year}년 ${_currentMonth.month.toString().padLeft(2, '0')}월',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Color(0xFF7D674B)),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        Color color = Color(0xFF707070);
        if (day == '일') color = Colors.red;
        if (day == '토') color = Colors.blue;
        return Container(
          width: 40.w,
          alignment: Alignment.center,
          child: Text(day, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDays() {
    List<Widget> weekRows = [];
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    int currentWeek = 0;
    List<Widget> currentWeekWidgets = [];

    // Add days from previous month
    final daysFromPreviousMonth = firstDayOfMonth.weekday % 7;
    final lastDayOfPreviousMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);
    for (int i = daysFromPreviousMonth - 1; i >= 0; i--) {
      final date = lastDayOfPreviousMonth.subtract(Duration(days: i));
      currentWeekWidgets.add(_buildDayBox(date, isCurrentMonth: false));
    }

    // Add days for current month and next month
    for (int day = 1; day <= 42 - daysFromPreviousMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      currentWeekWidgets.add(_buildDayBox(date, isCurrentMonth: date.month == _currentMonth.month));

      if (currentWeekWidgets.length == 7) {
        weekRows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10.h), // 주 사이의 간격
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentWeekWidgets,
            ),
          ),
        );
        currentWeekWidgets = [];
        currentWeek++;
      }

      if (day >= lastDayOfMonth.day && date.weekday == DateTime.saturday) break;
    }

    return Column(children: weekRows);
  }

  Widget _buildDayBox(DateTime date, {required bool isCurrentMonth}) {
    bool isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    Color textColor = Colors.black;
    if (date.weekday == DateTime.sunday) textColor = Colors.red;
    if (date.weekday == DateTime.saturday) textColor = Colors.blue;
    if (!isCurrentMonth) textColor = textColor.withOpacity(0.3);

    // UserStatus에서 해당 날짜의 요리 개수를 가져옵니다.
    List<CookingHistory> cookHistory = Provider.of<UserStatus>(context, listen: false)
        .cookingHistory
        .where((history) =>
            history.dateTime.year == date.year &&
            history.dateTime.month == date.month &&
            history.dateTime.day == date.day)
        .toList();
    int cookCount = cookHistory.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          if (date.month != _currentMonth.month) {
            _currentMonth = DateTime(date.year, date.month);
          }
        });
      },
      child: Container(
        height: 60.h,
        width: 40.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFFFD8B7) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            if (isCurrentMonth && cookCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(min(cookCount, 3), (index) {
                  Color dotColor;
                  switch (index) {
                    case 0:
                      dotColor = Color(0xFFFFC860);
                      break;
                    case 1:
                      dotColor = Color(0xFFFF9945);
                      break;
                    case 2:
                      dotColor = Color(0xFFF78D8D);
                      break;
                    default:
                      dotColor = Colors.transparent;
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingHistoryList() {
    List<CookingHistory> cookHistory = Provider.of<UserStatus>(context, listen: false)
        .cookingHistory
        .where((history) =>
            history.dateTime.year == _selectedDate.year &&
            history.dateTime.month == _selectedDate.month &&
            history.dateTime.day == _selectedDate.day)
        .toList();

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: cookHistory.length,
      itemBuilder: (context, index) {
        CookingHistory history = cookHistory[index];
        String iconPath = 'assets/imgs/icons/history_icon${(index % 3) + 1}.png';
        Color backgroundColor =
            [Color(0xFFFFDD9E), Color(0xFFFFD1A9), Color(0xFFFFB4A9)][index % 3];

        return InkWell(
          onTap: (){
            context.push('/recipeInfo', extra: history.recipe);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]),
            child: Row(
              children: [
                Image.asset(iconPath, width: 18.w, height: 18.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    history.recipe.title,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                Text(
                  '${history.dateTime.year.toString().substring(2)}.${history.dateTime.month.toString().padLeft(2, '0')}.${history.dateTime.day.toString().padLeft(2, '0')} '
                  '${history.dateTime.hour.toString().padLeft(2, '0')}:${history.dateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10.sp, color: Color(0xFF707070)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
