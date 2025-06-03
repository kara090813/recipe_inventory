import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScaffoldPaddingWidget extends StatelessWidget {
  final Widget child;
  const ScaffoldPaddingWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: EdgeInsets.fromLTRB(20, 50, 20, 0),child:child ,);
    return Padding(padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 0),child:child ,);
  }
}
