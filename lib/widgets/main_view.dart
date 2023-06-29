import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../providers/tcp_client.dart';
import '../providers/logs.dart';
import '../models/log.dart';

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    ipAddressController.addListener(() {
      setState(() {
        _connectEnable = ipAddressController.value.text.isNotEmpty &&
            portController.value.text.isNotEmpty;
      });
    });
    portController.addListener(() {
      setState(() {
        _connectEnable = ipAddressController.value.text.isNotEmpty &&
            portController.value.text.isNotEmpty;
      });
    });
  }

  Uint8List mbFrame = Uint8List.fromList([1, 3, 0, 20, 0, 2, 132, 15]);

  String modbusRequest = '';

  String consoleBufferedText = 'Log:';

  TextEditingController ipAddressController = TextEditingController();

  TextEditingController portController = TextEditingController();
  bool _connectEnable = false;

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String errorText = Provider.of<TcpClient>(context).error;
    ClientStatus _clientConnected =
        Provider.of<TcpClient>(context, listen: false).clientConnectionStatus;

    final logs = Provider.of<Logs>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Container(
                      // color: Color.fromRGBO(227, 227, 9, 0.612),
                      width: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _form,
                          child: Column(children: <Widget>[
                            //input for IP address
                            FocusTraversalOrder(
                              order: const NumericFocusOrder(1.0),
                              child: TextFormField(
                                validator: (value) {
                                  RegExp regExp = new RegExp(
                                      r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
                                  if (value == null || value.isEmpty) {
                                    // return ' Please enter IP address';
                                    _connectEnable = false;
                                    return null;
                                  } else if (!regExp.hasMatch(value)) {
                                    return ('Not valid IP address');
                                  }
                                  return null;
                                },
                                controller: ipAddressController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter IP address',
                                  focusColor: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            //input for Port
                            FocusTraversalOrder(
                              order: const NumericFocusOrder(2.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    _connectEnable = false;
                                    return null;
                                  }
                                  int? valueInt = int.tryParse(value);
                                  if (valueInt == null) {
                                    return 'Invalid value';
                                  } else if (valueInt < 1 || valueInt > 65535) {
                                    return 'Only 1-65535 numbers';
                                  }
                                  return null;
                                },
                                controller: portController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter port',
                                  focusColor: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            //Connect button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(3.0),
                                  child: TextButton(
                                    onPressed: _connectEnable &&
                                            _form.currentState!.validate() &&
                                            _clientConnected ==
                                                ClientStatus.closed
                                        ? () {
                                            _form.currentState?.save();
                                            Provider.of<TcpClient>(context,
                                                    listen: false)
                                                .createTcpClient(
                                                    ipAddressController.text,
                                                    int.parse(
                                                        portController.text));
                                            Provider.of<TcpClient>(context,
                                                    listen: false)
                                                .connectToServer();
                                            logs.addLog(
                                              'Port opened ${portController.text}@${ipAddressController.text}',
                                              InfoStatus.info,
                                            );
                                          }
                                        : null,
                                    child: const Text('Connect'),
                                    //style: ButtonStyle(),
                                  ),
                                ),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(4.0),
                                  child: TextButton(
                                    onPressed:
                                        _clientConnected == ClientStatus.opened
                                            ? () {
                                                Provider.of<TcpClient>(context,
                                                        listen: false)
                                                    .disconnectFromServer();
                                              }
                                            : null,
                                    child: const Text('Disconnect'),
                                    //style: ButtonStyle(),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: <Widget>[
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Device ID',
                              focusColor: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Address',
                              focusColor: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'No of registers',
                              focusColor: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            //cannot send if socket is not opened
                            onPressed: () {
                              Provider.of<TcpClient>(context, listen: false)
                                  .sendMessage();
                            },
                            child: const Text('Send'),
                            //style: ButtonStyle(),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        width: 280,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(' - device address'),
                                SizedBox(height: 5),
                                Text(' - no of registers'),
                                SizedBox(height: 5),
                                Text(' - data'),
                              ]),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DataTable(
                            headingRowHeight: 0,
                            dividerThickness: 1,
                            columns: [
                              DataColumn(label: Text('Timestamp')),
                              DataColumn(label: Text('Info')),
                            ],
                            rows: [
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('timestamp')),
                                  DataCell(Text(
                                      'longer info to view and information about addresss 192.168.2.2.')),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('timestamp')),
                                  DataCell(Text('info')),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('timestamp')),
                                  DataCell(
                                    Text(
                                      'anther info about the application state or the conection state that probably won;t fit to single line',
                                      softWrap: true,
                                    ),
                                    // ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
