import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';


import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'LocalStorage.dart';

class DataSetGet {
  static List<String> images = [];


// 获取持久化路径
  static Future<String> getPersistentImagePath(String originalPath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = originalPath.split('/').last; // 获取文件名
    final String newPath = '${appDocDir.path}/$fileName';
    return newPath;
  }

// 将图片保存到持久化存储
  static Future<String> saveImageToPersistentStorage(
      String originalPath) async {
    final File originalFile = File(originalPath);
    final String newPath = await getPersistentImagePath(originalPath);
    final File persistentFile = File(newPath);

    // 如果文件在持久路径中不存在，则复制过去
    if (!await persistentFile.exists()) {
      await originalFile.copy(newPath);
    }
    return newPath; // 返回持久化路径
  }

// 加载图片的方法
  static Future<ImageProvider> getImageProvider(String bgUrl) async {
    if (bgUrl.startsWith('assets/')) {
      return AssetImage(bgUrl);
    } else {
      final String persistentPath = await getPersistentImagePath(bgUrl);
      return FileImage(File(persistentPath));
    }
  }

  static Future<Image> getImagePath(String name) async {
    print('Loading image: $name');
    if (name.startsWith('assets/')) {
      return Image.asset(
        name,
        fit: BoxFit.cover,
      );
    } else {
      try {
        final String persistentPath = await getPersistentImagePath(name);
        return Image.file(
          File(persistentPath),
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error loading image file: $e');
        throw e;
      }
    }
  }

  static Future<Image> getImagePath2(String name) async {
    if (name.startsWith('assets/')) {
      return Image.asset(
        name,
        fit: BoxFit.fill,
      );
    } else {
      try {
        final String persistentPath = await getPersistentImagePath(name);
        return Image.file(
          File(persistentPath),
          fit: BoxFit.fill,
        );
      } catch (e) {
        print('Error loading image file: $e');
        throw e;
      }
    }
  }


  static List<String> getBgImageView() {
    String? stringValue =
    LocalStorage().getValue(LocalStorage.bgImageList) as String?;
    if (stringValue != null && stringValue.isNotEmpty) {
      try {
        images = List<String>.from(json.decode(stringValue));
      } catch (e) {
        print('Error decoding images from storage: $e');
      }
    }
    return images;
  }

  static void addImageToTop(String imagePath) {
    print('Saving image path: $imagePath');
    images.insert(0, imagePath);
    saveImagesToStorage();
  }

  static void saveImagesToStorage() {
    try {
      String jsonImages = json.encode(images);
      LocalStorage().setValue(LocalStorage.bgImageList, jsonImages);
      print('Saved images to storage: $jsonImages');
    } catch (e) {
      print('Error saving images to storage: $e');
    }
  }

}