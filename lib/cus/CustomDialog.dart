import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;

  const CustomDialog({
    Key? key,
    required this.child,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 407,
        padding: const EdgeInsets.only(top: 12,left: 16,right: 16,bottom: 20), // 内边距
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/bg_dialog.webp'),
            fit: BoxFit.fill,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            child,
            Positioned(
              right: 0,
              child: Row(
                children: [
                  const Text(
                    'Ready to relax?',
                    style: TextStyle(
                      fontFamily: 'eb',
                      fontSize: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    onPressed: () {
                      if (onClose != null) {
                        onClose!(); // 触发关闭回调
                      }
                      Navigator.of(context).pop(); // 关闭弹框
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
