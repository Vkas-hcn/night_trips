import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:night_trips/DetailPage.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:night_trips/data/RecordBean.dart';
import 'package:night_trips/sleep/SleepPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddPage.dart';
import 'RecordPage.dart';
import 'cus/RecordManager.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool qrLoading = false;
  bool createDialog = false;

  @override
  void initState() {
    super.initState();
    getListData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getListData() async {
    await RecordManager.loadRecords();
    setState(() {});
  }

  void backRefFun(int index) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailPage(recordBean: RecordManager.events[index]),
      ),
    ).then((value) {
      getListData();
    });
  }

  void goRecordPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordPage(),
      ),
    ).then((value) {
      getListData();
    });
  }

  void goAddPage()  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPage(),
      ),
    );
  }

  void goSleepPage()  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SleepPage(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        endDrawer: Drawer(
          width: 233,
          child: Container(
            color: const Color(0xFF040A25),
            child: ListView(
              padding: const EdgeInsets.only(right: 40),
              children: <Widget>[
                const SizedBox(height: 100),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset('assets/images/logo.jpg'),
                  ),
                ),
                const SizedBox(height: 40),
                ListTile(
                  contentPadding: const EdgeInsets.only(right: 0),
                  title: const Text('Post a Comment',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'eb',
                        color: Colors.white,
                        fontSize: 12,
                      )),
                  onTap: () {
                    _launchURL();
                  },
                ),
                const SizedBox(height: 40),
                ListTile(
                  contentPadding: const EdgeInsets.only(right: 0),
                  title: const Text('Share with Friends',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'eb',
                        color: Colors.white,
                        fontSize: 12,
                      )),
                  onTap: () {
                    _launchURL();
                  },
                ),
                const SizedBox(height: 40),
                ListTile(
                  contentPadding: const EdgeInsets.only(right: 0),
                  title: const Text('Privacy Policy',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'eb',
                        color: Colors.white,
                        fontSize: 12,
                      )),
                  onTap: () {
                    _launchURL();
                  },
                ),
              ],
            ),
          ),
        ),
        body: _buildMainApp(context),
      ),
    );
  }

  Widget _buildMainApp(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_main.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("App Name",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFFFFFFF),
                            )),
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: Image.asset(
                                    'assets/images/ic_setting.webp'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  const Text(
                    'WE GOT TRIPS FOR THE TRIPPSTER IN YOU',
                    style: TextStyle(
                      fontFamily: 'eb',
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        goAddPage();
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_sw.webp'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20),
                          child: Center(
                            child: Text(
                              'Start writing down your feelings and experiences now.',
                              style: TextStyle(
                                fontFamily: 'eb',
                                fontSize: 12,
                                color: Color(0xFF8ABBF3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        goSleepPage();
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_sleep.webp'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF59B710),
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.0, vertical: 5),
                                          child: Text(
                                            'Sleep relaxation',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Relax your body and mind, let music help you sleep, and enjoy every dream.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Record',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF59B710),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            goRecordPage();
                          },
                          child: const Text(
                            'more >',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7CC0FD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if(RecordManager.events.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: RecordManager.events.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              backRefFun(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/bg_record.webp'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF038DDB),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15.0,
                                                          vertical: 5),
                                                      child: Text(
                                                        DataUtils.textWeather[
                                                            RecordManager
                                                                .events[index]
                                                                .weather],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF59B710),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15.0,
                                                          vertical: 5),
                                                      child: Text(
                                                        DataUtils.textFeeling[
                                                            RecordManager
                                                                .events[index]
                                                                .feeling],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  RecordManager.events[index]
                                                      .information,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFFFFFFF),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Spacer(),
                                              Text(
                                                RecordBean.getTimeFromTimestamp(
                                                    RecordManager
                                                        .events[index].date),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFACB1C6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if(RecordManager.events.isEmpty)
                  Column(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Image.asset('assets/images/ic_emp_data.webp'),
                      ),
                      const Text(
                        'There are no diary entries recorded here yet. Start recording now!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: GestureDetector(
                          onTap: () {
                            goAddPage();
                          },
                          child: Container(
                            width: 243,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF31429D),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: const Center(
                              child: Text(
                                'GO',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  _launchURL() async {
    //TODO: Replace with your own url
    const url = 'https://flutterchina.club/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showToast('Cant open web page $url');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
