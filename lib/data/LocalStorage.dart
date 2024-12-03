import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static String dateList = "dateListjson";
  static String bgImageList = "bgImageList";
  static String muIndex = "muIndex";
  static String bgIndex = "bgIndex";
  static String djsTime = "djsTime";

  static String volumeData = "volumeData";

  static final LocalStorage _instance = LocalStorage._internal();
  late SharedPreferences _prefs;
  static String clickFeelId = "";

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set value by key
  Future<void> setValue(String key, dynamic value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  // Get value by key
  dynamic getValue(String key) {
    return _prefs.get(key);
  }

   Future<int> getMuIndex() async {
    return _prefs.getInt(muIndex) ?? 0;
  }
  Future<void> setMuIndex(int index) async {
    await _prefs.setInt(muIndex, index);
  }

  Future<int> getBgIndex() async {
    return _prefs.getInt(bgIndex) ?? 0;
  }
  Future<void> setBgIndex(int index) async {
    await _prefs.setInt(bgIndex, index);
  }

  Future<int> getDjsTime() async {
    return _prefs.getInt(djsTime) ?? 0;
  }
  Future<void> setDjsTime(int index) async {
    await _prefs.setInt(djsTime, index);
  }

  Future<double> getVolumeTime() async {
    return _prefs.getDouble(volumeData) ?? 0.0;
  }
  Future<void> setVolumeTime(double index) async {
    await _prefs.setDouble(volumeData, index);
  }
}
