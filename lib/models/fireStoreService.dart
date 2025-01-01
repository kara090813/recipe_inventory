import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_inventory/models/_models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 모든 레시피 가져오기
  Future<List<Recipe>> getRecipes() async {
    QuerySnapshot snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // 특정 레시피 가져오기
  Future<Recipe?> getRecipe(String id) async {
    DocumentSnapshot doc = await _firestore.collection('recipes').doc(id).get();
    if (doc.exists) {
      return Recipe.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 레시피 추가
  Future<void> addRecipe(Recipe recipe) async {
    await _firestore.collection('recipes').add(recipe.toJson());
  }

  // 레시피 업데이트
  Future<void> updateRecipe(String id, Recipe recipe) async {
    await _firestore.collection('recipes').doc(id).update(recipe.toJson());
  }

  // 레시피 삭제
  Future<void> deleteRecipe(String id) async {
    await _firestore.collection('recipes').doc(id).delete();
  }

  // 실시간 레시피 스트림
  Stream<List<Recipe>> recipesStream() {
    return _firestore.collection('recipes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }
}