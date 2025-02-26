import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formartDateTime(DateTime datetime) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String dateTimeString = dateFormat.format(datetime);
  return dateTimeString;
}

String formartDate(DateTime datetime) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  String dateTimeString = dateFormat.format(datetime);
  return dateTimeString;
}

String formatTime(TimeOfDay datetime) {
  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat("HH:mm");

  DateTime temp =
      DateTime(now.year, now.month, now.day, datetime.hour, datetime.minute);

  String dateTimeString = dateFormat.format(temp);

  return dateTimeString;
}
