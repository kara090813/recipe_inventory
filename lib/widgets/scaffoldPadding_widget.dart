import 'package:flutter/material.dart';

class ScaffoldPaddingWidget extends StatelessWidget {
  final Widget child;
  const ScaffoldPaddingWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: EdgeInsets.fromLTRB(20, 50, 20, 0),child:child ,);
    return Padding(padding: EdgeInsets.fromLTRB(20, 50, 20, 0),child:child ,);
  }
}
