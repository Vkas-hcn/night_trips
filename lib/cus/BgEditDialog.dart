import 'package:flutter/material.dart';


class BgEditDialog extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;

  const BgEditDialog({
    Key? key,
    required this.child,
    this.onClose,
  }) : super(key: key);

  @override
  _BgEditDialogState createState() => _BgEditDialogState();
}

class _BgEditDialogState extends State<BgEditDialog> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF02223B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: 0,
            child: Row(
              children: [
                const Text(
                  'Background',
                  style: TextStyle(
                    fontFamily: 'eb',
                    fontSize: 18,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(width: 100),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  onPressed: () {
                    if (widget.onClose != null) {
                      widget.onClose!(); // 触发关闭回调
                    }
                    Navigator.of(context).pop(); // 关闭弹框
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

