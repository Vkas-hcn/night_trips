import 'package:flutter/material.dart';
import 'cus/CustomDialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('自定义弹框示例')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // 显示自定义弹框
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
                        Text(
                          '这里是弹框内容',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('关闭弹框'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text('显示弹框'),
          ),
        ),
      ),
    );
  }
}
