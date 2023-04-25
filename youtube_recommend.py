import openai
import os
import google.auth
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import re

# Prompt the user for their occupation, aspiration, and values

aspiration = input("+ What do you target? ")
journal = "i was born in India in 2005 to a great mom and dad who took me care from the kid i got interest in electronics and robotics i grew up in victim mentality and i was a huge procrastinator i don't do well in school but everything changed when the covid and lockdown came i got access to the computer and i learnt to code and watched motivational video self help videos and got myself exercising and i gone into twitter to just be admired at this guy called elon musk who landed a rocket and make autopilot electric cars. I started building some great products and everything was going fine until the youtube and google which i used turned against me i mean i used it wrong i watched porn masturbated and got addicted to youtube, i got hydroxyphobia i feared about rabies and blood cancer"

# Set up the YouTube Data API client
api_service_name = "youtube"
api_version = "v3"
DEVELOPER_KEY = os.environ.get('YOUTUBE_API_KEY') # Replace with your own API key
youtube = build(api_service_name, api_version, developerKey=DEVELOPER_KEY)

# Search for videos related to the user's input
query = f"{aspiration}"
search_response = youtube.search().list(
    q=query,
    type="video",
    part="id,snippet",
    maxResults=10
).execute()

# Extract the video information and feed it into the ChatGPT language model
openai.api_key = os.environ.get('OPENAI_API_KEY') # Replace with your own API key

videos = []
for search_result in search_response.get("items", []):
    video_id = search_result["id"]["videoId"]
    video_title = search_result["snippet"]["title"]
    video_description = search_result["snippet"]["description"]
    video_tags = search_result["snippet"]["tags"] if "tags" in search_result["snippet"] else []
    videos.append((video_title,video_id))
print(videos)
completion = openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
    {"role": "user", "content":f"{journal} Provide a very short summary of the user's personal story, highlighting their interest in areas of good so it can be used to feed an youtube recommender system."}
  ],
  temperature=0
)
completion = openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
    {"role": "user","content":f"User journal: {completion.choices[0].message['content']}. Now i need you to help the user by selecting three youtube videos in the interest of {aspiration} from this list  {[x[0] for x in videos]}"}

     ],
     temperature=0
)
print(completion.choices[0].message['content'])

# Extract video titles using regular expression
video_titles = re.findall(r'\d+\. (.+)', completion.choices[0].message['content'])
print(video_titles)
# video_ids = [video[2] for video in videos if video[0] in video_titles]
# print(video_ids)
# result = [video_tuple[2] for video_tuple in videos if any(title.strip("'") in video_tuple[0] for title in video_titles)]

# print(result)

result_list = []

for title in video_titles:
    for video in videos:
      #second.append(video[0].strip("'"))
      if title.strip("'") == video[0].strip("'"):
          
        result_list.append((title, video[1]))

print(result_list)
print("Recommended videos:")
for i in result_list:
  print(f"{i[0]}: https://www.youtube.com/watch?v={i[1]}")
