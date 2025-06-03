import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recipe_inventory/status/_status.dart';

import '../models/_models.dart';

void addFoodFunc(List<Food> selectedFoods,BuildContext context){
  Provider.of<FoodStatus>(context,listen: false).addFoods(selectedFoods);
  Provider.of<SelectedFoodProvider>(context,listen: false).clearSelection();
  context.read<TabStatus>().setIndex(0);
  context.goNamed('home');
}

void resetFoodFunc(BuildContext context){
  Provider.of<SelectedFoodProvider>(context,listen: false).clearSelection();
}