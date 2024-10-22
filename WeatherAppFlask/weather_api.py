from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
from weather_utils import calculate_daily_summary, get_weather_city  # Import utility function
from mongo_utils import get_weather_collection  # Import MongoDB connection
app = Flask(__name__)
CORS(app)
@app.route('/weather/<city>', methods=['GET'])
def get_weather(city):
    """Fetch weather data for a single city."""
    weather_data = get_weather_city(city)
    print(weather_data)  # Debugging line
    if not weather_data:
        return jsonify({"error": "City not found or API error"}), 404
    collection = get_weather_collection()
    
    weather_entry = {
        "city": weather_data['city'],
        "temp": weather_data['temp'],
        "feels_like": weather_data['feels_like'],
        "main_condition": weather_data['main_condition'],
        "timestamp": datetime.utcnow()  # Store in UTC
    }
    try:
        collection.insert_one(weather_entry)
    except Exception as e:
        print(f"Error inserting data into MongoDB for {city}: {e}")
        return jsonify({"error": "Failed to store weather data in the database"}), 500
    return jsonify(weather_data), 200
@app.route('/weather/multiple', methods=['GET'])
def fetch_weather_for_cities():
    """Fetch weather data for multiple metro cities in India and save to MongoDB."""
    cities = ['Delhi', 'Mumbai', 'Chennai', 'Bangalore', 'Kolkata', 'Hyderabad']
    weather_data_list = []
    
    collection = get_weather_collection()  # Get MongoDB collection
    for city in cities:
        data = get_weather_city(city)
        if data:
            weather_data_list.append(data)
            
            # Prepare weather entry for MongoDB
            weather_entry = {
                "city": data['city'],
                "temp": data['temp'],
                "feels_like": data['feels_like'],
                "main_condition": data['main_condition'],
                "timestamp": datetime.utcnow()  # Store in UTC
            }
            # Insert into MongoDB with error handling
            try:
                collection.insert_one(weather_entry)
            except Exception as e:
                print(f"Error inserting data into MongoDB for {city}: {e}")
                return jsonify({"error": "Failed to store weather data in the database"}), 500
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
