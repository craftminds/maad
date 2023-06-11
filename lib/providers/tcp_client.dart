import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modbus/modbus.dart' as modbus;

class TcpClient with ChangeNotifier {
  late modbus.ModbusClient _client;
  String _ipAddress = '127.0.0.1';
  int _port = 502;
  String _errorMessage = '';
  var _registers;

  ClientStatus _clientStatus = ClientStatus.closed;

  get error {
    return _errorMessage;
  }

  get clientConnectionStatus {
    return _clientStatus;
  }

  void createTcpClient(String ip, int port) {
    _ipAddress = ip;
    _port = port;

    _client = modbus.createTcpClient(
      _ipAddress,
      port: _port,
      mode: modbus.ModbusMode.rtu,
      timeout: const Duration(seconds: 5),
    );
  }

  Future<void> connectToServer() async {
    try {
      await _client.connect();
      _clientStatus = ClientStatus.opened;
      print("client connected");
    } on SocketException {
      _errorMessage = 'Connection timed out for $_ipAddress:$_port';
      notifyListeners();
    } catch (e) {
      _errorMessage = '$e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> disconnectFromServer() async {
    _clientStatus = ClientStatus.closed;
    _client.close();
    notifyListeners();
  }

  Future<void> sendMessage() async {
    try {
      _registers = await _client.readHoldingRegisters(0, 5);
      for (int i = 0; i < _registers.length; i++) {
        print("REG_I[${i}]: " + _registers.elementAt(i).toString());
      }
    } catch (e) {
      _errorMessage = '$e';
    } finally {
      notifyListeners();
    }
  }
}

enum ClientStatus { opened, closed }
