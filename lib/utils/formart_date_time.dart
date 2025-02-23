import 'package:intl/intl.dart';

String formartDateTime(DateTime datetime) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String dateTimeString = dateFormat.format(datetime);
  return dateTimeString;
}
