from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.server_api import ServerApi
from urllib.parse import quote_plus
import os

# Load environment variables
load_dotenv()

MONGO_HOST = os.getenv("MONGO_HOST")
MONGO_USER = quote_plus(os.getenv("MONGO_USER"))
MONGO_PASS = quote_plus(os.getenv("MONGO_PASS"))
MONGO_URI = f"mongodb+srv://{MONGO_USER}:{MONGO_PASS}@{MONGO_HOST}/?retryWrites=true&w=majority"

def get_mongo_client():
    """Connect to MongoDB and return a client."""
    client = MongoClient(MONGO_URI, server_api=ServerApi('1'))
    return client

def get_weather_collection():
    """Get weather data collection."""
    client = get_mongo_client()
    db = client.get_database('weather')
    return db.get_collection('weatherdata')

def get_daily_weather_summaries():
    client = get_mongo_client()
    db = client.get_database('weather')
    return db.get_collection('daily_weather_summaries')

def save_daily_summary(city, date, summary):
    """Save the daily weather summary to MongoDB."""
    client = get_mongo_client()
    db = client.get_database('weather')

    daily_summary = {
        "city": city,
        "date": date,
        "avg_temp": summary["avg_temp"],
        "max_temp": summary["max_temp"],
        "min_temp": summary["min_temp"],
        "dominant_condition": summary["dominant_condition"]
    }

    try:
        db.get_collection('daily_weather_summaries').insert_one(daily_summary)
        print(f"Daily summary saved for {city} on {date}")
    except Exception as e:
        print(f"Failed to save daily summary for {city}: {e}")
