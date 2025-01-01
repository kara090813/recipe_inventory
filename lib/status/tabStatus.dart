import 'package:flutter/foundation.dart';

class TabStatus extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      print('Index set to: $_selectedIndex');
      notifyListeners();
    }
  }
}