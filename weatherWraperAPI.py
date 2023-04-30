from os import environ
import requests
from fastapi import FastAPI

# ================ fastAPI setup ================

API_Key=environ.get("API_KEY")

app = FastAPI()

@app.get("/")
async def read_item(lat:float, lon:float):
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_Key}"
    res = requests.get(url)
    data = res.json()
    return data


