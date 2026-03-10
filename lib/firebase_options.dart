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
    apiKey: 'AIzaSyAJbaJ3XcctF6__fG2G_iTEJoYr7iATJ_A',
    appId: '1:74788691186:web:906174f93bcb883494846b',
    messagingSenderId: '74788691186',
    projectId: 'oneconnect-b7306',
    authDomain: 'oneconnect-b7306.firebaseapp.com',
    storageBucket: 'oneconnect-b7306.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJbaJ3XcctF6__fG2G_iTEJoYr7iATJ_A',
    appId: '1:74788691186:android:906174f93bcb883494846b',
    messagingSenderId: '74788691186',
    projectId: 'oneconnect-b7306',
    storageBucket: 'oneconnect-b7306.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJbaJ3XcctF6__fG2G_iTEJoYr7iATJ_A',
    appId: '1:74788691186:ios:906174f93bcb883494846b',
    messagingSenderId: '74788691186',
    projectId: 'oneconnect-b7306',
    storageBucket: 'oneconnect-b7306.firebasestorage.app',
    iosBundleId: 'com.example.oneconnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJbaJ3XcctF6__fG2G_iTEJoYr7iATJ_A',
    appId: '1:74788691186:ios:906174f93bcb883494846b',
    messagingSenderId: '74788691186',
    projectId: 'oneconnect-b7306',
    storageBucket: 'oneconnect-b7306.firebasestorage.app',
    iosBundleId: 'com.example.oneconnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAJbaJ3XcctF6__fG2G_iTEJoYr7iATJ_A',
    appId: '1:74788691186:web:906174f93bcb883494846b',
    messagingSenderId: '74788691186',
    projectId: 'oneconnect-b7306',
    authDomain: 'oneconnect-b7306.firebaseapp.com',
    storageBucket: 'oneconnect-b7306.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );
}
