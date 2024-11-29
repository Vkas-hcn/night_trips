import 'dart:convert';

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

  // 从本地存储读取并解析成List<RecordBean>
  static Future<void> loadRecords2() async {
    // 从本地存储读取 JSON 字符串
    String? jsonString = await LocalStorage().getValue(LocalStorage.dateList);
    if (jsonString != null) {
      // 将 JSON 字符串解析为 List<Map<String, dynamic>>
      List<dynamic> jsonData = json.decode(jsonString);
      print("jsonString---->${jsonString}");
      //根据重复模式修改数据

      // 将每个 JSON 对象解析为 RecordBean 实例，并添加到 events 数组
      events = jsonData.map((e) => RecordBean.fromJson(e)).toList();
    }
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
  static void updateRecord(RecordBean updatedRecord) {
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
}
