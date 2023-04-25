# Note: you need to be using OpenAI Python v0.27.0 for the code below to work

import openai
import os
import re

openai.api_key = os.environ.get('OPENAI_API_KEY')
THE_VIDEOS = [('Genius makeup tutorial and beauty hacks you&#39;ll love', 'kr2WjPgPny8'), ('LSD - Genius ft. Sia, Diplo, Labrinth | EASY Piano Tutorial', 'oxcGeyPm27s'), ('How to become a Math Genius.✔️ How do genius people See a math problem! by mathOgenius', '1_DSMABQZbk'), ('Sign Up Genius Tutorial', 'm7EpNx1xXIg'), ('Sketch Genius Review &amp; Hindi Demo | The best tool to edit unique and creative videos- Sketch Genius', '3ASBAqOSOis'), ('This is GENIUS!', 't3miXQ8ToZY'), ('Genius Paper Bag Pockets By Lize - Accordion Folder Pockets', 'l-J0pgQ9cw8'), ('How To Make A Genius Video | Official Tutorial', 'D2231YAnU2g'), ('Dimsport genius how to use tutorial part 1 of 3', 'iF9ERy9jtRA'), ('Seiko Magic Lever, A Genius Mechanism', 'FmcV4nEVynQ')]
aspiration = "i was born in India in 2005 to a great mom and dad who took me care from the kid i got interest in electronics and robotics i grew up in victim mentality and i was a huge procrastinator i don't do well in school but everything changed when the covid and lockdown came i got access to the computer and i learnt to code and watched motivational video self help videos and got myself exercising and i gone into twitter to just be admired at this guy called elon musk who landed a rocket and make autopilot electric cars. I started building some great products and everything was going fine until the youtube and google which i used turned against me i mean i used it wrong i watched porn masturbated and got addicted to youtube, i got hydroxyphobia i feared about rabies and blood cancer"
interest = "Genius"
completion = openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
    {"role": "user", "content":f"{aspiration} Provide a very short summary of the user's personal story, highlighting their interest in areas of good so it can be used to feed an youtube recommender system."}
  ],
  temperature=0
)
print(completion.choices[0].message['content'])
#print(f"User journal: {completion.choices[0].message['content']}. Recommend quality YouTube videos related to {interest}. Video details: {[x[0] for x in THE_VIDEOS]}")
completion = openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
    {"role": "user","content":f"User journal: {completion.choices[0].message['content']}. Now i need you to help the user by selecting three youtube videos in the interest of {interest} from this list  {[x[0] for x in THE_VIDEOS]}"}

     ],
     temperature=0
)
print(completion.choices[0].message['content'])

# Extract video titles using regular expression
video_titles = re.findall(r'\d+\. (.+)', completion.choices[0].message['content'])
print(video_titles)