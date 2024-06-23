from fastapi import FastAPI, Request, status
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates

import uvicorn
import requests

app = FastAPI()
templates = Jinja2Templates(directory="templates")


# def fetch_timezones():
#     url = "http://worldtimeapi.org/api/timezone"
#     response = requests.get(url)
#     if response.status_code == 200:
#         return response.json()
#     else:
#         print(f"Failed to fetch timezones, status code: {response.status_code}")
#         return []
#
#
# def bound_city_to_timezone(city):
#     url = 'http://worldtimeapi.org/api/timezone'
#
#     return dest

def get_local_time(dest):
    url = f"http://worldtimeapi.org/api/timezone/{dest}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        datetime = data['datetime']
    else:
        datetime = "Could not fetch time."
    return datetime


@app.get("/",response_class=HTMLResponse)
def index(request: Request):
    desired_tz_cities = {
        "New York": "America/New_York",
        "Berlin": "Europe/Berlin",
        "Tokyo": "Asia/Tokyo",
    }
    time = {}
    for dest in desired_tz_cities.values():
        time[dest] = get_local_time(dest)
    return templates.TemplateResponse("index.html", {"request": request, "time": time})


@app.get("/health")
def healthcheck():
    return JSONResponse(status_code=status.HTTP_200_OK, content='ok')

if __name__ == "__main__":
    # timezones = fetch_timezones()
    uvicorn.run(app, host="0.0.0.0", port=8080)
