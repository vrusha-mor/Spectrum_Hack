import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0PNu5t_It_o7ccYj39CwKFAUYOxj83KM',
    appId: '1:642790847745:web:9496350dd9e26e4a77d700',
    messagingSenderId: '642790847745',
    projectId: 'spectrum-web-7435d',
    authDomain: 'spectrum-web-7435d.firebaseapp.com',
    storageBucket: 'spectrum-web-7435d.firebasestorage.app',
    measurementId: 'G-MVGG7TCJ0V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqPN3YOti60DnnMdsZUHZLl29p5ezYpRk',
    appId: '1:642790847745:android:1359ca49f873167377d700',
    messagingSenderId: '642790847745',
    projectId: 'spectrum-web-7435d',
    storageBucket: 'spectrum-web-7435d.firebasestorage.app',
  );
}
