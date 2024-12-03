import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 创建一个 TextEditingController 来控制 TextField
  TextEditingController feelController = TextEditingController();

  @override
  void dispose() {
    feelController.dispose(); // 清理控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
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
                child: Stack(
                  children: [
                    // 输入框
                    TextField(
                      keyboardType: TextInputType.multiline,
                      controller: feelController,
                      maxLength: 5000,  // 设置最大字符数
                      maxLines: null,    // 允许多行输入
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing down your feelings and experiences now.',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF83B3EA),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    // 字符限制显示
                    Positioned(
                      bottom: 4,  // 设置字符限制显示的位置
                      right: 0,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: feelController,
                        builder: (context, value, child) {
                          return Text(
                            '${value.text.length}/5000',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF83B3EA),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
