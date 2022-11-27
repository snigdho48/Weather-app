import 'dart:convert';
import '../models/current_weather_response.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/forecast_weather_response.dart';
import '../utils/constants.dart';

class WeatherProvider extends ChangeNotifier {
  CurrentWeatherResponse? currentWeather;
  ForecastWeatherResponse? forecastWeather;

  double latitude = 0.0;
  double longitude = 0.0;
  String tempUnit = metric;
  String tempSymbol = celsius;

  void setNewPosition(double la, double ln) {
    latitude = la;
    longitude = ln;
  }

  bool get hasDataLoaded => currentWeather != null && forecastWeather != null;

  void getData() {
    current();
    forecast();
  }

  Future<void> current() async {
    final urlString =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$tempUnit&appid=$weatherApiKey';
    try {
      final response = await http.get(Uri.parse(urlString));
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        currentWeather = CurrentWeatherResponse.fromJson(map);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> forecast() async {
    final urlString =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$tempUnit&appid=$weatherApiKey';
    try {
      final response = await http.get(Uri.parse(urlString));
      final map = json.decode(response.body);
      if (response.statusCode == 200) {
        forecastWeather = ForecastWeatherResponse.fromJson(map);
        print(map);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> convertLocation(String address) async {
    try {
      final locationList = await locationFromAddress(address);
      if (locationList.isNotEmpty) {
        final location = locationList.first;
        latitude = location.latitude;
        longitude = location.longitude;
        if (cities.contains(address) == false) {
          cities.add(address);
        }
        getData();
      } else {
        print('location not found');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  void setUnit(bool status) {
    tempUnit = status ? imperial : metric;
    tempSymbol = status ? fahrenheit : celsius;
    getData();
  }
}
