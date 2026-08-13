// File generated for Unisphere application with project config 'unisphere-a2be4'.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with the Unisphere application.
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8w8WciSJ08BIoz93cRCABj05zGTdgPps',
    appId: '1:1017293831751:web:90b952df5c078e2dd77b62',
    messagingSenderId: '1017293831751',
    projectId: 'unisphere-a2be4',
    authDomain: 'unisphere-a2be4.firebaseapp.com',
    storageBucket: 'unisphere-a2be4.firebasestorage.app',
    measurementId: 'G-YMXLKCP2FN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUUyClvyAQ6duitLERtq21w1haw-6fk1Q',
    appId: '1:1017293831751:android:f66b6c9a8b851402d77b62',
    messagingSenderId: '1017293831751',
    projectId: 'unisphere-a2be4',
    storageBucket: 'unisphere-a2be4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRtiWJ740Vln0VZNEFJUFRHP4EOklghZQ',
    appId: '1:1017293831751:ios:4e5e6f3f8ba2d6d8d77b62',
    messagingSenderId: '1017293831751',
    projectId: 'unisphere-a2be4',
    storageBucket: 'unisphere-a2be4.firebasestorage.app',
    iosClientId: '1017293831751-bsff5f865lco5q4b94t53933l9gmu2sh.apps.googleusercontent.com',
    iosBundleId: 'unisphere',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBRtiWJ740Vln0VZNEFJUFRHP4EOklghZQ',
    appId: '1:1017293831751:ios:4e5e6f3f8ba2d6d8d77b62',
    messagingSenderId: '1017293831751',
    projectId: 'unisphere-a2be4',
    storageBucket: 'unisphere-a2be4.firebasestorage.app',
    iosClientId: '1017293831751-bsff5f865lco5q4b94t53933l9gmu2sh.apps.googleusercontent.com',
    iosBundleId: 'unisphere',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA8w8WciSJ08BIoz93cRCABj05zGTdgPps',
    appId: '1:1017293831751:web:90b952df5c078e2dd77b62',
    messagingSenderId: '1017293831751',
    projectId: 'unisphere-a2be4',
    authDomain: 'unisphere-a2be4.firebaseapp.com',
    storageBucket: 'unisphere-a2be4.firebasestorage.app',
    measurementId: 'G-YMXLKCP2FN',
  );
}
