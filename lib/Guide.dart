import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'MainApp.dart';

class Guide extends StatelessWidget {
  const Guide({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timerProgress;
  bool restartState = false;
  final Duration checkInterval = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
  }

  void _startProgress() {
    const int totalDuration = 2000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;
    int currentUpdate = 0;
    _progress = 0.0;
    _timerProgress =
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
        pageToHome();
      }
    });
  }

  void pageToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => (MainApp())),
        (route) => route == null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startProgress() {}

  void stopProgress() {}

  void resetProgress() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_guide.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
               Center(
                child:  Padding(
                  padding: EdgeInsets.only(left:32,right:32,top: 150),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Night Trips',
                        style: TextStyle(
                          fontFamily: 'ab',
                          fontSize: 48,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'WE GOT TRIPS FOR THE TRIPPSTER IN YOU',
                        style: TextStyle(
                          fontFamily: 'ab',
                          fontSize: 10,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Relax your body and mind, let music help you sleep, and enjoy every dream.',
                        style: TextStyle(
                          fontFamily: 'ab',
                          fontSize: 13,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 74),

                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 80, right: 70, left: 70),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProgressBar(
                                progress: _progress,
                                // Set initial progress here
                                height: 6,
                                borderRadius: 3,
                                backgroundColor: Color(0x54FFFFFF),
                                progressColor: Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBar({
    required this.progress,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
