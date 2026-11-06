// File generated for XYZ Startup Firebase initialization
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static const String apiKey = 'AIzaSyBi-Hzbe4vKRBlqUZL5DTAa97ztNcHA-pY';
  static const String authDomain = 'mars-1d49a.firebaseapp.com';
  static const String projectId = 'mars-1d49a';
  static const String storageBucket = 'mars-1d49a.firebasestorage.app';
  static const String messagingSenderId = '1004866111513';
  static const String appId = '1:1004866111513:web:19835e4bdd3e26a6f88288';
  static const String measurementId = 'G-3LWPJV7CHK';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
    measurementId: measurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.xyzstartup.driverApp',
  );
}
