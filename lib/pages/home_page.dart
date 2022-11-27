import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/weather_preferences.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/datetimeposition.dart';
import '../utils/helper_functions.dart';
import '../utils/search.dart';
import '../utils/textstyles.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WeatherProvider provider;
  bool calledOnce = true;
  bool tempUnitStatus = false;

  @override
  void didChangeDependencies() {
    if (calledOnce) {
      provider = Provider.of<WeatherProvider>(context);
      _getData();
    }
    getBool(prefUnit).then((value) {
      setState(() {
        tempUnitStatus = value;
      });
    });
    calledOnce = false;

    super.didChangeDependencies();
  }

  void _getData() async {
    final position = await determinePosition();
    provider.setNewPosition(position.latitude, position.longitude);
    final status = await getBool(prefUnit);
    provider.setUnit(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(),
              ).then((city) {
                if (city != null && city.isNotEmpty) {
                  provider.convertLocation(city);
                }
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: provider.hasDataLoaded
          ? Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      // activeThumbImage: Image.network(ac).image,
                      // inactiveThumbImage: Image.network(inac).image,
                      value: tempUnitStatus,
                      onChanged: (value) async {
                        setState(() {
                          tempUnitStatus = value;
                        });
                        await setBool(prefUnit, value);
                        context.read<WeatherProvider>().setUnit(value);
                      },
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                  height: 2,
                  color: Colors.cyan,
                ),
                _cWeather(),
                const Divider(
                  thickness: 2,
                  height: 2,
                  color: Colors.cyan,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .2,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _fWeather(),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('Please wait'),
            ),
    );
  }

  Widget _cWeather() {
    final current = provider.currentWeather;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Text(
                  getFormattedDate(
                    current!.dt!,
                    pattern: 'EEE dd, yyyy',
                  ),
                  style: txtDate16,
                ),
                Text(
                  '${current.name}, ${current.sys!.country}',
                  style: txtAddress20,
                ),
              ],
            ),
          ],
        ),
        Image.network(
          '$iconPrefix${current.weather![0].icon}$iconSuffix',
          color: Colors.white,
        ),
        Text(
          '${current.main!.temp!.round()}$degree${provider.tempSymbol}',
          style: txtTempBig80,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Text(
                  current.weather![0].description!,
                  style: txtAddress20,
                ),
                Text(
                  'It Feels like ${current.main!.feelsLike!.round()}$degree${provider.tempSymbol}',
                  style: txtTempNormal18,
                ),
              ],
            ),
          ],
        ),
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'Humidity ${current.main!.humidity!}%',
                style: txtTempNormal18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'Pressure ${current.main!.pressure!}hPa',
                style: txtTempNormal18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'Visibility ${current.visibility} meter',
                style: txtTempNormal18,
              ),
            ),
          ],
        ),
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'Sunrise ${getFormattedDate(current.sys!.sunrise!, pattern: 'hh:mm a')}',
                style: txtAddress20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'Sunset ${getFormattedDate(current.sys!.sunset!, pattern: 'hh:mm a')}',
                style: txtAddress20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fWeather() {
    final itemList = provider.forecastWeather!.list!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: itemList
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Container(
                    color: Colors.deepPurple,
                    height: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getFormattedDate(item.dt!, pattern: 'EEE, HH:mm'),
                          style: txtDate16,
                        ),
                        Image.network(
                          '$iconPrefix${item.weather![0].icon}$iconSuffix',
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          '${item.main!.tempMax!.round()}/${item.main!.tempMax!.round()}$degree${provider.tempSymbol}',
                          style: txtDate16,
                        ),
                        Text(
                          item.weather![0].description!,
                          style: txtDate16,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
