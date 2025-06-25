import 'dart:convert';
import 'dart:math' as math;
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyAp5N79ZheLw-_nhXP2w9HIahhqB66POoo";
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 64,
        maxOutputTokens: 8192,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>> convertSubtitlesToRecipe(String subtitleText, String? thumbnailUrl) async {
    print('🤖 Gemini AI - convertSubtitlesToRecipe 시작');
    print('📄 자막 텍스트 길이: ${subtitleText.length}');
    print('🔑 사용 중인 API 키: ${_apiKey.substring(0, 10)}...');
    print('🖼️ 썸네일 URL: $thumbnailUrl');
    
    final prompt = _createRecipePrompt(subtitleText, thumbnailUrl);
    print('📝 생성된 프롬프트 길이: ${prompt.length}');
    
    try {
      print('📡 Gemini API 호출 시작...');
      final response = await _model.generateContent([Content.text(prompt)]);
      
      print('📊 Gemini API 응답 받음');
      print('📄 응답 텍스트 존재: ${response.text != null}');
      
      if (response.text == null || response.text!.isEmpty) {
        print('❌ AI 응답이 비어있습니다');
        throw Exception('AI 응답이 비어있습니다');
      }

      print('📄 응답 텍스트 길이: ${response.text!.length}');
      print('📄 응답 텍스트 샘플: ${response.text!.substring(0, math.min(300, response.text!.length))}...');

      final recipeData = _parseJsonResponse(response.text!);
      print('✅ JSON 파싱 성공');
      
      final validatedData = _validateAndFormatRecipeData(recipeData);
      print('✅ 데이터 검증 완료');
      print('📊 최종 레시피 제목: ${validatedData['title']}');
      print('📊 재료 개수: ${validatedData['ingredients_cnt']}');
      print('📊 조리 단계 개수: ${(validatedData['recipe_method'] as List).length}');
      
      return validatedData;
      
    } catch (e) {
      print('❌ Gemini AI 변환 오류: $e');
      throw Exception('레시피 변환 중 오류 발생: $e');
    }
  }

  String _createRecipePrompt(String subtitleText, String? thumbnailUrl) {
    return """
Role: 당신은 요리 영상 자막을 분석하여 레시피를 추출하는 전문가입니다.

Context:
- 목표: 제공된 유튜브 영상 자막을 분석하여 정확한 레시피 정보를 JSON 형식으로 추출합니다.
- 대상 사용자: 요리를 배우고 싶어하는 사람들

Instructions:
1. 자막 텍스트에서 요리 관련 정보만을 추출하세요.
2. 요리와 관련없는 내용(인사말, 광고, 잡담 등)은 제외하세요.
3. 재료는 정확한 양과 함께 추출하세요. 양이 명시되지 않은 경우 "적당량"으로 표시하세요.
4. 조리 과정은 순서대로 정리하여 각 단계를 명확히 구분하세요.
5. 요리 난이도는 조리 과정의 복잡성을 고려하여 판단하세요.
6. 요리 종류는 한식, 일식, 양식, 중식, 아시안, 기타 중에서 선택하세요.

Output Format (JSON):
{
  "title": "요리 이름",
  "sub_title": "레시피 간단 설명 (한 줄)",
  "thumbnail": "${thumbnailUrl ?? ''}",
  "recipe_type": "요리 종류 (한식/일식/양식/중식/아시안/기타)",
  "difficulty": "요리 난이도 (매우 쉬움/쉬움/보통/어려움/매우 어려움)",
  "ingredients_cnt": 재료 종류 개수,
  "ingredients": [
    {"food": "재료명", "cnt": "분량"}
  ],
  "recipe_method": [
    "조리 과정 1단계",
    "조리 과정 2단계"
  ],
  "recipe_tags": ["태그1", "태그2", "태그3"]
}

자막 텍스트:
$subtitleText

위의 자막을 분석하여 레시피 정보를 JSON 형식으로 추출해주세요. 반드시 유효한 JSON 형식으로 응답해야 합니다.
""";
  }

  Map<String, dynamic> _parseJsonResponse(String responseText) {
    try {
      // JSON 마커 제거 (```json, ``` 등)
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      return json.decode(cleanedResponse.trim());
    } catch (e) {
      // JSON 파싱 실패 시 다시 정제 시도
      return _attemptJsonRecovery(responseText);
    }
  }

  Map<String, dynamic> _attemptJsonRecovery(String responseText) {
    try {
      // 줄바꿈 문자를 적절히 이스케이프 처리
      String processed = responseText
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r')
          .replaceAll('\t', '\\t');
      
      return json.decode(processed);
    } catch (e) {
      throw Exception('JSON 파싱 실패: $e');
    }
  }

  Map<String, dynamic> _validateAndFormatRecipeData(Map<String, dynamic> data) {
    // 필수 필드 검증 및 기본값 설정
    final validatedData = <String, dynamic>{
      'title': _validateString(data['title'], '제목 없음'),
      'sub_title': _validateString(data['sub_title'], '설명 없음'),
      'thumbnail': _validateString(data['thumbnail'], ''),
      'recipe_type': _validateRecipeType(data['recipe_type']),
      'difficulty': _validateDifficulty(data['difficulty']),
      'ingredients_cnt': _validateIngredientCount(data['ingredients'], data['ingredients_cnt']),
      'ingredients': _validateIngredients(data['ingredients']),
      'recipe_method': _validateRecipeMethod(data['recipe_method']),
      'recipe_tags': _validateTags(data['recipe_tags']),
    };

    return validatedData;
  }

  String _validateString(dynamic value, String defaultValue) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return defaultValue;
  }

  String _validateRecipeType(dynamic value) {
    const validTypes = ['한식', '일식', '양식', '중식', '아시안', '기타'];
    if (value is String && validTypes.contains(value)) {
      return value;
    }
    return '기타';
  }

  String _validateDifficulty(dynamic value) {
    const validDifficulties = ['매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'];
    if (value is String && validDifficulties.contains(value)) {
      return value;
    }
    return '보통';
  }

  int _validateIngredientCount(dynamic ingredients, dynamic count) {
    if (ingredients is List) {
      return ingredients.length;
    }
    if (count is int && count > 0) {
      return count;
    }
    return 0;
  }

  List<Map<String, String>> _validateIngredients(dynamic value) {
    if (value is! List) return [];
    
    final validatedIngredients = <Map<String, String>>[];
    for (final item in value) {
      if (item is Map) {
        final food = _validateString(item['food'], '');
        final cnt = _validateString(item['cnt'], '적당량');
        
        if (food.isNotEmpty) {
          validatedIngredients.add({
            'food': food,
            'cnt': cnt,
          });
        }
      }
    }
    
    return validatedIngredients;
  }

  List<String> _validateRecipeMethod(dynamic value) {
    if (value is! List) return [];
    
    final validatedSteps = <String>[];
    for (final step in value) {
      if (step is String && step.trim().isNotEmpty) {
        validatedSteps.add(step.trim());
      }
    }
    
    return validatedSteps;
  }

  List<String> _validateTags(dynamic value) {
    if (value is! List) return [];
    
    final validatedTags = <String>[];
    for (final tag in value) {
      if (tag is String && tag.trim().isNotEmpty) {
        validatedTags.add(tag.trim());
      }
    }
    
    // 태그 개수 제한 (최대 5개)
    return validatedTags.take(5).toList();
  }
}