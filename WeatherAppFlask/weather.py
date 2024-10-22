import datetime
from urllib.parse import quote_plus
from flask import Flask, jsonify, request
from flask_cors import CORS
import pymongo
import requests
from dotenv import load_dotenv
import os
from pymongo.server_api import ServerApi

from weather_utils import calculate_daily_summary

# Load environment variables from .env file
load_dotenv()
API_KEY = os.getenv('OPENWEATHERAPI')
MONGO_HOST = os.getenv("MONGO_HOST")
MONGO_USER = quote_plus(os.getenv("MONGO_USER"))
MONGO_PASS = quote_plus(os.getenv("MONGO_PASS"))
MONGO_URI = f"mongodb+srv://{MONGO_USER}:{MONGO_PASS}@{MONGO_HOST}/?retryWrites=true&w=majority"
client = pymongo.MongoClient(MONGO_URI, server_api=ServerApi('1'))
db = client.get_database('weather')
collection = db.get_collection('weatherdata')
app = Flask(__name__)
CORS(app)

def get_weather_city(city):
    # Call the OpenWeather API with city name
    resp = requests.get(f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric')

    # Check if the request was successful
    if resp.status_code == 200:
        weather_data = resp.json()
        # Extract desired fields
        main_condition = weather_data['weather'][0]['main']  # Main weather condition
        temp = weather_data['main']['temp']  # Current temperature in Centigrade
        feels_like = weather_data['main']['feels_like']  # Perceived temperature in Centigrade
        dt = weather_data['dt']  # Time of the data update (Unix timestamp)
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

# Route for getting weather by city name using GET method
@app.route('/weather/<city>', methods=['GET'])
def get_weather(city):
    weather_data = get_weather_city(city)
    if weather_data:
        return jsonify(weather_data), 200
    else:
        return jsonify({"error": "City not found or API error"}), 404

@app.route('/weather/multiple', methods=['GET'])
def fetch_weather_for_cities():
    # List of metro cities in India
    cities = ['Delhi', 'Mumbai', 'Chennai', 'Bangalore', 'Kolkata', 'Hyderabad']
    
    # Get the weather data for each city
    weather_data_list = []
    for city in cities:
        data = get_weather_city(city)
        if data:
            weather_data_list.append(data)
            # Save data to MongoDB
            weather_entry = {
                "city": data['city'],
                "temp": data['temp'],
                "feels_like": data['feels_like'],
                "main_condition": data['main_condition'],
            }
            db.weatherdata.insert_one(weather_entry)

    # Return the combined weather data as JSON response
    return jsonify({"weather_data": weather_data_list}), 200

@app.route('/weather/summary/<city>', methods=['GET'])
def get_daily_summary(city):
    """Fetch daily weather summary for a city."""

    # Get the date from the request query parameters (default to today)
    date_str = request.args.get('date')
    if date_str:
        date = datetime.strptime(date_str, '%Y-%m-%d')
    else:
        date = datetime.utcnow().date()  # Use today's date if no date is provided

    # Calculate daily summary
    summary = calculate_daily_summary(city, date)

    if summary:
        return jsonify(summary), 200
    else:
        return jsonify({"error": "No data available for the specified date"}), 404

if __name__ == "__main__":
    app.run(debug=True)
