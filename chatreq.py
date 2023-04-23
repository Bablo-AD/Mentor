import requests
import json

url = 'https://chatgpt-api.shn.hk/v1/'
headers = {'Content-Type': 'application/json'}

data = {
    'model': 'gpt-3.5-turbo',
    'messages': [{'role': 'user', 'content': 'Hello, how are you?'}]
}

response = requests.post(url, headers=headers, data=json.dumps(data))

print(response.json())
