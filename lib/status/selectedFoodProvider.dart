import 'package:flutter/foundation.dart';
import '../models/_models.dart';

class SelectedFoodProvider extends ChangeNotifier {
  final List<Food> _selectedFoods = [];

  List<Food> get selectedFoods => _selectedFoods;

  void toggleFood(Food food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  void updateSelectedFoods(List<Food> newSelectedFoods){
    _selectedFoods.clear();
    _selectedFoods.addAll(newSelectedFoods);
    notifyListeners();
  }

  void clearSelection() {
    _selectedFoods.clear();
    notifyListeners();
  }

  bool isSelected(Food food) => _selectedFoods.contains(food);
}