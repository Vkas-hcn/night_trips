import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:night_trips/showint/LTFDW.dart';
import 'package:night_trips/showint/ShowAdFun.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import 'MainApp.dart';
import 'data/LocalStorage.dart';

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
  late LTFDW Ltfdw;
  final _ump = UserMessagingPlatform.instance;
  final String _testDeviceId = "F8F8F8A6A1ECD38483E6997F3C5220BB";
  late StreamSubscription _umpStateSubscription;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    requestConsentInfoUpdate();
    Ltfdw = LTFDW(
      onAppResumed: _handleAppResumed,
      onAppPaused: _handleAppPaused,
    );
    WidgetsBinding.instance.addObserver(Ltfdw);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
  }

  void _handleAppResumed() {
    LocalStorage.isInBack = false;
    if (_pausedTime != null) {
      final timeInBackground =
          DateTime.now().difference(_pausedTime!).inSeconds;
      if (LocalStorage.clone_ad == true) {
        return;
      }
      if (timeInBackground > 3 && LocalStorage.int_ad_show == false) {
        restartState = true;
        restartApp();
      }
    }
  }

  void _handleAppPaused() {
    LocalStorage.isInBack = true;
    LocalStorage.clone_ad = false;
    _pausedTime = DateTime.now();
  }

  void loadingGuideAd() {
    DataSetGet.getMobUtils(context).loadAd(AdWhere.OPEN);
    Future.delayed(const Duration(seconds: 2), () {
      DataSetGet.getMobUtils(context).loadAd(AdWhere.BACKINT);
      DataSetGet.getMobUtils(context).loadAd(AdWhere.SAVE);
      showOpenAd();
    });
  }

  void _startMonitoringUmpState() {
    _umpStateSubscription = Stream.periodic(checkInterval).listen((_) async {
      bool umpState =
          await LocalStorage().getValue(LocalStorage.umpState) ?? false;
      if (umpState) {
        _umpStateSubscription.cancel();
        _startProgress();
        loadingGuideAd();
      }
    });
  }

  Future<void> requestConsentInfoUpdate() async {
    bool? data = await LocalStorage().getValue(LocalStorage.umpState);
    print("requestConsentInfoUpdate---${data}");
    if (data == true) {
      loadingGuideAd();
      return;
    }
    _startMonitoringUmpState();

    int retryCount = 0;
    const maxRetries = 1;

    while (retryCount <= maxRetries) {
      try {
        final info = await _ump
            .requestConsentInfoUpdate(_buildConsentRequestParameters());
        print("requestConsentInfoUpdate---->${info.consentStatus}");
        if (info.consentStatus == ConsentStatus.required) {
          showConsentForm();
        } else {
          LocalStorage().setValue(LocalStorage.umpState, true);
        }
        break;
      } catch (e) {
        if (e is PlatformException && e.code == 'timeout') {
          retryCount++;
          if (retryCount > maxRetries) {
            LocalStorage().setValue(LocalStorage.umpState, true);
            return;
          }
          print("Request timed out, retrying... ($retryCount/$maxRetries)");
          await Future.delayed(Duration(seconds: 1));
        } else {
          LocalStorage().setValue(LocalStorage.umpState, true);
          return;
        }
      }
    }
  }

  ConsentRequestParameters _buildConsentRequestParameters() {
    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      debugSettings: ConsentDebugSettings(
        geography: DebugGeography.EEA,
        testDeviceIds: [_testDeviceId],
      ),
    );
    return parameters;
  }

  Future<void> showConsentForm() {
    return _ump.showConsentForm().then((info) {
      print("showConsentForm---->${info.consentStatus}");
      LocalStorage().setValue(LocalStorage.umpState, true);
    });
  }

  void showOpenAd() async {
    int elapsed = 0;
    const int timeout = 12000;
    const int interval = 500;
    print("准备展示open广告");
    Timer.periodic(const Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      if (DataSetGet.getMobUtils(context).canShowAd(AdWhere.OPEN)) {
        DataSetGet.getMobUtils(context).showAd(context, AdWhere.OPEN, () {
          print("关闭广告-------");
          pageToHome();
        });
        timer.cancel();
      } else if (elapsed >= timeout) {
        print("超时，直接进入首页");
        pageToHome();
        timer.cancel();
      }
    });
  }

  void restartApp() {
    LocalStorage.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Guide()),
      (route) => false,
    );
  }

  void _startProgress() {
    _timerProgress?.cancel();
    const int totalDuration = 12000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;
    int currentUpdate = 0;
    _progress = 0.0;
    _timerProgress =
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      if (mounted) {
        setState(() {
          _progress = (currentUpdate + 1) / totalUpdates;
        });
      }
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
      }
    });
  }

  void pageToHome() {
    print("pageToHome-----------");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => (MainApp())),
        (route) => route == null);
  }

  @override
  void dispose() {
    super.dispose();
    _timerProgress?.cancel();
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
                child: Padding(
                  padding: EdgeInsets.only(left: 32, right: 32, top: 150),
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
                        padding: const EdgeInsets.only(
                            bottom: 80, right: 70, left: 70),
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
