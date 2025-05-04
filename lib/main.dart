import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

final ThemeData sunnyTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.orange,
  scaffoldBackgroundColor: Colors.yellow[50],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
);

final ThemeData rainyTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue[900],
  scaffoldBackgroundColor: Colors.blueGrey[50],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[900],
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[900],
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
);
final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(sunnyTheme);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(WeatherlyApp());
}

class WeatherlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (_, theme, __) {
        return MaterialApp(
          title: 'Weatherly',
          theme: theme,
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/forecast': (context) => ForecastScreen(),
            '/map': (context) => MapScreen(),
            '/theme': (context) => ThemeSettingsScreen(),
            '/community': (context) => CommunityScreen(),
            '/alerts': (context) => AlertsScreen(),
          },
        );
      },
    );
  }
}

Future<Map<String, dynamic>?> fetchCurrentWeather() async {
  const apiKey = '8377ee3a600148eaa8310845250305';
  const city = 'Atlanta';
  final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'temp': data['current']['temp_f'],
        'icon': "https:${data['current']['condition']['icon']}",
        'desc': data['current']['condition']['text'],
      };
    }
  } catch (e) {
    print('Weather fetch error: $e');
  }
  return null;
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> weatherFuture;
  final String city = 'Atlanta';

  @override
  void initState() {
    super.initState();
    weatherFuture = fetchCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weatherly")),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/gg.webp',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content with padding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Weatherly",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BFCF),
                  ),
                ),
                SizedBox(height: 16),

                FutureBuilder<Map<String, dynamic>?>(
                  future: weatherFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading...",
                          style: TextStyle(fontSize: 24, color: Colors.white));
                    }
                    final weather = snapshot.data!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(weather['icon'], width: 40),
                        SizedBox(width: 8),
                        Text(
                          "${weather['temp']}°F – $city",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),

                // Buttons
                for (var route in [
                  ['Forecast', '/forecast'],
                  ['Map', '/map'],
                  ['Themes', '/theme'],
                  ['Community', '/community'],
                  ['Alerts', '/alerts'],
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, route[1]),
                      child: Text(route[0]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ForecastScreen extends StatefulWidget {
  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic> forecastList = [];

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    const apiKey = '8377ee3a600148eaa8310845250305';
    const city = 'Atlanta';
    final url =
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=7&aqi=no&alerts=no';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forecastList = data['forecast']['forecastday'];
        });
      } else {
        print("Failed to fetch forecast. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forecast")),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/forecast2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          forecastList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: forecastList.length,
            itemBuilder: (context, index) {
              final day = forecastList[index];
              final date = day['date'];
              final condition = day['day']['condition']['text'];
              final iconUrl = "https:${day['day']['condition']['icon']}";
              final tempMin = day['day']['mintemp_f'];
              final tempMax = day['day']['maxtemp_f'];

              return ListTile(
                leading: Image.network(iconUrl, width: 40),
                title: Text(
                  "$date – $tempMin°F to $tempMax°F",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  condition,
                  style: TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class MapScreen extends StatelessWidget {
  final mapboxAccessToken =
      'pk.eyJ1IjoiYWRuYW40MjMiLCJhIjoiY21hN2psbWtoMGdhbzJpb2J4dzkydnAyMSJ9.eixXQHgUPUzVzfxgRqLgXA';
  final mapboxStyleId = 'mapbox/streets-v11';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather Map")),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: LatLng(33.7490, -84.3880), // Atlanta
          initialZoom: 10,
        ),
        children: [
          // Mapbox base layer
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/$mapboxStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken',
            additionalOptions: {
              'accessToken': mapboxAccessToken,
              'styleId': mapboxStyleId,
            },
          ),

          // RainViewer radar overlay with proper opacity
          TileLayer(
            urlTemplate:
            'https://tilecache.rainviewer.com/v2/radar/latest/256/{z}/{x}/{y}/2/1_1.png',
            tileProvider: NetworkTileProvider(),
            tileDisplay: TileDisplay.fadeIn(
              duration: Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Theme Settings')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/theme.webp',
              fit: BoxFit.cover,
            ),
          ),

          // Content overlay
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.wb_sunny, color: Colors.orange),
                    title: Text("Sunny Theme"),
                    onTap: () => themeNotifier.value = sunnyTheme,
                  ),
                  ListTile(
                    leading: Icon(Icons.grain, color: Colors.blue[900]),
                    title: Text("Rainy Theme"),
                    onTap: () => themeNotifier.value = rainyTheme,
                  ),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Upload Custom Theme'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _reportController = TextEditingController();

  void _submitReport() {
    if (_reportController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('reports').add({
        'message': _reportController.text,
        'timestamp': Timestamp.now(),
      });
      _reportController.clear();
    }
  }

  void _deleteReport(String docId) {
    FirebaseFirestore.instance.collection('reports').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Reports")),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/comm.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(12),
              color: Colors.white.withOpacity(0.85),
              child: Column(
                children: [
                  TextField(
                    controller: _reportController,
                    decoration: InputDecoration(
                      labelText: "What's the weather like?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitReport,
                    child: Text("Submit"),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reports')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final message = doc['message'];

                            return ListTile(
                              title: Text(message),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteReport(doc.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool rainAlert = false;
  bool tempAlert = false;

  void _updateAlerts() {
    print("Rain alert: $rainAlert, Temp alert: $tempAlert");
    // Example: Push to Firestore or Firebase Messaging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personal Alerts")),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/noti.jpg', // Make sure it's listed in pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          Container(
            color: Colors.white.withOpacity(0.85), // Optional overlay for readability
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text("Alert me if it rains tomorrow"),
                  value: rainAlert,
                  onChanged: (val) => setState(() => rainAlert = val),
                ),
                SwitchListTile(
                  title: Text("Alert me if temp > 90°F"),
                  value: tempAlert,
                  onChanged: (val) => setState(() => tempAlert = val),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateAlerts,
                  child: Text("Save Alerts"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}