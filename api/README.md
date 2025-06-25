# YouTube Subtitle API

YouTube 비디오에서 자막을 추출하는 FastAPI 기반 REST API입니다.

## 기능

- YouTube 비디오 URL에서 자막 추출
- YouTube 비디오 정보 가져오기 (제목, 설명, 썸네일)
- 한국어/영어 자막 우선순위 지원
- 수동 생성 자막 우선, 자동 생성 자막 지원
- CORS 설정으로 웹 앱에서 직접 호출 가능
- YouTube Data API v3 사용

## API 엔드포인트

### 1. 기본 정보
```
GET /
```

### 2. 헬스 체크
```
GET /health
```

### 3. 자막 가져오기 (POST)
```
POST /get-subtitles
Content-Type: application/json

{
  "video_url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "include_auto_captions": true
}
```

### 4. 비디오 정보 가져오기
```
POST /get-video-info
Content-Type: application/json

{
  "video_url": "https://www.youtube.com/watch?v=VIDEO_ID"
}
```

### 5. 자막 가져오기 (GET)
```
GET /get-subtitles/{video_id}?include_auto_captions=true
```

## 응답 형식

### 성공 시
```json
{
  "success": true,
  "subtitle_text": "추출된 자막 텍스트...",
  "language": "ko",
  "video_id": "VIDEO_ID",
  "error": null
}
```

### 실패 시
```json
{
  "success": false,
  "subtitle_text": null,
  "language": null,
  "video_id": "VIDEO_ID",
  "error": "오류 메시지"
}
```

### 비디오 정보 응답 형식
```json
{
  "success": true,
  "video_id": "VIDEO_ID",
  "title": "비디오 제목",
  "description": "비디오 설명",
  "thumbnail_url": "https://i.ytimg.com/...",
  "error": null
}
```

## 로컬 실행

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. 서버 실행
```bash
python main.py
```

또는

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

서버가 실행되면 http://localhost:8000 에서 접근할 수 있습니다.

## Render 배포

### 방법 1: GitHub 연동 (권장)
1. GitHub에 코드 푸시
2. [Render](https://render.com)에 로그인
3. "New Web Service" 선택
4. GitHub 저장소 연결
5. 다음 설정 사용:
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### 방법 2: render.yaml 사용
1. `render.yaml` 파일이 루트에 있는지 확인
2. Render 대시보드에서 "Blueprint" 방식으로 배포

### 환경 변수 (선택사항)
- `PYTHON_VERSION`: `3.11.0`

## Docker 실행

```bash
docker build -t youtube-subtitle-api .
docker run -p 8000:8000 youtube-subtitle-api
```

## 자막 우선순위

1. 수동 생성 한국어 자막
2. 수동 생성 영어 자막  
3. 자동 생성 한국어 자막 (include_auto_captions=true인 경우)
4. 자동 생성 영어 자막 (include_auto_captions=true인 경우)

## 사용 예시

### cURL
```bash
curl -X POST "http://localhost:8000/get-subtitles" \
     -H "Content-Type: application/json" \
     -d '{
       "video_url": "https://www.youtube.com/watch?v=mhRrbnf5Cig",
       "include_auto_captions": true
     }'
```

### Python
```python
import requests

response = requests.post(
    "http://localhost:8000/get-subtitles",
    json={
        "video_url": "https://www.youtube.com/watch?v=mhRrbnf5Cig",
        "include_auto_captions": True
    }
)

data = response.json()
if data["success"]:
    print(f"자막 언어: {data['language']}")
    print(f"자막 내용: {data['subtitle_text'][:200]}...")
else:
    print(f"오류: {data['error']}")

# 비디오 정보 가져오기
info_response = requests.post(
    "http://localhost:8000/get-video-info",
    json={
        "video_url": "https://www.youtube.com/watch?v=mhRrbnf5Cig"
    }
)

info_data = info_response.json()
if info_data["success"]:
    print(f"제목: {info_data['title']}")
    print(f"썸네일: {info_data['thumbnail_url']}")
```