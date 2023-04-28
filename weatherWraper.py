from sys import argv

import requests

API_Key = argv[3]
lat, lon = argv[1], argv[2]
url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_Key}"

res = requests.get(url)
data = res.json()

print(data)

