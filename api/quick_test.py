#!/usr/bin/env python3
"""
Quick test for the YouTube API endpoints
"""

import requests
import json

# API base URL
BASE_URL = "http://localhost:8000"

def test_video_info():
    """Test video info endpoint"""
    print("=== Testing video info endpoint ===")
    
    test_url = "https://www.youtube.com/watch?v=mhRrbnf5Cig"
    
    try:
        response = requests.post(
            f"{BASE_URL}/get-video-info",
            json={"video_url": test_url}
        )
        
        print(f"Status: {response.status_code}")
        data = response.json()
        
        if data["success"]:
            print(f"✅ Success!")
            print(f"Video ID: {data['video_id']}")
            print(f"Title: {data['title']}")
            print(f"Thumbnail: {data['thumbnail_url']}")
        else:
            print(f"❌ Failed: {data['error']}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def test_subtitles():
    """Test subtitles endpoint"""
    print("\n=== Testing subtitles endpoint ===")
    
    test_url = "https://www.youtube.com/watch?v=mhRrbnf5Cig"
    
    try:
        response = requests.post(
            f"{BASE_URL}/get-subtitles",
            json={
                "video_url": test_url,
                "include_auto_captions": True
            }
        )
        
        print(f"Status: {response.status_code}")
        data = response.json()
        
        if data["success"]:
            print(f"✅ Success!")
            print(f"Language: {data['language']}")
            print(f"Text length: {len(data['subtitle_text'])}")
            print(f"Sample: {data['subtitle_text'][:200]}...")
        else:
            print(f"❌ Failed: {data['error']}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_video_info()
    test_subtitles()