import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'bluetoothProvider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> responseMessages = [];
  bool waitingForResponse = false;
  final StringBuffer _responseBuffer = StringBuffer();
  final ScrollController _scrollController = ScrollController();
  BluetoothCharacteristic? _defaultConnection;

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);

    EasyLoading.show(status: 'Connecting...');

    try {
      // Use provider to manage connection
      if (bluetoothProvider.connectedDevice != null) {
        await bluetoothProvider.discoverServices();
        setUpCharacteristics(bluetoothProvider.services!);
      }
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      showMessage("Error connecting to device: $e");
      Navigator.pop(context);
    }
  }

  void setUpCharacteristics(List<BluetoothService> services) {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            _responseBuffer.write(String.fromCharCodes(value));
            if (mounted) {
              setState(() {
                waitingForResponse = true;
              });
            }

            if (_responseBuffer.toString().contains('\n')) {
              if (mounted) {
                setState(() {
                  responseMessages.add(_responseBuffer.toString().trim());
                  _responseBuffer.clear();
                  waitingForResponse = false;
                });


                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                });
              }
              if (kDebugMode) {
                print("Received data: ${responseMessages.last}");
              }
            }
          });
        }
        if (characteristic.uuid == Guid('6e400002-b5a3-f393-e0a9-e50e24dcca9e')) {
          _defaultConnection = characteristic;
        }
      }
    }
  }

  Future<void> write(String message) async {
    if (_defaultConnection != null) {
      try {
        waitingForResponse = true;
        await _defaultConnection!.write(utf8.encode(message) as Uint8List);
        if (kDebugMode) {
          print("Data written: $message");
        }

        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        if (kDebugMode) {
          print("Error writing data: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("No default connection available.");
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final device = bluetoothProvider.connectedDevice;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(device != null ? device.platformName : 'No Device',style: TextStyle(fontWeight: FontWeight.w600),),
          backgroundColor: device != null && device.isConnected ? Colors.green : Colors.grey,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: responseMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Text('Response: ${responseMessages[index]}'),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Send Data/Commands'),
                    ),
                  ),
                  const SizedBox(width: 8.0), // Space between TextField and button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.green), // Green background
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // White icon
                      ),
                      onPressed: () {
                        write('${_controller.text.trim()}\r');
                      },
                      child: const Icon(Icons.send),
                    )
      
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
