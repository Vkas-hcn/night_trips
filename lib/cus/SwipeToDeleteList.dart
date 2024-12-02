import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SwipeToDeleteList extends StatefulWidget {
  @override
  _SwipeToDeleteListState createState() => _SwipeToDeleteListState();
}

class _SwipeToDeleteListState extends State<SwipeToDeleteList> {
  final List<Record> records = List.generate(
    10,
        (index) => Record(id: index, weather: "Sunny", feeling: "Happy", information: "Record $index", date: DateTime.now().millisecondsSinceEpoch),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swipe to Delete")),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          return DismissibleRecordItem(
            record: records[index],
            onDelete: () {
              setState(() {
                records.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}

class DismissibleRecordItem extends StatefulWidget {
  final Record record;
  final VoidCallback onDelete;

  const DismissibleRecordItem({
    required this.record,
    required this.onDelete,
  });

  @override
  _DismissibleRecordItemState createState() => _DismissibleRecordItemState();
}

class _DismissibleRecordItemState extends State<DismissibleRecordItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.4, 0), // Item slides partially
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _handleDismiss() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("确认删除"),
          content: Text("您确定要删除这条记录吗？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
                setState(() => _isDismissed = true);
              },
              child: Text("删除"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isDismissed
        ? SizedBox.shrink()
        : SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            _controller.forward();
          }
        },
        child: Stack(
          children: [
            Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: _handleDismiss,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(widget.record.information),
                subtitle: Text("Date: ${widget.record.date}"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Record {
  final int id;
  final String weather;
  final String feeling;
  final String information;
  final int date;

  Record({required this.id, required this.weather, required this.feeling, required this.information, required this.date});
}
