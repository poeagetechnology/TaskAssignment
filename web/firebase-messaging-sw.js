/* eslint-disable no-undef */
// Keep in sync with lib/firebase_options.dart (web). Regenerate via `flutterfire configure`.
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB6DP4553YDcC9WltEIyfP1fT03ITbZgQU',
  appId: '1:938624740251:web:placeholder_id',
  projectId: 'sago-builders',
  messagingSenderId: '938624740251',
  storageBucket: 'sago-builders.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js]', payload);
});
