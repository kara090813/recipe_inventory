import 'foodJson.dart';
import 'freezed/_freezed.dart';

const List<String> FOOD_CATEGORY = ['전체','채소','과일','육류','수산물','조미료/향신료','가공/유제품','기타'];
final List<Food> FOOD_LIST = FOOD_JSON.map((e) => Food.fromJson(e)).toList();
