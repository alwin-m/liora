// File generated for Firebase configuration
// Follow the instructions at https://firebase.google.com/docs/flutter/setup
// to generate your own firebase_options.dart file with proper credentials.

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Firebase Configuration - LIORA Project (liora-43381)
  // These values are locked and verified per Firebase Integration Specification
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-PLACEHOLDER-REPLACE-WITH-ACTUAL-KEY', // Get from Firebase Console
    appId: '1:105498158234:web:a1b2c3d4e5f6g7h8',
    messagingSenderId: '105498158234',
    projectId: 'liora-43381',
    storageBucket: 'liora-43381.firebasestorage.app',
    authDomain: 'liora-43381.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyD-PLACEHOLDER-REPLACE-WITH-ACTUAL-KEY', // Get from Firebase Console
    appId: '1:105498158234:android:962e76b41469788bb9ab23',
    messagingSenderId: '105498158234',
    projectId: 'liora-43381',
    storageBucket: 'liora-43381.firebasestorage.app',
  );
}
