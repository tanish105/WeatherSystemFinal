import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherappfrontend/city.dart';
import 'package:weatherappfrontend/history.dart';

class landingPage extends StatefulWidget {
  const landingPage({super.key});

  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  List<dynamic> weatherData = [];
  final TextEditingController _controller = TextEditingController();
  String _inputText = '';
  Timer? _timer;

  // Function to fetch weather data from the API
  Future<void> fetchWeatherData() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:5000/weather/multiple'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = data['weather_data']; // Extract the weather data
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(); // Call the function to fetch weather data when the page loads
    // Set up a periodic timer to call the weather API every 5 minutes (300 seconds)
    // _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
    //   fetchWeatherData(); // Fetch updated weather data every 5 minutes
    // });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _submitInput() {
    setState(() {
      _inputText = _controller.text; // Get the text from the controller
    });
    _controller.clear(); // Clear the input field after submission
    // Navigate to the city page and pass the input text
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CityWeather(cityName: _inputText), // Pass the city name
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Weather Application System',
            style: TextStyle(fontSize: 35),
          ),
        ),
        toolbarHeight: 100.0,
      ),
      body: weatherData.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                    height:
                        30), // Adjust this value to control the gap between AppBar and ListView
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the Row contents
                  children: [
                    Container(
                      width: 300, // Set the desired width here
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search for a city',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          labelText: 'Enter city',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 40), // Space between input field and button
                FilledButton(
                  onPressed: _submitInput,
                  child: const Text('Fetch Weather'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Weather in Indian metro cities',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.9, // Limit width to 90% of the screen
                    height: 200, // Height for the horizontal ListView
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final cityWeather = weatherData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0), // Add horizontal spacing
                          child: WeatherTile(
                            city: cityWeather['city'],
                            mainCondition: cityWeather['main_condition'],
                            temp: cityWeather['temp'].toString(),
                            feelsLike: cityWeather['feels_like'].toString(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator()), // Show loading spinner while data is being fetched
    );
  }
}

class WeatherTile extends StatelessWidget {
  final String city;
  final String mainCondition;
  final String temp;
  final String feelsLike;

  const WeatherTile({
    Key? key,
    required this.city,
    required this.mainCondition,
    required this.temp,
    required this.feelsLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the CityWeather page, passing the city name and weather details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoricalData(
              cityName: city, date: '2024-10-18',
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 160, // Set width for each weather card
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Temp: $temp°C'),
              Text('Condition: $mainCondition'),
              Text('Feels Like: $feelsLike°C'),
            ],
          ),
        ),
      ),
    );
  }
}

