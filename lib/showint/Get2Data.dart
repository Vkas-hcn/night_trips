import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../data/LocalStorage.dart';

class Get2Data with ChangeNotifier {
  static const String BLACK_URL =
      "https://belt.bedtimediary.com/pessimal/pilewort";
  static String fqaId = "";

  static String getUUID() {
    var uuid = Uuid();
    return uuid.v4();
  }

  static void initializeFqaId() {
    if (fqaId.isEmpty) {
      fqaId = getUUID();
    }
  }

  Future<void> getBlackList(BuildContext context) async {
    String? data = LocalStorage().getValue(LocalStorage.clockData);
    print("Blacklist data=${data}");

    if (data != null) {
      return;
    }
    final mapData = await cloakMapData(context);
    try {
      final response = await postMapData(BLACK_URL, mapData);
      LocalStorage().setValue(LocalStorage.clockData, response);
      notifyListeners();
    } catch (error) {
      retry(context);
    }
  }

  Future<Map<String, dynamic>> cloakMapData(BuildContext context) async {
    return {
      "repartee": "com.diary.bedtime.serenity",
      "kindred": "varsity",
      "gorky": await getAppVersion(context),
      "ski": DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<String> getAppVersion(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> postMapData(String url, Map<String, dynamic> map) async {
    print("开始请求---${map}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        print("请求结果：${response.body}");
        return response.body;
      } else {
        print("请求出错：HTTP error: ${response.statusCode}");
        throw HttpException('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print("请求异常：$e");
      throw e;
    }
  }

  void retry(BuildContext context) async {
    await Future.delayed(Duration(seconds: 10));
    await getBlackList(context);
  }
}

