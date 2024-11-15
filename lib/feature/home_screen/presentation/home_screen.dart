
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/service/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final WeatherService _weatherService = WeatherService();
  String _city = 'Dhaka';
  Map<String, dynamic>? _currentWeather;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWeather();
  }

  // Fetch Weather
  Future<void> _fetchWeather() async {
    try{
      final weatherData = await _weatherService.fetchCurrentWeather(_city);

      setState(() {
        _currentWeather = weatherData;
      });
      // log('Weather Data : $weatherData');
    } catch (e) {
      print('Error to fetch weather data : $e');
    }
  }

  void showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter City Name'),
          content: TypeAheadField(
            suggestionsCallback: (search) async {
              return await _weatherService.fetchCitySuggestions(search);
            },
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'City',
                ),
              );
            },
            itemBuilder: (context, value) {
              return ListTile(title: Text(value['name']));
            },
            onSelected: (city) {
              setState(() {
                _city = city['name'].toString();
                // log('City Name : ${city['name'].toString()}');
              });
            },
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: const Text('Cancel')),
            TextButton(onPressed: () {
              Navigator.pop(context);
              _fetchWeather();
            }, child: const Text('Submit')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _currentWeather == null ? Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2344),
              Color.fromARGB(225, 125, 32, 142),
              Colors.purple,
              Color.fromARGB(225, 151, 44, 170),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2344),
              Color.fromARGB(225, 125, 32, 142),
              Colors.purple,
              Color.fromARGB(225, 151, 44, 170),
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showCitySelectionDialog();
              },
              child: Text(_city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),),
            ),
            Center(
              child: Column(
                children: [

                  Image.network(
                    'http:${_currentWeather!['current']['condition']['icon']}',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '${_currentWeather!['current']['temp_c'].round()} °C',
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${_currentWeather!['current']['condition']['text']}',
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Max: ${_currentWeather!['forecast']['forecastday'][0]['day']['maxtemp_c'].round()} °C',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Min: ${_currentWeather!['forecast']['forecastday'][0]['day']['mintemp_c'].round()} °C',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherDetail('Sunrise', Icons.wb_sunny, _currentWeather!['forecast']['forecastday'][0]['astro']['sunrise']),
                _buildWeatherDetail('Sunset', Icons.brightness_3, _currentWeather!['forecast']['forecastday'][0]['astro']['sunset']),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherDetail('Humidity', Icons.opacity, _currentWeather!['current']['humidity']),
                _buildWeatherDetail('Wild (KPH)', Icons.wind_power, _currentWeather!['current']['wind_kph']),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {

                },
                child: const Text('Next 7 Days Forecast'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherDetail(String level, IconData icon, dynamic value) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  const Color(0XFF1A2344).withOpacity(0.5),
                  const Color(0XFF1A2344).withOpacity(0.2),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 8),
                Text(level, style: GoogleFonts.lato(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),

                const SizedBox(height: 8),
                Text(value is String ? value : value.toString(), style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),


              ],
            ),
          ),
      ),
    );
  }
}
