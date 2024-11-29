import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:night_trips/data/RecordBean.dart';
import 'package:path_provider/path_provider.dart';

import 'cus/CustomDialog.dart';
import 'cus/RecordManager.dart';
import 'data/LocalStorage.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  int imgWeather = 0;
  int imgFeeling = 0;
  final feelController = TextEditingController();
  DateTime selectedDate = DateTime.now();

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

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await File(image.path).copy(newPath);
      DataSetGet.addImageToTop(newImage.path);
      setState(() {
        DataSetGet.getBgImageView();
      });
    }
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          onClose: () {
            print('弹框关闭');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 220),
              const Text(
                'Your diary is complete. Now is a great time to enjoy a moment of peace! Would you like to enter the sleep relaxation music?',
                style: TextStyle(
                  fontFamily: 'eb',
                  fontSize: 14,
                  color: Color(0xFF8ABBF3),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 208,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF31429D),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Center(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Later',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x99FCFFFF),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void saveData() {
    if (feelController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the feelings");
      return;
    }
    String? bgImageList =
    LocalStorage().getValue(LocalStorage.bgImageList) as String?;
    RecordBean event = RecordBean(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      information: feelController.text,
      date: (selectedDate.millisecondsSinceEpoch ~/ 1000).toString(),
      bgList: bgImageList?? '',
      weather: imgWeather,
      feeling: imgFeeling,
    );
    RecordManager.addRecord(event);
    Fluttertoast.showToast(msg: "Saved Successfully");
    // showCustomDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate;
    formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);
      return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
              padding: const EdgeInsets.only(top: 56),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/ic_back.webp'),
                          ),
                        ),
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0x80E8E8E8), width: 1),
                                ),
                                child:  Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 28),
                                  child: Row(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0x80D2D3D7),
                                        size: 16,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
                    child: Row(
                      children: [
                        Text(
                          'Record',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF59B710),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 20, right: 20),
                    child: SizedBox(
                      height: 123,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: DataUtils.imagesWeather.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                imgWeather = index;
                              });
                            },
                            child: Container(
                              width: 74,
                              margin: const EdgeInsets.only(right: 2.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imgWeather == index
                                      ? const AssetImage(
                                          'assets/images/bg_we.webp')
                                      : const AssetImage(
                                          'assets/images/bg_we_2.webp'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DataUtils.textWeather[index],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: imgWeather == index
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xCCFFFFFF),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: Image.asset(
                                        DataUtils.imagesWeather[index],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, right: 20, left: 20),
                    child: SizedBox(
                      height: 188,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_feel.webp'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: SizedBox(
                          height: 138,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              controller: feelController,
                              maxLength: 3000,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFFFFFF),
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Start writing down your feelings and experiences now.',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF83B3EA),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
                    child: Row(
                      children: [
                        Text(
                          'Record mood',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF59B710),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 0.0, left: 20, right: 20),
                    child: SizedBox(
                      height: 100, // 设置固定高度
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: DataUtils.imagesFeeling.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                imgFeeling = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                      imgFeeling == index
                                          ? DataUtils.imagesFeeling[index]
                                          : DataUtils.imagesFeeling2[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DataUtils.textFeeling[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: imgFeeling == index
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0x99FCFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
                    child: Row(
                      children: [
                        Text(
                          'Capture moments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF59B710),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Add pictures to capture moments and preserve beautiful memories.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0x99FCFFFF),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24.0, left: 20, right: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            pickImage();
                          },
                          child: SizedBox(
                            width: 100,
                            height: 130,
                            child: Image.asset(
                              'assets/images/ic_add.webp',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 103,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: DataSetGet.getBgImageView().length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 15.0),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Center(
                                          child: CustomCircle(
                                            img: DataSetGet.getBgImageView()[
                                                index],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                DataSetGet.getBgImageView()
                                                    .removeAt(index);
                                                DataSetGet
                                                    .saveImagesToStorage();
                                              });
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Image.asset(
                                                'assets/images/ic_delete.webp',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () {
                        saveData();
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
                            'Finish',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      // 初始日期为明天
      firstDate: DateTime.now().add(const Duration(days: 1)),
      // 最早日期为明天
      lastDate: DateTime(2100),
      // 设置一个合理的未来日期
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // 主色
              onPrimary: Colors.white, // 文字颜色
              onSurface: Colors.black, // 表面颜色
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // 按钮文字颜色
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        print("pickedDate=====$pickedDate");
      });
    }
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
