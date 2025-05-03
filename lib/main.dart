import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
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
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/forecast'), child: Text("Forecast")),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/map'), child: Text("Map")),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/theme'), child: Text("Themes")),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/community'), child: Text("Community")),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/alerts'), child: Text("Alerts")),
          ],
        ),
      ),
    );
  }
}

class ForecastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forecast")),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.cloud),
            title: Text("Day $index – 70°F - 80°F"),
            subtitle: Text("Partly Cloudy"),
          );
        },
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather Map")),
      body: Center(child: Text("🌍 Map View Coming Soon")),
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
