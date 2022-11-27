import 'package:intl/intl.dart';

String getFormattedDate(num dt, {String pattern = 'dd/MM/yyyy'}) =>
    DateFormat(pattern)
        .format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
