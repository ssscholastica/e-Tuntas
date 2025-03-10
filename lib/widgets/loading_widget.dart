import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;

  const LoadingWidget({Key? key, required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading)
      return const SizedBox.shrink(); // Jika tidak loading, tidak tampil

    return AnimatedOpacity(
      opacity: isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withOpacity(0.4), // Layar redup
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F2F9D)), // Warna loading
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
