import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:bill_generator/main.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Fast fade duration
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showSplash = false;
          });
        }
      });

    // Keep splash for 2 seconds before fading
    Timer(const Duration(milliseconds: 2000), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainScreen(), // Your actual app
        if (_showSplash)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/MOBIBILL1.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
