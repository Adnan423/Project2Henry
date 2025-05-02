import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
