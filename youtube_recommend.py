import openai
import os
import google.auth
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError


# Prompt the user for their occupation, aspiration, and values

aspiration = input("What do you aspire to become? ")


# Set up the YouTube Data API client
api_service_name = "youtube"
api_version = "v3"
DEVELOPER_KEY = os.environ.get('YOUTUBE_API_KEY') # Replace with your own API key
youtube = build(api_service_name, api_version, developerKey=DEVELOPER_KEY)

# Search for videos related to the user's input
query = f"{aspiration} tutorial"
search_response = youtube.search().list(
    q=query,
    type="video",
    part="id,snippet",
    maxResults=10
).execute()

# Extract the video information and feed it into the ChatGPT language model
openai.api_key = os.environ.get('OPENAI_API_KEY') # Replace with your own API key

recommended_videos = []
for search_result in search_response.get("items", []):
    video_id = search_result["id"]["videoId"]
    video_title = search_result["snippet"]["title"]
    video_description = search_result["snippet"]["description"]
    video_tags = search_result["snippet"]["tags"] if "tags" in search_result["snippet"] else []

    # Generate a relevance score for the video based on the ChatGPT language model
    completion = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": f"User journal: [user's journal here]. Recommend quality YouTube videos related to [occupation/aspiration/values]. Video details: [video_title], [video_description], [video_tags] "}
        ]
        )
    relevance_score = completion.choices[0].text.strip()
    # Add the video and its relevance score to the recommended videos list
    recommended_videos.append((video_title, video_id, relevance_score))

# Sort the recommended videos based on relevance and return the top three videos
recommended_videos = sorted(recommended_videos, key=lambda x: x[2], reverse=True)[:3]

print("Recommended videos:")
for video_title, video_id, relevance_score in recommended_videos:
    print(f"{video_title}: https://www.youtube.com/watch?v={video_id}")
