import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/service/weather_service.dart';

class ForecastScreen extends StatefulWidget {

  String city;

   ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {

  final WeatherService _weatherService = WeatherService();
  List<dynamic>? _forecast;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchForecast();
  }

  // Fetch Weather
  Future<void> _fetchForecast() async {
    try{
      final forecastData = await _weatherService.fetch7DayForecast(widget.city);
      setState(() {
        _forecast = forecastData['forecast']['forecastday'];
      });
      // log('Weather Data : $weatherData');
    } catch (e) {
      print('Error to fetch weather data : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _forecast == null ? Container(
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
          height: MediaQuery.of(context).size.height,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
                      ),
                      const Text('7 Day Forecast', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _forecast!.length,
                  itemBuilder: (context, index) {
                    final day = _forecast![index];
                    String iconUrl = 'http:${day['day']['condition']['icon']}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                      child: ClipRRect(
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
                            child: ListTile(
                              leading: Image.network(iconUrl),
                              title: Text(
                                '${day['date']} - ${day['day']['avgtemp_c'].round()}°C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                day['day']['condition']['text'],
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Text(
                                'Max: ${day['day']['maxtemp_c']}°C\nMin: ${day['day']['mintemp_c']}',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
