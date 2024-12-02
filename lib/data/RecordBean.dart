import 'package:intl/intl.dart';

class RecordBean {
  String id;
  String date;
  String information;
  String bgList;
  int weather;
  int feeling;

  RecordBean({
    required this.id,
    required this.information,
    required this.date,
    required this.bgList,
    required this.weather,
    required this.feeling,
  });

  // 从JSON解析为Event实例
  factory RecordBean.fromJson(Map<String, dynamic> json) {
    return RecordBean(
      id: json['id'] ?? '',
      information: json['information'] ?? '',
      date: json['date'] ?? '',
      bgList: json['bgList'] ?? '',
      weather: json['weather'] ?? 0,
      feeling: json['feeling'] ?? 0,
    );
  }

  // 将Event实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'information': information,
      'date': date,
      'bgList': bgList,
      'weather': weather,
      'feeling': feeling,
    };
  }

  // Adjust date based on weather frequency with precision to seconds
  void adjustDateIfRepeating() {
    DateTime currentDate = DateTime.now();
    DateTime eventDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
    // Keep updating the event date to the next valid occurrence
    while (eventDate.isBefore(currentDate)) {
      switch (weather) {
        case 1: // Every Week
          eventDate = eventDate.add(Duration(days: 7));
          break;
        case 2: // Every Month
          eventDate = DateTime(eventDate.year, eventDate.month + 1, eventDate.day, eventDate.hour, eventDate.minute, eventDate.second);
          break;
        case 3: // Every Year
          eventDate = DateTime(eventDate.year + 1, eventDate.month, eventDate.day, eventDate.hour, eventDate.minute, eventDate.second);
          break;
        default:
          break;
      }
    }
    // Update the date to the next valid occurrence
    date = DateFormat('yyyy-MM-dd HH:mm:ss').format(eventDate);
  }

  static String getTimeFromTimestamp(String timestampString) {
    int timestamp = int.parse(timestampString);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
