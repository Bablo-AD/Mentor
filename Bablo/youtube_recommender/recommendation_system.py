import openai
import os
import google.auth
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import re

class Tools:
  def journal2short_journal(journal):
    completion = openai.ChatCompletion.create(
      model="gpt-3.5-turbo",
      messages=[
        {"role": "user", "content":f"{journal} Provide a very short summary of the user's personal story, highlighting their interest in areas of good so it can be used to feed an youtube recommender system."}
      ],
      temperature=0
    )
    return completion.choices[0].message['content']

class youtube_recommender:
  def __init__(self):
    # Set up the YouTube Data API client
    openai.api_key = os.environ.get('OPENAI_API_KEY')
    api_service_name = "youtube"
    api_version = "v3"
    DEVELOPER_KEY = os.environ.get('YOUTUBE_API_KEY') # Replace with your own API key
    self.youtube = build(api_service_name, api_version, developerKey=DEVELOPER_KEY)

  def set_value(self,journal,aspiration):
    self.journal = journal
    self.aspiration = aspiration

  # Condenses the journal to a short journal
  def journal2short_journal(self):
    completion = openai.ChatCompletion.create(
      model="gpt-3.5-turbo",
      messages=[
        {"role": "user", "content":f"{self.journal} Provide a very short summary of the user's personal story, highlighting their interest in areas of good so it can be used to feed an youtube recommender system."}
      ],
      temperature=0
    )
    self.short_journal = completion.choices[0].message['content']
    return self.short_journal
  
  # Looking to expand this
  def querier(self):
    self.query = self.aspiration
    return self.query

  def youtube_searcher(self):
    search_response = self.youtube.search().list(
    q=self.query,
    type="video",
    part="id,snippet",
    maxResults=10
    ).execute()
    videos = []
    for search_result in search_response.get("items", []):
        video_id = search_result["id"]["videoId"]
        video_title = search_result["snippet"]["title"]
        video_description = search_result["snippet"]["description"]
        video_tags = search_result["snippet"]["tags"] if "tags" in search_result["snippet"] else []
        videos.append((video_title,video_id))
    self.youtube_videos = videos
    return self.youtube_videos


  def AI_filter(self):
    completion = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
      {"role": "user","content":f"User journal: {self.short_journal}. Now i need you to help the user by selecting three youtube videos in the interest of {self.aspiration} from this list  {[x[0] for x in self.youtube_videos]}"}

      ],
      temperature=0)
    return completion.choices[0].message['content']
    
  
  def refine_completion(self,msg):
    video_titles = re.findall(r'\d+\. (.+)', msg)
    result_list = {"completetion_response":msg}
    
    for title in video_titles:
        for video in self.youtube_videos:
          #second.append(video[0].strip("'"))
          if title.strip("'") == video[0].strip("'"):
              
            result_list[title]= video[1]
    print(result_list)
    return result_list

  def execute(self,aspiration,journal="",short_journal=""):
    self.aspiration = aspiration
    if journal == "" and short_journal != "":
      self.short_journal = short_journal
      if short_journal == "":
        raise Exception("Pass short_journal atleast if you cannot pass the journal")
    else:
      self.journal = journal
      self.short_journal = Tools.journal2short_journal(journal)
    self.querier()
    self.youtube_searcher()
    completion = self.AI_filter()
    
    return self.refine_completion(completion)




