# [A] 불필요한 언어(중국어, 일본어, 데바나가리어) 관련 패키지 경고 무시
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# [B] 나머지 ML Kit 텍스트 인식 코드에서 발생하는 경고 전부 무시할 경우
# (선택적으로)
-dontwarn com.google.mlkit.vision.text.**

# [C] 이미 Missing class가 "오류"로 처리될 때,
#  경고 수준으로 바꾸기 위해(강제로 빌드 통과) -ignorewarnings
-ignorewarnings