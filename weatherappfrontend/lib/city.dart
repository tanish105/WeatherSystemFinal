import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CityWeather extends StatefulWidget {
  final String cityName;
  const CityWeather({super.key, required this.cityName});

  @override
  State<CityWeather> createState() => _CityWeatherState();
}

class _CityWeatherState extends State<CityWeather> {
  Map<String, dynamic>? weatherData;
  double maxTempThreshold = 30.0; // User-defined temperature threshold

  // Function to fetch weather data from the API
  Future<void> fetchCityWeather() async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:5000/weather/${widget.cityName}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double currentTemp = data['temp']; // Current temperature

        // Check if the current temperature exceeds the threshold
        if (currentTemp > maxTempThreshold) {
          _showAlert(); // Show alert if temperature exceeds threshold
        }

        setState(() {
          weatherData = data;
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Show alert dialog if temperature exceeds threshold
  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Temperature Alert'),
          content: Text(
              'The temperature in ${widget.cityName} has exceeded ${maxTempThreshold}°C!'),
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
    fetchCityWeather(); // Call the function to fetch weather data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather in ${widget.cityName}'),
      ),
      body: weatherData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    weatherData!['city'],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${weatherData!['temp']}°C',
                    style: const TextStyle(
                      fontSize: 80, // Large temperature display
                      fontWeight: FontWeight.w300,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getWeatherIcon(weatherData!['main_condition']),
                        size: 50,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        weatherData!['main_condition'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Feels Like: ${weatherData!['feels_like']}°C',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  // Function to map weather conditions to icons
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'haze':
        return Icons.filter_drama;
      default:
        return Icons.wb_cloudy;
    }
  }
}
