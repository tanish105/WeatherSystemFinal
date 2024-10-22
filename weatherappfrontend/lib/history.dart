import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HistoricalData extends StatefulWidget {
  final String cityName;
  final String date; // Accept a date parameter

  const HistoricalData({
    Key? key,
    required this.cityName,
    required this.date, // Add date parameter to constructor
  }) : super(key: key);

  @override
  State<HistoricalData> createState() => _HistoricalDataState();
}

class _HistoricalDataState extends State<HistoricalData> {
  Map<String, dynamic>? weatherData;
  double maxTempThreshold = 30.0; // User-defined temperature threshold

  // Function to fetch weather data from the API
  Future<void> fetchCityWeather() async {
    try {
      // Fetch the weather summary for the given city and date
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:5000/weather/summary/${widget.cityName}?date=${widget.date}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the max temperature exceeds the threshold
        double maxTemp = data['max_temp'];
        if (maxTemp > maxTempThreshold) {
          _showAlert(maxTemp); // Show alert if max temperature exceeds threshold
        }

        setState(() {
          weatherData = data; // Store the weather data in the state
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Show alert dialog if temperature exceeds threshold
  void _showAlert(double maxTemp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Temperature Alert'),
          content: Text(
              'The maximum temperature in ${widget.cityName} on ${widget.date} was ${maxTemp.toStringAsFixed(1)}°C, which exceeds the threshold of ${maxTempThreshold}°C!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCityWeather(); // Fetch the weather data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historical Weather in ${widget.cityName}'),
      ),
      body: weatherData != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Dominant Condition: ${weatherData!['dominant_condition']}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Display the average temperature
                    Text(
                      'Average Temp: ${weatherData!['avg_temp'].toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display the maximum temperature
                    Text(
                      'Max Temp: ${weatherData!['max_temp']}°C',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display the minimum temperature
                    Text(
                      'Min Temp: ${weatherData!['min_temp']}°C',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
