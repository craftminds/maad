import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

typedef void FunctionCallback(int function, Uint8List data);
typedef void ErrorCallback(error, stackTrace);
typedef void CloseCallback();

/// This should be called by the Connector implementation when response comes from the device
late FunctionCallback onResponse;

/// This should be called by the Connector implementation when any error occurs
ErrorCallback? onError;

/// This should be called by the Connector implementation after closing connection (socket close, etc)
CloseCallback? onClose;

class TCPConnector {
  var _address;
  int _port;
  int _transactionID = 0;
  late int _unitID;
  final Duration? timeout;

  Socket? _socket;
  List<int> tcpBuffer = Uint8List(0);

  TCPConnector(this._address, this._port, {this.timeout});

  Future<void> connect() async {
    _socket = await Socket.connect(_address, _port, timeout: this.timeout);
    _socket!.listen(_onData,
        onError: onError, onDone: onClose, cancelOnError: true);
  }

  void _onData(List<int> tcpData) {
    tcpBuffer =
        tcpBuffer + tcpData; //add new data to any data already in buffer

    while (tcpBuffer.length > 8) {
      var view = ByteData.view(Uint8List.fromList(tcpBuffer).buffer);
      int tid = view.getUint16(0); // ignore: unused_local_variable
      int len = view.getUint16(4);
      int unitId = view.getUint8(6); // ignore: unused_local_variable
      int function = view.getUint8(7);

      // check if frame is complete - payload is 2 bytes shorter then length since Modbus length is calculated including unitID and function code
      if (tcpBuffer.length >= (8 + len - 2)) {
        var payload = tcpBuffer.sublist(8, 8 + len - 2);
        tcpBuffer.removeRange(
            0, 8 + len - 2); // remove Modbus packet data from buffer
        onResponse(function, Uint8List.fromList(payload));
      } else {
        // not enough bytes in buffer - wait and hope that remaining data is in next TCP frame
        break;
      }
    }
  }

  void write(int function, Uint8List data) {
    _transactionID++;

    Uint8List tcpHeader = Uint8List(7); // Modbus Application Header
    ByteData.view(tcpHeader.buffer)
      ..setUint16(0, _transactionID, Endian.big)
      ..setUint16(4, 1 /*unitId*/ + 1 /*fn*/ + data.length, Endian.big)
      ..setUint8(6, _unitID);

    Uint8List fn = Uint8List(1); // Modbus Application Header
    ByteData.view(fn.buffer).setUint8(0, function);

    Uint8List tcpData = Uint8List.fromList(tcpHeader + fn + data);
    _socket!.add(tcpData);
  }
}
