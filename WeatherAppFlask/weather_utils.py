from datetime import datetime
import requests
from dotenv import load_dotenv
import os
from bson.son import SON
from mongo_utils import get_daily_weather_summaries, get_weather_collection, save_daily_summary

# Load environment variables
load_dotenv()

API_KEY = os.getenv('OPENWEATHERAPI')

def get_weather_city(city):
    """Fetch weather data for a given city using OpenWeather API."""
    try:
        resp = requests.get(f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric')

        if resp.status_code == 200:
            weather_data = resp.json()
            main_condition = weather_data['weather'][0]['main']  # Main weather condition
            temp = weather_data['main']['temp']  # Current temperature
            feels_like = weather_data['main']['feels_like']  # Perceived temperature
            dt = weather_data['dt']  # Timestamp
            name = weather_data['name']

            return {
                "main_condition": main_condition,
                "temp": temp,
                "feels_like": feels_like,
                "dt": dt,
                "city": name
            }
        else:
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching weather data for {city}: {e}")
        return None

def calculate_daily_summary(city, date):
    """Calculate daily weather summary for a city."""
    collection = get_weather_collection()

    pipeline = [
        {
            "$match": {
                "city": city,
                "timestamp": {
                    "$gte": datetime.combine(date, datetime.min.time()),
                    "$lt": datetime.combine(date, datetime.max.time())
                }
            }
        },
        {
            "$group": {
                "_id": "$city",
                "avg_temp": {"$avg": "$temp"},
                "max_temp": {"$max": "$temp"},
                "min_temp": {"$min": "$temp"},
                "dominant_condition": {"$push": "$main_condition"}
            }
        }
    ]

    result = list(collection.aggregate(pipeline))

    if result:
        summary = result[0]
        # Determine the most frequent weather condition as dominant
        conditions = summary['dominant_condition']
        dominant_condition = max(set(conditions), key=conditions.count)

        # Create a summary dictionary
        daily_summary = {
            "avg_temp": summary["avg_temp"],
            "max_temp": summary["max_temp"],
            "min_temp": summary["min_temp"],
            "dominant_condition": dominant_condition
        }

        # Save the daily summary using the new function
        save_daily_summary(city, date, daily_summary)

        return daily_summary

    return None
