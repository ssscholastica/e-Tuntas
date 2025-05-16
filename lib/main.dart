import 'package:etuntas/home.dart';
import 'package:etuntas/login-signup/resetPasswordScreen.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
