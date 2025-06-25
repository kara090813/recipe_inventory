#!/usr/bin/env python3
"""
YouTube Subtitle API 테스트 스크립트
"""

import requests
import json

# API 베이스 URL (로컬 테스트용)
# 배포된 API를 테스트하려면 아래 URL을 배포된 주소로 변경하세요
# 예: BASE_URL = "https://your-app-name.onrender.com"
BASE_URL = "http://localhost:8000"

def test_health():
    """헬스 체크 테스트"""
    print("=== 헬스 체크 테스트 ===")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"상태 코드: {response.status_code}")
        print(f"응답: {response.json()}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

def test_root():
    """루트 엔드포인트 테스트"""
    print("=== 루트 엔드포인트 테스트 ===")
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"상태 코드: {response.status_code}")
        print(f"응답: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

def test_get_video_info():
    """비디오 정보 가져오기 테스트"""
    print("=== 비디오 정보 가져오기 테스트 ===")
    
    # 테스트할 YouTube URL
    test_url = "https://www.youtube.com/watch?v=mhRrbnf5Cig"
    
    try:
        response = requests.post(
            f"{BASE_URL}/get-video-info",
            json={
                "video_url": test_url
            }
        )
        print(f"상태 코드: {response.status_code}")
        data = response.json()
        
        if data["success"]:
            print(f"성공!")
            print(f"비디오 ID: {data['video_id']}")
            print(f"제목: {data['title']}")
            print(f"설명: {data['description'][:100]}..." if data['description'] else "설명: 없음")
            print(f"썸네일 URL: {data['thumbnail_url']}")
        else:
            print(f"실패: {data['error']}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

def test_get_subtitles_post():
    """POST 방식으로 자막 가져오기 테스트"""
    print("=== POST 자막 가져오기 테스트 ===")
    
    # 테스트할 YouTube URL
    test_url = "https://www.youtube.com/watch?v=mhRrbnf5Cig"
    
    try:
        response = requests.post(
            f"{BASE_URL}/get-subtitles",
            json={
                "video_url": test_url,
                "include_auto_captions": True
            }
        )
        print(f"상태 코드: {response.status_code}")
        data = response.json()
        
        if data["success"]:
            print(f"성공!")
            print(f"비디오 ID: {data['video_id']}")
            print(f"언어: {data['language']}")
            print(f"자막 길이: {len(data['subtitle_text'])} 문자")
            print(f"자막 미리보기: {data['subtitle_text'][:200]}...")
        else:
            print(f"실패: {data['error']}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

def test_get_subtitles_get():
    """GET 방식으로 자막 가져오기 테스트"""
    print("=== GET 자막 가져오기 테스트 ===")
    
    # 테스트할 비디오 ID
    video_id = "mhRrbnf5Cig"
    
    try:
        response = requests.get(
            f"{BASE_URL}/get-subtitles/{video_id}?include_auto_captions=true"
        )
        print(f"상태 코드: {response.status_code}")
        data = response.json()
        
        if data["success"]:
            print(f"성공!")
            print(f"비디오 ID: {data['video_id']}")
            print(f"언어: {data['language']}")
            print(f"자막 길이: {len(data['subtitle_text'])} 문자")
            print(f"자막 미리보기: {data['subtitle_text'][:200]}...")
        else:
            print(f"실패: {data['error']}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

def test_invalid_url():
    """잘못된 URL 테스트"""
    print("=== 잘못된 URL 테스트 ===")
    
    try:
        response = requests.post(
            f"{BASE_URL}/get-subtitles",
            json={
                "video_url": "https://invalid-url.com",
                "include_auto_captions": True
            }
        )
        print(f"상태 코드: {response.status_code}")
        data = response.json()
        print(f"응답: {data}")
        print()
    except Exception as e:
        print(f"오류: {e}")
        print()

if __name__ == "__main__":
    print("YouTube Subtitle API 테스트 시작\n")
    
    # 서버가 실행 중인지 확인
    try:
        requests.get(f"{BASE_URL}/health", timeout=5)
        print("✅ API 서버가 실행 중입니다.\n")
    except:
        print("❌ API 서버가 실행되지 않았습니다.")
        print("다음 명령으로 서버를 실행하세요:")
        print("python main.py")
        print("또는")
        print("uvicorn main:app --host 0.0.0.0 --port 8000 --reload")
        exit(1)
    
    # 테스트 실행
    test_root()
    test_health()
    test_get_video_info()
    test_get_subtitles_post()
    test_get_subtitles_get()
    test_invalid_url()
    
    print("테스트 완료!")