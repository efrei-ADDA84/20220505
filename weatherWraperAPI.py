from os import environ
import requests
from fastapi import FastAPI

API_Key = "3d483ba26d36dfb88f6ae88729d42f51"
#environ.get("API_KEY")

# ================ fastAPI setup ================

app = FastAPI()

@app.get("/")
async def read_item(lat:float, lon:float):
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_Key}"
    res = requests.get(url)
    data = res.json()
    return data


