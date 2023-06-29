import 'package:flutter/material.dart';
import '../models/log.dart';

class Logs with ChangeNotifier {
  List<Log> _logTable = [];

//addLog
  void addLog(String info, InfoStatus status) {
    _logTable.add(Log(datetime: DateTime.now(), info: info, status: status));
    notifyListeners();
  }

//getLogs
  get logTable {
    return _logTable;
  }

//clearLogs
  void clearLogs() {
    _logTable = [];
    notifyListeners();
  }
}
