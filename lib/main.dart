import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(WeatherlyApp());
}

class WeatherlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF4A90E2),
        scaffoldBackgroundColor: Color(0xFFF8F8FF),
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
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
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weatherly")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🌤️ 72°F – Atlanta", style: TextStyle(fontSize: 24)),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/forecast'), child: Text("Forecast")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/map'), child: Text("Map")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/theme'), child: Text("Themes")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/community'), child: Text("Community")),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/alerts'), child: Text("Alerts")),
          ],

        ),
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
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      body: forecastList.isEmpty
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
            title: Text("$date – $tempMin°F to $tempMax°F"),
            subtitle: Text(condition),
          );
        },
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final mapboxAccessToken = 'pk.eyJ1IjoiYWRuYW40MjMiLCJhIjoiY21hN2psbWtoMGdhbzJpb2J4dzkydnAyMSJ9.eixXQHgUPUzVzfxgRqLgXA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather Map")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(33.7490, -84.3880), // Atlanta
          zoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/$mapboxStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken',
            additionalOptions: {
              'accessToken': mapboxAccessToken,
              'styleId': mapboxStyleId,
            },
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
      appBar: AppBar(title: Text("Theme Settings")),
      body: Column(
        children: [
          ListTile(title: Text("☀️ Sunny Theme")),
          ListTile(title: Text("🌧️ Rainy Theme")),
          ElevatedButton(onPressed: () {}, child: Text("Upload Custom Theme"))
        ],
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Reports")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _reportController,
              decoration: InputDecoration(labelText: "What's the weather like?", border: OutlineInputBorder()),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_reportController.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('reports').add({
                  'message': _reportController.text,
                  'timestamp': Timestamp.now(),
                });
              }
            },
            child: Text("Submit"),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final report = docs[index]['message'];
                    return ListTile(title: Text(report));
                  },
                );
              },
            ),
          )
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
    // Example: You can push to Firestore or use Firebase Messaging here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personal Alerts")),
      body: Column(
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
          ElevatedButton(onPressed: _updateAlerts, child: Text("Save Alerts"))
        ],
      ),
    );
  }
}
