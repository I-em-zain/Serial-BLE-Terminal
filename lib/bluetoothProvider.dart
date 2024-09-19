import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider with ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService>? _services;
  final List<BluetoothDevice> _scannedDevices = [];

  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothService>? get services => _services;
  List<BluetoothDevice> get scannedDevices => _scannedDevices;

  Future<void> startScan() async {
    _scannedDevices.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.isNotEmpty && r.device.platformName != "Unknown Device" && !_scannedDevices.contains(r.device)) {
          _scannedDevices.add(r.device);
        }
      }
      notifyListeners();
    });
  }


  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      await discoverServices();
      notifyListeners();
    } catch (e) {
      disconnectDevice();
    }
  }

  Future<void> discoverServices() async {
    if (_connectedDevice != null) {
      _services = await _connectedDevice!.discoverServices();
      notifyListeners();
    }
  }

  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _services = null;
      notifyListeners();
    }
  }

  bool get isConnected => _connectedDevice != null;
}
