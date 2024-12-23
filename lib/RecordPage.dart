import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:night_trips/DetailPage.dart';
import 'package:night_trips/MainApp.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:night_trips/data/RecordBean.dart';
import 'package:night_trips/showint/AdShowui.dart';
import 'package:night_trips/showint/ShowAdFun.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddPage.dart';
import 'cus/RecordManager.dart';
import 'data/DataSetGet.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  bool qrLoading = false;
  bool createDialog = false;
  int imgFeelState = 0;

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
    getStatistics();
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

  void goAddPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddPage(),
        ),
      );
  }

  void getStatistics() async {
    // 加载记录
    await RecordManager.loadRecords();

    // 获取情绪统计数据
    Map<String, int> statistics = RecordManager.getFeelingStatistics();

    // 打印统计结果
    statistics.forEach((feeling, count) {
      print('$feeling: $count');
    });
  }


  void nextJump() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
          nextJump();
        return false;
      },
      child: Scaffold(
        body: _buildRecordPage(context),
      ),
    );
  }

  Widget _buildRecordPage(BuildContext context) {
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: GestureDetector(
                          onTap: () {
                              nextJump();
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/ic_back.webp'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'record',
                        style: TextStyle(
                          fontFamily: 'eb',
                          fontSize: 16,
                          color: Color(0xFFFFFFFF),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 20, right: 20),
                    child: SizedBox(
                      height: 250,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 每行显示3个项目
                          mainAxisSpacing: 1.0, // 主轴间距
                          crossAxisSpacing: 1.0, // 交叉轴间距
                        ),
                        itemCount: RecordManager.getFeelingStatistics().length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                imgFeelState = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imgFeelState == index
                                      ? const AssetImage(
                                          'assets/images/bg_to_1.webp')
                                      : const AssetImage(
                                          'assets/images/bg_to_2.webp'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      RecordManager.getFeelingStatistics()
                                          .keys
                                          .elementAt(index),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: imgFeelState == index
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xCCFFFFFF),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      RecordManager.getFeelingStatistics()
                                          .values
                                          .elementAt(index)
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (RecordManager.getRecordsByFeeling(
                          DataUtils.textFeelingRecord[imgFeelState])
                      .isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: RecordManager.getRecordsByFeeling(
                                  DataUtils.textFeelingRecord[imgFeelState])
                              .length,
                          itemBuilder: (context, index) {
                            final record = RecordManager.getRecordsByFeeling(
                                DataUtils
                                    .textFeelingRecord[imgFeelState])[index];
                            return Dismissible(
                              key: Key(record.id.toString()),
                              // 唯一标识符
                              direction: DismissDirection.endToStart,
                              // 从右向左滑动
                              secondaryBackground: Container(
                                color: Color(0x00000000),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: SizedBox(
                                  width: 60,
                                  height: 100,
                                  child: Image.asset(
                                      'assets/images/bg_delete.webp'),
                                ),
                              ),
                              background: Container(
                                color: Colors.transparent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: SizedBox(
                                  width: 60,
                                  height: 100,
                                  child: Image.asset(
                                      'assets/images/bg_delete.webp'),
                                ),
                              ),
                              onDismissed: (direction) {
                                // 删除记录并刷新列表
                                RecordManager.deleteRecord(record.id);
                                setState(() {});
                              },
                              confirmDismiss: (direction) async {
                                // 可以在这里添加确认对话框
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm deletion"),
                                      content: const Text(
                                          "Are you sure you want to delete this record?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: GestureDetector(
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFF038DDB),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical: 5),
                                                          child: Text(
                                                            DataUtils
                                                                    .textWeather[
                                                                record.weather],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFFFFFFFF),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFF59B710),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical: 5),
                                                          child: Text(
                                                            DataUtils
                                                                    .textFeeling[
                                                                record.feeling],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFFFFFFFF),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      record.information,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFFFFFFFF),
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
                                                    RecordBean
                                                        .getTimeFromTimestamp(
                                                            record.date),
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
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (RecordManager.getRecordsByFeeling(
                          DataUtils.textFeelingRecord[imgFeelState])
                      .isEmpty)
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
}
