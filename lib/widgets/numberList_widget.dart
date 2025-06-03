import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/_models.dart';

class NumberListWidget extends StatelessWidget {
  final List<String> items;
  final List<Ingredient> ingredients; // 레시피 식재료 리스트 추가

  const NumberListWidget({
    Key? key,
    required this.items,
    required this.ingredients,
  }) : super(key: key);

  // 텍스트에서 식재료를 하이라이트하는 함수
  List<TextSpan> _highlightIngredients(String text) {
    List<TextSpan> spans = [];
    String remainingText = text;

    while (remainingText.isNotEmpty) {
      bool foundIngredient = false;

      // 가장 긴 매칭을 먼저 찾기 위해 식재료 정렬
      final sortedIngredients = [...ingredients]..sort(
              (a, b) => b.food.length.compareTo(a.food.length)
      );

      for (var ingredient in sortedIngredients) {
        int index = remainingText.toLowerCase().indexOf(ingredient.food.toLowerCase());
        if (index == 0) {
          // 식재료 발견 시 하이라이트 처리
          spans.add(TextSpan(
            text: remainingText.substring(0, ingredient.food.length),
            style: TextStyle(
              fontSize: 16.sp,
              color:Colors.black,
              fontFamily: 'Mapo',
              backgroundColor: Color(0xFFFFD8B7),
            ),
          ));
          remainingText = remainingText.substring(ingredient.food.length);
          foundIngredient = true;
          break;
        }
      }

      if (!foundIngredient) {
        // 일반 텍스트 처리
        int nextIndex = remainingText.length;
        for (var ingredient in ingredients) {
          int index = remainingText.toLowerCase().indexOf(ingredient.food.toLowerCase());
          if (index > 0 && index < nextIndex) {
            nextIndex = index;
          }
        }
        spans.add(TextSpan(
          text: remainingText.substring(0, nextIndex),
          style: TextStyle(fontSize: 16.sp,color: Colors.black,fontFamily: 'Mapo',),
        ));
        remainingText = remainingText.substring(nextIndex);
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final time = extractTime(items[index]);
        return Container(
          margin: EdgeInsets.only(bottom: 22.h),
          decoration: BoxDecoration(
            color: Color(0xFFF6F0E8),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30.w,
                      child: Text(
                        '${index + 1}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: _highlightIngredients(items[index]),
                        ),
                      ),
                    ),
                  ],
                ),
                if (time != null) ...[
                  SizedBox(height: 12.h),
                  TimerWidget(durationInSeconds: time),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final int durationInSeconds;

  const TimerWidget({Key? key, required this.durationInSeconds})
      : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with TickerProviderStateMixin{
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;  // 타이머 완료 상태 추가
  late AnimationController _flashingController;
  late Animation<Color?> _colorAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInSeconds;

    _flashingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
      // 완료 상태에서만 반복 애니메이션 실행
      if (_isCompleted) {
        if (status == AnimationStatus.completed) {
          _flashingController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _flashingController.forward();
        }
      }
    });

    _colorAnimation = ColorTween(
      begin: Color(0xFFF7F2ED),
      end: Color(0xFFFFD8A8),
    ).animate(_flashingController);
  }

  void _startTimer() {
    if (_secondsRemaining <= 0 || _isCompleted) return;  // 완료 상태에서는 시작 불가
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          if (_secondsRemaining == 0) {
            _onTimerComplete();
          }
        }
      });
    });
  }

  void _onTimerComplete() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });

    try {
      // 진동 패턴 설정 (밀리초 단위)
      // [대기시간, 진동시간, 대기시간, 진동시간, ...]
      final vibrationPattern = [0, 500, 200, 500];

      // 진동 지원 여부 확인
      if (await Vibration.hasVibrator() ?? false) {
        if (await Vibration.hasCustomVibrationsSupport() ?? false) {
          // 패턴 진동 지원시
          Vibration.vibrate(pattern: vibrationPattern);
        } else {
          // 일반 진동만 지원시
          Vibration.vibrate(duration: 1000);
        }
      }

      // 알람 소리 재생
      await _audioPlayer.play(AssetSource('data/alarm.mp3'));

    } catch (e) {
      print('피드백 재생 실패: $e');
    }

    _flashingController.forward();
  }

  void _pauseTimer() {
    if (_isCompleted) return;  // 완료 상태에서는 일시정지 불가
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    _flashingController.stop();
    _flashingController.reset();
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _secondsRemaining = widget.durationInSeconds;
    });

    // 배경색을 처음 상태로 강제 변경
    _colorAnimation = ColorTween(
      begin: Color(0xFFF7F2ED),
      end: Color(0xFFF7F2ED),
    ).animate(_flashingController);
  }

  void _showTimePickerDialog() {
    // 현재 값으로 초기화
    int currentHours = _secondsRemaining ~/ 3600;
    int currentMinutes = (_secondsRemaining % 3600) ~/ 60;
    int currentSeconds = _secondsRemaining % 60;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('타이머 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberPicker(
                        label: '시간',
                        value: currentHours,
                        minValue: 0,
                        maxValue: 23,
                        onChanged: (value) => setState(() => currentHours = value),
                      ),
                      SizedBox(width: 10),
                      _buildNumberPicker(
                        label: '분',
                        value: currentMinutes,
                        minValue: 0,
                        maxValue: 59,
                        onChanged: (value) => setState(() => currentMinutes = value),
                      ),
                      SizedBox(width: 10),
                      _buildNumberPicker(
                        label: '초',
                        value: currentSeconds,
                        minValue: 0,
                        maxValue: 59,
                        onChanged: (value) => setState(() => currentSeconds = value),
                      ),
                    ],
                  ),
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
                    // 부모 위젯의 상태를 업데이트
                    this.setState(() {
                      _secondsRemaining = currentHours * 3600 +
                          currentMinutes * 60 +
                          currentSeconds;
                      _isCompleted = false;  // 완료 상태 초기화

                      // 애니메이션 컨트롤러 초기화
                      _flashingController.reset();
                      _colorAnimation = ColorTween(
                        begin: Color(0xFFF7F2ED),
                        end: Color(0xFFFFD8A8),
                      ).animate(_flashingController);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(label),
        NumberPicker(
          value: value,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
          itemHeight: 32,
          itemWidth: 50,
          textStyle: TextStyle(fontSize: 16, color: Colors.grey),
          selectedTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black26),
              bottom: BorderSide(color: Colors.black26),
            ),
          ),
        ),
      ],
    );
  }



  Widget _formatTimeWidget(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    List<Widget> parts = [];

    // 시간이 있을 경우만 표시
    if (hours > 0) {
      parts.add(Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            hours.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C3311),
            ),
          ),
          Text(
            '시간',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF707070),
            ),
          ),
          SizedBox(width: 6.w),
        ],
      ));
    }

    // 분 표시
    parts.add(Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          minutes.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C3311),
          ),
        ),
        Text(
          '분',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF707070),
          ),
        ),
        SizedBox(width: 6.w),
      ],
    ));

    // 초 표시
    parts.add(Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          seconds.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C3311),
          ),
        ),
        Text(
          '초',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF707070),
          ),
        ),
      ],
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.timer_outlined, size: 46.w, color: Color(0xFFFF8B27)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '요리 타이머 설정',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3009)),
                    ),
                    GestureDetector(
                      onTap: _isCompleted ? null : _showTimePickerDialog,  // 완료 상태에서는 시간 설정 불가
                      child: _formatTimeWidget(_secondsRemaining),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // 완료 상태에서는 재생/일시정지 버튼 비활성화
                    _buildTimerButton(
                      onPressed: _isCompleted ? null : (_isRunning ? _pauseTimer : _startTimer),
                      icon: _isRunning ? Icons.pause : Icons.play_arrow,
                      color: _isCompleted ? Colors.grey : Color(0xFFFF8B27),
                    ),
                    SizedBox(width: 8.w),
                    _buildTimerButton(
                      onPressed: _stopTimer,  // 정지 버튼은 항상 활성화
                      icon: Icons.stop,
                      color: Color(0xFF6C3311),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildTimerButton({
    required VoidCallback? onPressed,  // null 허용으로 변경
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,  // null이면 버튼 자동 비활성화
      child: Icon(icon, size: 20.w, color: Colors.white),
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
    _flashingController.dispose();
    _audioPlayer.dispose(); // AudioPlayer 정리
    super.dispose();
  }
}

// 수정된 정규표현식: '시간', '분', '초' 단위를 모두 인식
RegExp timeRegex = RegExp(r'(\d+)\s*(시간|분|초)');

int? extractTime(String text) {
  final matches = timeRegex.allMatches(text);
  if (matches.isEmpty) return null;

  int totalSeconds = 0;

  for (final match in matches) {
    int value = int.parse(match.group(1)!);
    String unit = match.group(2)!;

    switch (unit) {
      case '시간':
        totalSeconds += value * 3600;
        break;
      case '분':
        totalSeconds += value * 60;
        break;
      case '초':
        totalSeconds += value;
        break;
    }
  }

  return totalSeconds;
}