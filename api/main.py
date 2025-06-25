from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound, NoTranscriptAvailable
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import re
import uvicorn
import time
import random
from typing import Optional, Dict, List
import asyncio
import json

app = FastAPI(title="YouTube Subtitle API", version="2.0.0")

# YouTube Data API 설정
API_SERVICE_NAME = 'youtube'
API_VERSION = 'v3'
API_KEY = "AIzaSyCKVKYOokIJxyxsbMHlfmjheuuCBvemFtE"

# CORS 미들웨어 추가 (Flutter 앱에서 접근할 수 있도록)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SubtitleRequest(BaseModel):
    video_url: str
    include_auto_captions: bool = True

class SubtitleResponse(BaseModel):
    success: bool
    subtitle_text: Optional[str] = None
    language: Optional[str] = None
    video_id: Optional[str] = None
    error: Optional[str] = None

class VideoInfoRequest(BaseModel):
    video_url: str

class VideoInfoResponse(BaseModel):
    success: bool
    video_id: Optional[str] = None
    title: Optional[str] = None
    description: Optional[str] = None
    thumbnail_url: Optional[str] = None
    error: Optional[str] = None

def extract_video_id(url: str) -> Optional[str]:
    """YouTube URL에서 비디오 ID 추출"""
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([a-zA-Z0-9_-]{11})',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    
    return None

def get_youtube_service():
    """YouTube API 서비스 객체 생성"""
    try:
        return build(API_SERVICE_NAME, API_VERSION, developerKey=API_KEY)
    except Exception as e:
        print(f"Error creating YouTube service: {e}")
        return None

def clean_subtitle_text(subtitle_text: str) -> str:
    """자막 텍스트 정리"""
    # 중복된 공백 제거
    subtitle_text = re.sub(r'\s+', ' ', subtitle_text)
    # 앞뒤 공백 제거
    subtitle_text = subtitle_text.strip()
    return subtitle_text

def get_video_info(video_id: str) -> dict:
    """YouTube Data API를 사용하여 비디오 정보 가져오기"""
    youtube = get_youtube_service()
    if not youtube:
        return {
            'success': False,
            'error': 'Failed to create YouTube service'
        }
    
    try:
        response = youtube.videos().list(
            part='snippet,contentDetails',
            id=video_id
        ).execute()
        
        if not response['items']:
            return {
                'success': False,
                'error': f'Video {video_id} not found'
            }
        
        item = response['items'][0]
        return {
            'success': True,
            'video_id': item['id'],
            'title': item['snippet']['title'],
            'description': item['snippet']['description'],
            'thumbnail_url': item['snippet']['thumbnails']['high']['url']
        }
        
    except HttpError as e:
        try:
            error_content = json.loads(e.content.decode('utf-8'))
            error_message = error_content.get('error', {}).get('message', 'Unknown error')
        except:
            error_message = str(e)
        return {
            'success': False,
            'error': f'YouTube API error: {error_message}'
        }
    except Exception as e:
        return {
            'success': False,
            'error': f'Error fetching video info: {str(e)}'
        }

def check_captions(video_id: str, include_auto_captions: bool = True) -> dict:
    """
    비디오의 자막을 확인하고 가져오기 (reference/youtube.py 방식)
    우선순위: 수동 생성 한국어 > 수동 생성 영어 > 자동 생성 한국어 > 자동 생성 영어
    """
    try:
        # 비디오의 자막 목록을 가져옵니다
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
        
        # 한국어 자막 확인 (수동 생성)
        try:
            transcript = transcript_list.find_manually_created_transcript(['ko'])
            print(f"Video {video_id} has manual Korean subtitles")
            korean_subtitles = transcript.fetch()
            korean_text = ' '.join([entry['text'] for entry in korean_subtitles])
            return {
                'success': True,
                'language': 'ko',
                'subtitle_text': clean_subtitle_text(korean_text),
                'is_auto_generated': False,
                'video_id': video_id
            }
        except NoTranscriptFound:
            pass
        
        # 영어 자막 확인 (수동 생성)
        try:
            transcript = transcript_list.find_manually_created_transcript(['en'])
            print(f"Video {video_id} has manual English subtitles")
            english_subtitles = transcript.fetch()
            english_text = ' '.join([entry['text'] for entry in english_subtitles])
            return {
                'success': True,
                'language': 'en',
                'subtitle_text': clean_subtitle_text(english_text),
                'is_auto_generated': False,
                'video_id': video_id
            }
        except NoTranscriptFound:
            pass
        
        # 자동 생성 자막 확인 (옵션이 활성화된 경우)
        if include_auto_captions:
            # 한국어 자동 생성 자막
            try:
                transcript = transcript_list.find_generated_transcript(['ko'])
                print(f"Video {video_id} has auto-generated Korean subtitles")
                korean_subtitles = transcript.fetch()
                korean_text = ' '.join([entry['text'] for entry in korean_subtitles])
                return {
                    'success': True,
                    'language': 'ko',
                    'subtitle_text': clean_subtitle_text(korean_text),
                    'is_auto_generated': True,
                    'video_id': video_id
                }
            except NoTranscriptFound:
                pass
            
            # 영어 자동 생성 자막
            try:
                transcript = transcript_list.find_generated_transcript(['en'])
                print(f"Video {video_id} has auto-generated English subtitles")
                english_subtitles = transcript.fetch()
                english_text = ' '.join([entry['text'] for entry in english_subtitles])
                return {
                    'success': True,
                    'language': 'en',
                    'subtitle_text': clean_subtitle_text(english_text),
                    'is_auto_generated': True,
                    'video_id': video_id
                }
            except NoTranscriptFound:
                pass
        
        return {
            'success': False,
            'error': f'No suitable subtitles found for video {video_id}',
            'video_id': video_id
        }
            
    except TranscriptsDisabled:
        return {
            'success': False,
            'error': f'Subtitles are disabled for video {video_id}',
            'video_id': video_id
        }
    except NoTranscriptAvailable:
        return {
            'success': False,
            'error': f'No subtitles available for video {video_id}',
            'video_id': video_id
        }
    except Exception as e:
        print(f"Error fetching subtitles for video {video_id}: {e}")
        return {
            'success': False,
            'error': f'Error fetching subtitles: {str(e)}',
            'video_id': video_id
        }

# 대안 방법은 더 이상 필요하지 않음 (YouTube Data API 사용)

def get_subtitles(video_id: str, include_auto_captions: bool = True) -> dict:
    """자막 가져오기 래퍼 함수"""
    return check_captions(video_id, include_auto_captions)

@app.get("/")
async def root():
    return {
        "message": "YouTube Subtitle API",
        "version": "2.0.0",
        "endpoints": {
            "GET /": "API 정보",
            "POST /get-subtitles": "YouTube 자막 가져오기",
            "POST /get-video-info": "YouTube 비디오 정보 가져오기",
            "GET /health": "헬스 체크"
        }
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "API is running"}

@app.post("/get-subtitles", response_model=SubtitleResponse)
async def get_youtube_subtitles(request: SubtitleRequest):
    """
    YouTube 비디오 URL에서 자막을 가져옵니다.
    
    요청 본문:
    - video_url: YouTube 비디오 URL
    - include_auto_captions: 자동 생성 자막 포함 여부 (기본: True)
    
    응답:
    - success: 성공 여부
    - subtitle_text: 자막 텍스트 (성공 시)
    - language: 자막 언어 (성공 시)
    - video_id: 추출된 비디오 ID
    - error: 오류 메시지 (실패 시)
    """
    
    # URL에서 비디오 ID 추출
    video_id = extract_video_id(request.video_url)
    if not video_id:
        raise HTTPException(
            status_code=400,
            detail="Invalid YouTube URL. Please provide a valid YouTube video URL."
        )
    
    # 자막 가져오기
    result = get_subtitles(video_id, request.include_auto_captions)
    
    if result['success']:
        return SubtitleResponse(
            success=True,
            subtitle_text=result['subtitle_text'],
            language=result['language'],
            video_id=video_id
        )
    else:
        return SubtitleResponse(
            success=False,
            video_id=video_id,
            error=result['error']
        )

@app.post("/get-video-info", response_model=VideoInfoResponse)
async def get_youtube_video_info(request: VideoInfoRequest):
    """
    YouTube 비디오 URL에서 비디오 정보를 가져옵니다.
    
    요청 본문:
    - video_url: YouTube 비디오 URL
    
    응답:
    - success: 성공 여부
    - video_id: 비디오 ID
    - title: 비디오 제목
    - description: 비디오 설명
    - thumbnail_url: 썸네일 URL
    - error: 오류 메시지 (실패 시)
    """
    
    # URL에서 비디오 ID 추출
    video_id = extract_video_id(request.video_url)
    if not video_id:
        raise HTTPException(
            status_code=400,
            detail="Invalid YouTube URL. Please provide a valid YouTube video URL."
        )
    
    # 비디오 정보 가져오기
    result = get_video_info(video_id)
    
    if result['success']:
        return VideoInfoResponse(
            success=True,
            video_id=video_id,
            title=result['title'],
            description=result['description'],
            thumbnail_url=result['thumbnail_url']
        )
    else:
        return VideoInfoResponse(
            success=False,
            video_id=video_id,
            error=result['error']
        )

@app.get("/get-subtitles/{video_id}")
async def get_subtitles_by_id(video_id: str, include_auto_captions: bool = True):
    """
    비디오 ID로 직접 자막을 가져옵니다.
    
    경로 매개변수:
    - video_id: YouTube 비디오 ID
    
    쿼리 매개변수:
    - include_auto_captions: 자동 생성 자막 포함 여부 (기본: True)
    """
    
    result = get_subtitles(video_id, include_auto_captions)
    
    if result['success']:
        return SubtitleResponse(
            success=True,
            subtitle_text=result['subtitle_text'],
            language=result['language'],
            video_id=video_id
        )
    else:
        return SubtitleResponse(
            success=False,
            video_id=video_id,
            error=result['error']
        )

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)