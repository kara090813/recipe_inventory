import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_model.freezed.dart';
part 'ingredient_model.g.dart';

@freezed
class DisplayIngredient with _$DisplayIngredient {
  factory DisplayIngredient({
    required String food,
    required String cnt,
    required String img,
    required String type,
  }) = _DisplayIngredient;

  factory DisplayIngredient.fromJson(Map<String, dynamic> json) =>
      _$DisplayIngredientFromJson(json);
}
