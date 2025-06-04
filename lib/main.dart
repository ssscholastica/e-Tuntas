  import 'package:etuntas/login-signup/resetPasswordScreen.dart';
  import 'package:etuntas/network/globals.dart';
  import 'package:etuntas/splashScreen.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:uni_links/uni_links.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:http/http.dart' as http;

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MyApp());
  }

  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    @override
    void initState() {
      super.initState();
      initUniLinks();
      _initFCM(); 
    }

    void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Minta izin notifikasi (khusus iOS, Android akan auto granted)
    await messaging.requestPermission();

    // Ambil device token
    String? token = await messaging.getToken();
    debugPrint("FCM Device Token: $token");

    // Kirim ke server Laravel (jika token tersedia)
    if (token != null) {
      final headers = await getHeaders();
      var response = await http.post(
        Uri.parse(
            '${baseURL}save-token'), // ganti dengan URL server kamu
        headers: headers,
        body: {
          'device_token': token,
        },
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

    Future<void> initUniLinks() async {
      try {
        final initialLink = await getInitialLink();
        if (initialLink != null) {
          handleDeepLink(initialLink);
        }
      } catch (e) {
        debugPrint('Error handling initial link: $e');
      }

      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          handleDeepLink(uri.toString());
        }
      }, onError: (err) {
        debugPrint('Error handling link stream: $err');
      });
    }

    void handleDeepLink(String link) {
      if (link.startsWith('etuntas://reset-password')) {
        final uri = Uri.parse(link);
        final token = uri.queryParameters['token'];
        final email = uri.queryParameters['email'];

        if (token != null && email != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ResetPassword(token: token, email: email),
            ),
          );
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.dmSansTextTheme(),
        ),
        home: const SplashScreen(),
      );
    }
  }
