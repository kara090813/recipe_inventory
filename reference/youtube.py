import argparse
import os
import json
import sys
from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound, NoTranscriptAvailable
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# YouTube Data API 설정
API_SERVICE_NAME = 'youtube'
API_VERSION = 'v3'
API_KEY = "AIzaSyCKVKYOokIJxyxsbMHlfmjheuuCBvemFtE"

# 파일 경로 설정
DEFAULT_VIDEO_IDS_FILE = 'video_ids.txt'
DEFAULT_OUTPUT_JSON_FILE = 'videos.json'

def get_youtube_service():
    return build(API_SERVICE_NAME, API_VERSION, developerKey=API_KEY)

def load_collected_video_ids(video_ids_file):
    if not os.path.exists(video_ids_file):
        print(f"{video_ids_file} 파일이 존재하지 않습니다. 새로 생성합니다.")
        return set()
    with open(video_ids_file, 'r', encoding='utf-8') as f:
        return set(line.strip() for line in f)

def save_collected_video_ids(video_ids, video_ids_file):
    with open(video_ids_file, 'a', encoding='utf-8') as f:
        for vid in video_ids:
            f.write(f"{vid}\n")

def save_videos_to_json(videos, output_json_file):
    if os.path.exists(output_json_file):
        with open(output_json_file, 'r', encoding='utf-8') as f:
            try:
                existing_data = json.load(f)
            except json.JSONDecodeError:
                print(f"{output_json_file} 파일이 손상되었습니다. 새로 생성합니다.")
                existing_data = []
    else:
        existing_data = []
    existing_data.extend(videos)
    with open(output_json_file, 'w', encoding='utf-8') as f:
        json.dump(existing_data, f, ensure_ascii=False, indent=4)
    print(f"{len(videos)}개의 비디오가 {output_json_file} 파일에 저장되었습니다.")

def get_videos_from_channel(youtube, channel_id, max_results):
    videos = []
    collected = 0
    try:
        print(f"채널 {channel_id}에서 비디오를 가져오는 중...")
        # 채널의 업로드된 플레이리스트 ID 가져오기
        response = youtube.channels().list(
            part='contentDetails',
            id=channel_id
        ).execute()
        uploads_playlist_id = response['items'][0]['contentDetails']['relatedPlaylists']['uploads']
        print(f"업로드된 플레이리스트 ID: {uploads_playlist_id}")

        # 업로드된 플레이리스트에서 비디오 가져오기
        next_page_token = None
        while collected < max_results:
            pl_response = youtube.playlistItems().list(
                part='snippet',
                playlistId=uploads_playlist_id,
                maxResults=min(50, max_results - collected),
                pageToken=next_page_token
            ).execute()

            for item in pl_response['items']:
                video_id = item['snippet']['resourceId']['videoId']
                videos.append(video_id)
                collected += 1
                if collected >= max_results:
                    break

            next_page_token = pl_response.get('nextPageToken')
            if not next_page_token:
                break
        print(f"채널에서 총 {len(videos)}개의 비디오를 가져왔습니다.")
    except HttpError as e:
        try:
            error_content = json.loads(e.content.decode('utf-8'))
            error_message = error_content.get('error', {}).get('message', 'Unknown error')
        except:
            error_message = 'Unknown error'
        print(f"An HTTP error {e.resp.status} occurred: {error_message}")
        sys.exit(1)
    return videos

def get_videos_from_playlist(youtube, playlist_id, max_results):
    videos = []
    collected = 0
    try:
        print(f"플레이리스트 {playlist_id}에서 비디오를 가져오는 중...")
        next_page_token = None
        while collected < max_results:
            pl_response = youtube.playlistItems().list(
                part='snippet',
                playlistId=playlist_id,
                maxResults=min(50, max_results - collected),
                pageToken=next_page_token
            ).execute()

            for item in pl_response['items']:
                video_id = item['snippet']['resourceId']['videoId']
                videos.append(video_id)
                collected += 1
                if collected >= max_results:
                    break

            next_page_token = pl_response.get('nextPageToken')
            if not next_page_token:
                break
        print(f"플레이리스트에서 총 {len(videos)}개의 비디오를 가져왔습니다.")
    except HttpError as e:
        try:
            error_content = json.loads(e.content.decode('utf-8'))
            error_message = error_content.get('error', {}).get('message', 'Unknown error')
        except:
            error_message = 'Unknown error'
        print(f"An HTTP error {e.resp.status} occurred: {error_message}")
        sys.exit(1)
    return videos

def get_videos_from_query(youtube, query, max_results):
    videos = []
    collected = 0
    try:
        print(f"검색어 '{query}'로 자막이 있는 비디오를 검색하는 중...")
        next_page_token = None
        while collected < max_results:
            search_response = youtube.search().list(
                q=query,
                part='id',
                type='video',
                videoCaption='closedCaption',  # 자막이 있는 영상만 검색
                maxResults=min(50, max_results - collected),
                pageToken=next_page_token
            ).execute()

            for item in search_response['items']:
                video_id = item['id']['videoId']
                videos.append(video_id)
                collected += 1
                if collected >= max_results:
                    break

            next_page_token = search_response.get('nextPageToken')
            if not next_page_token:
                break
        print(f"검색 결과에서 총 {len(videos)}개의 자막이 있는 비디오를 가져왔습니다.")
    except HttpError as e:
        try:
            error_content = json.loads(e.content.decode('utf-8'))
            error_message = error_content.get('error', {}).get('message', 'Unknown error')
        except:
            error_message = 'Unknown error'
        print(f"An HTTP error {e.resp.status} occurred: {error_message}")
        sys.exit(1)
    return videos

def check_captions(video_id, include_auto_captions=False):
    """
    비디오에 수동 생성된 한국어 자막이 있는지 확인하고, 해당 자막을 수집합니다.
    자동 생성 자막은 옵션에 따라 포함할지 결정합니다.
    만약 한국어 자막이 없으면, 수동 생성된 영어 자막을 수집합니다.
    """
    try:
        # 비디오의 자막 목록을 가져옵니다
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
        
        # 한국어 자막이 있는지 확인 (자동 생성 자막 포함 여부에 따라)
        try:
            if include_auto_captions:
                transcript = transcript_list.find_transcript(['ko'])
            else:
                transcript = transcript_list.find_manually_created_transcript(['ko'])
            print(f"비디오 {video_id}는 한국어 자막을 가지고 있습니다.")
            korean_subtitles = transcript.fetch()
            # 자막 텍스트를 하나의 문자열으로 합칩니다
            korean_text = ' '.join([entry['text'] for entry in korean_subtitles])
            return {'language': 'ko', 'subtitle': korean_text}
        except NoTranscriptFound:
            print(f"비디오 {video_id}는 한국어 자막이 없습니다.")
            # 한국어 자막이 없으면 영어 자막 확인
            try:
                transcript = transcript_list.find_manually_created_transcript(['en'])
                print(f"비디오 {video_id}는 영어 자막을 가지고 있습니다.")
                english_subtitles = transcript.fetch()
                # 자막 텍스트를 하나의 문자열로 합칩니다
                english_text = ' '.join([entry['text'] for entry in english_subtitles])
                return {'language': 'en', 'subtitle': english_text}
            except NoTranscriptFound:
                print(f"비디오 {video_id}는 영어 자막도 없습니다.")
                return None
            
    except TranscriptsDisabled:
        print(f"비디오 {video_id}는 자막이 비활성화되어 있습니다.")
        return None
    except NoTranscriptAvailable:
        print(f"비디오 {video_id}는 자막이 제공되지 않습니다.")
        return None
    except Exception as e:
        print(f"비디오 {video_id}의 자막을 가져오는 중 오류 발생: {e}")
        return None

def get_video_details(youtube, video_ids):
    videos = []
    try:
        print(f"비디오 상세 정보를 가져오는 중...")
        for i in range(0, len(video_ids), 50):
            batch_ids = video_ids[i:i+50]
            response = youtube.videos().list(
                part='snippet,contentDetails',
                id=','.join(batch_ids)
            ).execute()
            for item in response['items']:
                video_data = {
                    'video_id': item['id'],
                    'link': f"https://www.youtube.com/watch?v={item['id']}",
                    'title': item['snippet']['title'],
                    'description': item['snippet']['description'],
                    'thumbnail_url': item['snippet']['thumbnails']['high']['url'],
                    'caption_language': None,  # 초기값
                    'subtitle': None  # 자막 데이터 저장
                }
                videos.append(video_data)
        print(f"총 {len(videos)}개의 비디오 상세 정보를 가져왔습니다.")
    except HttpError as e:
        print(f"An HTTP error {e.resp.status} occurred: {e.content}")
    return videos

def main():
    parser = argparse.ArgumentParser(description='YouTube Video Data Collector')
    subparsers = parser.add_subparsers(dest='command', required=True, help='Commands')

    # 공통 인자 추가 (서브커맨드 전에 배치)
    parser.add_argument('--output', '-o', type=str, default=DEFAULT_OUTPUT_JSON_FILE,
                        help=f'수집된 데이터를 저장할 JSON 파일명 (기본값: {DEFAULT_OUTPUT_JSON_FILE})')
    parser.add_argument('--video_ids_file', '-v', type=str, default=DEFAULT_VIDEO_IDS_FILE,
                        help=f'이미 수집된 영상 ID를 저장할 파일명 (기본값: {DEFAULT_VIDEO_IDS_FILE})')
    parser.add_argument('--include_auto_captions', action='store_true',
                        help='자동 생성된 자막도 수집에 포함합니다.')

    # 채널 명령어
    parser_channel = subparsers.add_parser('channel', help='수집할 채널의 ID를 지정합니다.')
    parser_channel.add_argument('channel_id', help='채널 ID')
    parser_channel.add_argument('--max', type=int, default=50, help='수집할 최대 영상 수')

    # 플레이리스트 명령어
    parser_playlist = subparsers.add_parser('playlist', help='수집할 플레이리스트의 ID를 지정합니다.')
    parser_playlist.add_argument('playlist_id', help='플레이리스트 ID')
    parser_playlist.add_argument('--max', type=int, default=50, help='수집할 최대 영상 수')

    # 검색어 명령어
    parser_query = subparsers.add_parser('query', help='수집할 검색어를 지정합니다.')
    parser_query.add_argument('search_query', help='검색어 쿼리')
    parser_query.add_argument('--max', type=int, default=50, help='수집할 최대 영상 수')

    args = parser.parse_args()

    # YouTube Data API 서비스 객체 생성 (비디오 상세 정보 조회에 사용)
    youtube = get_youtube_service()
    
    # 이미 수집된 비디오 ID 로드
    collected_video_ids = load_collected_video_ids(args.video_ids_file)
    print(f"이미 수집된 비디오 수: {len(collected_video_ids)}")
    
    new_collected_ids = set()
    videos_to_save = []

    # 명령어에 따른 비디오 ID 수집
    if args.command == 'channel':
        video_ids = get_videos_from_channel(youtube, args.channel_id, args.max)
    elif args.command == 'playlist':
        video_ids = get_videos_from_playlist(youtube, args.playlist_id, args.max)
    elif args.command == 'query':
        video_ids = get_videos_from_query(youtube, args.search_query, args.max)
    else:
        print("잘못된 명령어입니다.")
        sys.exit(1)

    # 중복 및 자막 확인
    print("중복 및 자막 확인 중...")
    for vid in video_ids:
        if vid in collected_video_ids or vid in new_collected_ids:
            print(f"비디오 {vid}는 이미 수집되었거나 현재 수집 중입니다. 건너뜁니다.")
            continue
        caption_info = check_captions(vid, include_auto_captions=args.include_auto_captions)
        if caption_info:
            videos_to_save.append({
                'video_id': vid,
                'subtitle': caption_info['subtitle'],
                'caption_language': caption_info['language']  # 'ko' 또는 'en'
            })
            new_collected_ids.add(vid)
        else:
            print(f"비디오 {vid}는 수동 생성된 한국어 또는 영어 자막이 없어 건너뜁니다.")

    if not videos_to_save:
        print("수집할 새로운 영상이 없습니다.")
        sys.exit(0)

    # 비디오 상세 정보 가져오기
    video_ids_to_fetch = [item['video_id'] for item in videos_to_save]
    video_details = get_video_details(youtube, video_ids_to_fetch)

    # 자막 데이터 추가
    print("자막 데이터를 추가하는 중...")
    for video in video_details:
        vid = video['video_id']
        # 해당 비디오의 자막 데이터를 찾습니다
        subtitle_entry = next((item for item in videos_to_save if item['video_id'] == vid), None)
        if subtitle_entry:
            video['subtitle'] = subtitle_entry['subtitle']
            video['caption_language'] = subtitle_entry['caption_language']  # 'ko' 또는 'en'
            print(f"비디오 {vid}의 자막을 성공적으로 추가했습니다.")
        else:
            video['subtitle'] = None

    # JSON 파일에 저장
    save_videos_to_json(video_details, args.output)
    save_collected_video_ids(new_collected_ids, args.video_ids_file)
    print(f"새로 수집된 영상 수: {len(new_collected_ids)}")
    print(f"수집된 데이터를 '{args.output}' 파일에 저장했습니다.")

if __name__ == '__main__':
    main()
