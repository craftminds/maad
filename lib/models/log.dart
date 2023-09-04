import 'package:flutter/material.dart';

class Log {
  final DateTime datetime;
  final String info;
  final InfoStatus status;
  Log({
    required this.datetime,
    required this.info,
    required this.status,
  });
}

enum InfoStatus {
  warning,
  error,
  info,
}
