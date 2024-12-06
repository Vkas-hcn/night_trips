import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_trips/AddPage.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:night_trips/data/RecordBean.dart';
import 'package:night_trips/showint/AdShowui.dart';
import 'package:night_trips/showint/ShowAdFun.dart';

import 'cus/ImageDialog.dart';

class DetailPage extends StatefulWidget {
  final RecordBean recordBean;

  const DetailPage({super.key, required this.recordBean});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int indexBg = 0;
  bool showImage = false;
  List<String> bgImageList = [];
  final feelController = TextEditingController();
  late RecordBean _currentRecordBean;
  late ShowAdFun adManager;
  final AdShowui _loadingOverlay = AdShowui();

  @override
  void initState() {
    super.initState();
    adManager = DataSetGet.getMobUtils(context);
    feelController.addListener(showWeightController);
    _currentRecordBean = widget.recordBean; // 初始化新变量
    setState(() {
      bgImageList = List<String>.from(json.decode(_currentRecordBean.bgList));
    });
  }

  void showWeightController() async {
    feelController.text.trim();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void backRefFun() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPage(recordBean: _currentRecordBean),
      ),
    );

    // 检查返回值是否有效，并且确保类型为 RecordBean
    if (result != null && result is RecordBean) {
      print("object-result: ${result.information}");

      setState(() {
        _currentRecordBean = result; // 更新 _currentRecordBean
        bgImageList = List<String>.from(
            json.decode(_currentRecordBean.bgList)); // 更新背景图片列表
      });
    } else {
      print("Result is not of type RecordBean or is null");
    }
  }

  void showImageDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageDialog(
          img: bgImageList[index],
          onClose: () {},
        );
      },
    );
  }

  void showLoading() {
    setState(() {
      _loadingOverlay.show(context);
    });
  }

  void hideLoading() {
    setState(() {
      _loadingOverlay.hide();
    });
  }

  void showAdNextPaper(AdWhere adWhere, Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    DataSetGet.showScanAd(context, adWhere, 5, () {
      setState(() {
        _loadingOverlay.hide();
      });
    }, () {
      setState(() {
        _loadingOverlay.hide();
      });
      nextJump();
    });
  }

  void nextJump() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showAdNextPaper(AdWhere.BACKINT, () {
          nextJump();
        });
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_main.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 56, right: 20, left: 20, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showAdNextPaper(AdWhere.BACKINT, () {
                            nextJump();
                          });
                        },
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset('assets/images/ic_back.webp'),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          backRefFun();
                        },
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset('assets/images/ic_edit.webp'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Image.asset(DataUtils
                            .imagesFeeling[_currentRecordBean.feeling]),
                      ),
                      SizedBox(
                        width: 202,
                        height: 42,
                        child: Image.asset('assets/images/bg_feel_b.webp'),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 531,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg_detail.webp'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20),
                      child: Column(
                        children: [
                          // Scrollable Text area
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              child: Text(
                                _currentRecordBean.information,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontFamily: 'eb',
                                  fontSize: 12,
                                  color: Color(0xFF8ABBF3),
                                ),
                              ),
                            ),
                          ),
                          // Horizontal Image List
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 103,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: bgImageList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      showImageDialog(context, index);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: Center(
                                        child: CustomCircle(
                                          img: bgImageList[index],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                textAlign: TextAlign.start,
                                "${RecordBean.getTimeFromTimestamp(_currentRecordBean.date)} ${DataUtils.textFeeling[_currentRecordBean.feeling]}",
                                style: const TextStyle(
                                  fontFamily: 'eb',
                                  fontSize: 14,
                                  color: Color(0xFFACB1C6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircle extends StatelessWidget {
  final String img;

  const CustomCircle({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 103,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            height: 130,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Image>(
                future: DataSetGet.getImagePath(img),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
