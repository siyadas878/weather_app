import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/api.dart';


void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: const LocationScreen(),
  ));
}



class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _latitude = 'Unknown';
  String _longitude = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (await _checkPermission()) {
      _getLocation();
    } else {
      _requestPermission();
    }
  }

  Future<bool> _checkPermission() async {
    return await Permission.location.isGranted;
  }

  Future<void> _requestPermission() async {
    if (await Permission.location.request().isGranted) {
      _getLocation();
    } else {
      print('Location permission denied by user.');
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weather'),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getApi(_latitude, _longitude),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/celsius.png',
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pin_drop),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${snapshot.data!['name']}',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CardWidget(
                        title:
                            'Temperature: ${snapshot.data!['main']['temp']}°C',
                        icon: Icons.cabin),
                    CardWidget(
                        title:
                            'Pressure: ${snapshot.data!['main']['pressure']} hPa',
                        icon: Icons.alarm),
                    CardWidget(
                        title:
                            'Humidity: ${snapshot.data!['main']['humidity']}%',
                        icon: Icons.water_drop),
                    CardWidget(
                        title:
                            'Weather: ${snapshot.data!['weather'][0]['main']}',
                        icon: Icons.cloud),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Loading state while waiting for data
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}


class CardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  const CardWidget({
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
      ),
    );
  }
}
