import 'package:flutter/material.dart';

import 'Guide.dart';
import 'data/LocalStorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    print("object=================main");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageToHome();
    });
  }


  void pageToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Guide()),
        (route) => route == null);
  }

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
        ),
      ),
    );
  }
}
