// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6nmmA6_2K0xeQmYkvdohO-wNlbqQ-UfY',
    appId: '1:493668357375:web:b8a7eb65e76da2cd41a8ca',
    messagingSenderId: '493668357375',
    projectId: 'project2henry',
    authDomain: 'project2henry.firebaseapp.com',
    storageBucket: 'project2henry.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFt655Bx3pAIzb-oketShCT3Q1vS61ERo',
    appId: '1:493668357375:android:8321c51a2a46543d41a8ca',
    messagingSenderId: '493668357375',
    projectId: 'project2henry',
    storageBucket: 'project2henry.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCktq2gWpq-J5WZ1ygyxJq-Au9eHb4gCWA',
    appId: '1:493668357375:ios:fc930cd43a4dca2141a8ca',
    messagingSenderId: '493668357375',
    projectId: 'project2henry',
    storageBucket: 'project2henry.firebasestorage.app',
    iosBundleId: 'com.example.project2Henry',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCktq2gWpq-J5WZ1ygyxJq-Au9eHb4gCWA',
    appId: '1:493668357375:ios:fc930cd43a4dca2141a8ca',
    messagingSenderId: '493668357375',
    projectId: 'project2henry',
    storageBucket: 'project2henry.firebasestorage.app',
    iosBundleId: 'com.example.project2Henry',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6nmmA6_2K0xeQmYkvdohO-wNlbqQ-UfY',
    appId: '1:493668357375:web:59aa353d4d895c7841a8ca',
    messagingSenderId: '493668357375',
    projectId: 'project2henry',
    authDomain: 'project2henry.firebaseapp.com',
    storageBucket: 'project2henry.firebasestorage.app',
  );
}
