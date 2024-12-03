import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:night_trips/data/DataUtils.dart';
import 'package:night_trips/data/RecordBean.dart';

import '../data/LocalStorage.dart';

class RecordManager {
  static List<RecordBean> events = [];

  // 添加一个Record到数组
  static void addRecord(RecordBean event) {
    events.insert(0, event); // 添加到数组的第一位
    saveRecords(); // 保存到本地存储
  }

  // 保存整个事件数组到本地存储
  static Future<void> saveRecords() async {
    // 将 events 转换成 JSON 字符串
    String jsonString = json.encode(events.map((e) => e.toJson()).toList());
    await LocalStorage().setValue(LocalStorage.dateList, jsonString);
  }

  static Future<void> loadRecords() async {
    // Load JSON string from local storage
    String? jsonString = await LocalStorage().getValue(LocalStorage.dateList);
    if (jsonString != null) {
      List<dynamic> jsonData = json.decode(jsonString);
      print("jsonString---->$jsonString");

      // Parse each JSON object as RecordBean and adjust dates based on repeat
      events = jsonData.map((e) {
        RecordBean event = RecordBean.fromJson(e);
        //
        // // Update the date if the event is repeating and the date has passed
        // event.adjustDateIfRepeating();
        return event;
      }).toList();
    }
  }

  //获取到指定的Record
  static RecordBean? getRecordById(String eventId) {
    final foundRecords = events.where((event) => event.id == eventId).toList();
    if (foundRecords.isNotEmpty) {
      return foundRecords.first;
    } else {
      return null;
    }
  }

  // 更新指定ID的Record
  static Future<void> updateRecord(RecordBean updatedRecord) async {
    int index = events.indexWhere((event) => event.id == updatedRecord.id);
    if (index != -1) {
      events[index] = updatedRecord; // 更新事件
      saveRecords(); // 保存更改后的事件数组
    }
  }

  // 删除指定ID的Record
  static void deleteRecord(String eventId) {
    events.removeWhere((event) => event.id == eventId);
    saveRecords(); // 保存更改后的事件数组
  }

  // 获取情绪统计数据
  static Map<String, int> getFeelingStatistics() {
    Map<String, int> statistics = {
      'Total': events.length, // 添加总数统计
      for (var feeling in DataUtils.textFeeling) feeling: 0
    };

    for (var event in events) {
      if (event.feeling >= 0 && event.feeling < DataUtils.textFeeling.length) {
        String feelingText = DataUtils.textFeeling[event.feeling];
        statistics[feelingText] = (statistics[feelingText] ?? 0) + 1;
      }
    }

    return statistics;
  }

  static List<RecordBean> getRecordsByFeeling(String feeling) {
    if (feeling == "Total") {
      return List.from(events);
    }
    int feelingIndex = DataUtils.textFeeling.indexOf(feeling);
    if (feelingIndex == -1) {
      throw ArgumentError('Invalid feeling: $feeling');
    }

    // 筛选出对应心情的记录列表
    return events.where((event) => event.feeling == feelingIndex).toList();
  }

  static bool isFirstRecordOfDay() {
    // 获取今天的日期
    DateTime today = DateTime.now();
    String todayStr = DateFormat('yyyy-MM-dd').format(today);
    // 查找是否已有任何记录是今天添加的
    bool isFirst = !events.any((event) {
      DateTime eventDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(event.date) * 1000);
      print("todayStr===${todayStr}=====${DateFormat('yyyy-MM-dd').format(eventDate)}");
      return DateFormat('yyyy-MM-dd').format(eventDate) == todayStr;
    });

    return isFirst;
  }
}
