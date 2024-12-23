import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';


import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../showint/ShowAdFun.dart';
import 'LocalStorage.dart';

class DataSetGet {
  static List<String> images = [];

  // static ShowAdFun getMobUtils(BuildContext context) {
  //   final adManager = ShowAdFun(context);
  //   return adManager;
  // }
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


  //
  // static Future<void> showScanAd(
  //     BuildContext context,
  //     AdWhere adPosition,
  //     int moreTime,
  //     Function() loadingFun,
  //     Function() nextFun,
  //     ) async {
  //   final Completer<void> completer = Completer<void>();
  //   var isCancelled = false;
  //
  //   void cancel() {
  //     isCancelled = true;
  //     completer.complete();
  //   }
  //
  //   Future<void> _checkAndShowAd() async {
  //     bool colckState = await ShowAdFun.blacklistBlocking();
  //     if (colckState) {
  //       nextFun();
  //       return;
  //     }
  //
  //     // 判断广告是否可以展示
  //     if (!getMobUtils(context).canShowAd(adPosition)) {
  //       // 加载广告
  //       getMobUtils(context).loadAd(adPosition);
  //     }
  //
  //     // 等待广告加载完成
  //     if (getMobUtils(context).canShowAd(adPosition)) {
  //       loadingFun();
  //       getMobUtils(context).showAd(context, adPosition, () {
  //         // 广告展示后，确保广告数据被清理
  //         getMobUtils(context).clearAdCache(adPosition);  // 清理广告缓存
  //         getMobUtils(context).loadAd(adPosition);  // 重新加载广告
  //         nextFun();
  //       });
  //       return;
  //     }
  //
  //     // 如果广告未加载成功，重新检查
  //     if (!isCancelled) {
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       await _checkAndShowAd();
  //     }
  //   }
  //
  //   // 超过指定时间取消广告展示
  //   Future.delayed(Duration(seconds: moreTime), cancel);
  //   await Future.any([
  //     _checkAndShowAd(),
  //     completer.future,
  //   ]);
  //
  //   if (!completer.isCompleted) {
  //     return;
  //   }
  //   print("插屏广告展示超时");
  //   nextFun();
  // }

}