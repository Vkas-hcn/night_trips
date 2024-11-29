import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:path_provider/path_provider.dart';

import 'cus/CustomDialog.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int indexBg = 0;
  bool showImage = false;

  final feelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    feelController.addListener(showWeightController);
  }

  void showWeightController() async {
    feelController.text.trim();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
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
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Image.asset('assets/images/ic_back.webp'),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/ic_edit.webp'),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(DataUtils.imagesFeeling[1]),
                          ),
                          SizedBox(
                            width: 202,
                            height: 42,
                            child: Image.asset('assets/images/bg_feel_b.webp'),
                          )
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
                              const Text(
                                textAlign: TextAlign.start,
                                'Start writing down your feelings and experiences now.Start writing down your feelings and experiences now.Start writing down your feelings and experiences now.Start writing down your feelings and experiences now.Start writing down your feelings and experiences now.Start writing down your feelings and experiences now.',
                                style: TextStyle(
                                  fontFamily: 'eb',
                                  fontSize: 12,
                                  color: Color(0xFF8ABBF3),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 103,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        DataSetGet.getBgImageView().length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            indexBg = index;
                                            showImage = true;
                                          });
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Center(
                                            child: CustomCircle(
                                              img: DataSetGet.getBgImageView()[
                                                  index],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    textAlign: TextAlign.start,
                                    '2024-11-07  Sun',
                                    style: TextStyle(
                                      fontFamily: 'eb',
                                      fontSize: 14,
                                      color: Color(0xFFACB1C6),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24)
                    ],
                  ),
                ),
              ),
            ),
            //全屏图片
            if (showImage)
              GestureDetector(
                  onTap: () {
                    setState(() {
                      showImage = false;
                    });
                  },
                  child: Center(
                    child: Container(
                        width: 327,
                        height: 562,
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          image: DecorationImage(
                            image: AssetImage(
                                DataSetGet.getBgImageView()[indexBg]),
                            fit: BoxFit.fill,
                          ),
                        )),
                  ))
          ],
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
