import requests
import json
import os
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# Get API credentials from environment variables
API_USER = os.environ.get("HABITICA_API_USER")
API_KEY = os.environ.get("HABITICA_API_KEY")

# Get Google Keep note ID and API key from environment variables
KEEP_NOTE_ID = os.environ.get("KEEP_NOTE_ID")
KEEP_API_KEY = os.environ.get("KEEP_API_KEY")

# Set up the credentials object for Google API access
creds = None

if KEEP_API_KEY:
    creds = Credentials.from_apis_console_key(KEEP_API_KEY)

# Function to get all tasks from Habitica API
def get_habitica_tasks():
    url = f"https://habitica.com/api/v3/tasks/user"
    headers = {
        "x-api-user": API_USER,
        "x-api-key": API_KEY
    }
    response = requests.get(url, headers=headers)
    tasks = json.loads(response.content)
    return tasks["data"]

# Function to update a Google Keep note
def update_keep_note(note_id, text):
    if not creds:
        print("Google API key not found in environment variables.")
        return False
    
    url = f"https://www.googleapis.com/keep/v1/notes/{note_id}"
    headers = {
        "Authorization": f"Bearer {creds.token}",
        "Content-Type": "application/json"
    }
    data = {
        "text": text
    }
    response = requests.put(url, headers=headers, json=data)
    return response.ok

# Get all tasks from Habitica API
tasks = get_habitica_tasks()

# Create dictionary to store points for each tag
points = {}

# Loop through tasks and add points for each tag
for task in tasks:
    if task["type"] == "habit" and task["tags"]:
        for tag in task["tags"]:
            if tag not in points:
                points[tag] = 0
            if task["completed"]:
                if task["value"] > 0:
                    points[tag] += task["value"]
                else:
                    points[tag] += 1

# Generate text for the Google Keep note
note_text = "Habitica points by tag:\n\n"
for tag, point in points.items():
    note_text += f"{tag}: {point}\n"

# Update the Google Keep note with the points for each tag
update_keep_note(KEEP_NOTE_ID, note_text)
