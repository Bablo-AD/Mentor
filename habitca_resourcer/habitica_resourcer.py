import requests
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

# set your user ID and API token
user_id = "your_user_id"
api_token = "your_api_token"

# define the base URL for the Habitica API
base_url = "https://habitica.com/api/v3/"

# create headers for API requests
headers = {
    "x-api-user": user_id,
    "x-api-key": api_token,
    "Content-Type": "application/json"
}

# define a function to get user data
def get_user_data():
    url = base_url + "user"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        user_data = response.json()
        return user_data
    else:
        print("Error getting user data")
        return None

# define a function to get tasks
def get_tasks():
    url = base_url + "tasks/user"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        tasks = response.json()
        return tasks
    else:
        print("Error getting tasks")
        return None

# define a function to update a Google Keep note
def update_keep_note(note_id, content):
    creds = Credentials.from_authorized_user_file('token.json')
    service = build('keep', 'v1', credentials=creds)
    note = service.notes().get(noteId=note_id).execute()
    note['text'] += '\n' + content
    service.notes().update(noteId=note_id, body=note).execute()

# fetch user data and tasks
user_data = get_user_data()
if user_data:
    print("Welcome, " + user_data["data"]["profile"]["name"])
    tasks = get_tasks()
    if tasks:
        # create a dictionary to store the points for each tag
        tag_points = {}
        for task in tasks["data"]:
            if "tags" in task:
                for tag in task["tags"]:
                    if tag not in tag_points:
                        tag_points[tag] = 0
                    if task["completed"]:
                        tag_points[tag] += task["value"]

        # print the points for each tag
        for tag, points in tag_points.items():
            print(tag + ": " + str(points))

        # update the Google Keep note
        note_id = "your_note_id"
        content = "\n".join([tag + ": " + str(points) for tag, points in tag_points.items()])
        update_keep_note(note_id, content)
