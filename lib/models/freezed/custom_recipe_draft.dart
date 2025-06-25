import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'recipe_model.dart';

part 'custom_recipe_draft.freezed.dart';
part 'custom_recipe_draft.g.dart';

@freezed
@HiveType(typeId: 17)
class CustomRecipeDraft with _$CustomRecipeDraft {
  factory CustomRecipeDraft({
    @HiveField(0) @Default("") String title,
    @HiveField(1) @Default("") String subTitle,
    @HiveField(2) @Default("한식") String foodType,
    @HiveField(3) @Default("매우 쉬움") String difficulty,
    @HiveField(4) @Default([]) List<Ingredient> ingredients,
    @HiveField(5) @Default([]) List<String> cookingSteps,
    @HiveField(6) @Default("") String thumbnailPath,
    @HiveField(7) @Default([]) List<String> tags,
    @HiveField(8) @Default("") String youtubeUrl,
    @HiveField(9) @Default("") String lastSavedAt,
  }) = _CustomRecipeDraft;

  factory CustomRecipeDraft.fromJson(Map<String, dynamic> json) => _$CustomRecipeDraftFromJson(json);
}