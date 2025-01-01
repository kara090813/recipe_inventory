import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberListWidget extends StatelessWidget {
  final List<String> items;

  const NumberListWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final time = extractTime(items[index]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        '${index + 1}.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(items[index],style: TextStyle(fontSize: 12.sp),),
                    ),
                  ],
                ),
              ),
              if (time != null)
                Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: TimerWidget(minutes: time),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final int minutes;

  const TimerWidget({Key? key, required this.minutes}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.minutes * 60;
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _secondsRemaining = widget.minutes * 60;
    });
    _timer?.cancel();
  }

  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int minutes = _secondsRemaining ~/ 60;
        int seconds = _secondsRemaining % 60;
        return AlertDialog(
          title: Text('타이머 설정'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberPicker(
                value: minutes,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) => minutes = value,
              ),
              Text('분'),
              SizedBox(width: 20),
              _buildNumberPicker(
                value: seconds,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) => seconds = value,
              ),
              Text('초'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  _secondsRemaining = minutes * 60 + seconds;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumberPicker({
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return NumberPicker(
      value: value,
      minValue: minValue,
      maxValue: maxValue,
      onChanged: onChanged,
      itemHeight: 32,
      itemWidth: 50,
      textStyle: TextStyle(fontSize: 16),
      selectedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFFEAE5DF),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.timer, size: 30.w, color: Color(0xFF6C3311)),
          Column(
            children: [
              Text(
                '요리타이머설정',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Color(0xFF6C3311)),
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: _showTimePickerDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${minutes.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Color(0xFF6C3311)),
                    ),
                    Text(
                      '분 ',
                      style: TextStyle(fontSize: 14.sp, color: Color(0xFF6C3311)),
                    ),
                    Text(
                      '${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Color(0xFF6C3311)),
                    ),
                    Text(
                      '초',
                      style: TextStyle(fontSize: 14.sp, color: Color(0xFF6C3311)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildTimerButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: _isRunning ? Icons.pause : Icons.play_arrow,
                color: Color(0xFFFF8B27),
              ),
              SizedBox(width: 8.w),
              _buildTimerButton(
                onPressed: _stopTimer,
                icon: Icons.stop,
                color: Color(0xFF6C3311),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, size: 20.w),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        padding: EdgeInsets.all(8.w),
        minimumSize: Size(36.w, 36.w),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

RegExp timeRegex = RegExp(r'(\d+)\s*(분|초)');

int? extractTime(String text) {
  final match = timeRegex.firstMatch(text);
  if (match != null) {
    int time = int.parse(match.group(1)!);
    if (match.group(2) == '초') {
      time = (time / 60).ceil(); // 초를 분으로 변환 (올림)
    }
    return time;
  }
  return null;
}