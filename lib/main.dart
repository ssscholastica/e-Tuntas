import 'package:etuntas/home.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:etuntas/pendaftaran.dart';
import 'package:etuntas/profile.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Profile(),
    );
  }
}
