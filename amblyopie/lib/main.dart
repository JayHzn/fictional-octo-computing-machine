import 'package:amblyopie/firebase_options.dart';
import 'package:amblyopie/pages/auth/login_page.dart';
import 'package:amblyopie/pages/auth/register_page.dart';
import 'package:amblyopie/pages/onboarding/onboarding_page.dart';
import 'package:amblyopie/pages/profile/create_profile_page.dart';
import 'package:amblyopie/pages/home/home_shell.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notif = message.notification;
  if (notif != null) {
    await _showLocal(
      title: notif.title ?? 'Notification',
      body: notif.body ?? '',
    );
  }

  print('Message reçu en arrière-plan: ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> _showLocal({
  required String title,
  required String body,
}) async {
  if (kIsWeb) return;

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'amblyopie_channel',
      'Amblyopie',
      channelDescription: 'Rappels et notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    details,
  );
}

Future<void> _initLocalNotifications() async {
  if (kIsWeb) return;

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/home', (route) => false);
    },
  );

  final android = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      'amblyopie_channel', // id
      'Amblyopie',
      description: 'Rappels et notifications', // title
      importance: Importance.high,
    ),
  );

  await android?.requestNotificationsPermission();
}

Future<void> safeInitFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if (kIsWeb) {
      print('Firebase Messaging non configuré sur le web');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final token = await messaging.getToken();
    print('Firebase Messaging Token: $token');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notif = message.notification;
      if (notif != null) {
        await _showLocal(
          title: notif.title ?? 'Notification',
          body: notif.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
    });

  } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        Firebase.app();
      } else {
        rethrow;
      }
    }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initLocalNotifications();
  await safeInitFirebase();
  await initializeDateFormatting('fr_FR', null);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  runApp(MyApp(initialMessage: initialMessage));

  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }
}

class MyApp extends StatelessWidget {
  final RemoteMessage? initialMessage;

  const MyApp({super.key, this.initialMessage});

  final peach = const Color(0xFFFBE1C5);
  final orange = const Color(0xFFF58F5D);
  final blue = const Color(0xFF8FB4E3);
  final ink = const Color(0xFF2F2A24);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          background: peach,
          surface: Colors.white,
          primary: orange,
          secondary: blue,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: ink,
          onSurface: ink.withOpacity(0.9),
        ),
        scaffoldBackgroundColor: peach,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(height: 1.25),
        ),
      ),
      title: 'Amblyopie',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeShell(),
        '/createProfile' : (context) => CreateProfilePage(),
      },
      initialRoute: 
        initialMessage != null ? '/home' : '/onboarding',
    );
  }
}
