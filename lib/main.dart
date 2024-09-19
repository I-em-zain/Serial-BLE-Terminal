import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bluetoothProvider.dart';
import 'homePageScreen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _handlePermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> _handlePermissions() async {
  // Check and request location permission
  final locationStatus = await Permission.locationWhenInUse.status;
  if (!locationStatus.isGranted) {
    final result = await Permission.locationWhenInUse.request();
    if (result.isDenied) {
      // Handle permission denied
      print("Location permission denied");
    }
  }

  // Check and request Bluetooth permission (for Android 12+)
  final bluetoothStatus = await Permission.bluetoothScan.status;
  if (!bluetoothStatus.isGranted) {
    final result = await Permission.bluetoothScan.request();
    if (result.isDenied) {
      // Handle permission denied
      print("Bluetooth scan permission denied");
    }
  }

  final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
  if (!bluetoothConnectStatus.isGranted) {
    final result = await Permission.bluetoothConnect.request();
    if (result.isDenied) {
      // Handle permission denied
      print("Bluetooth connect permission denied");
    }
  }

  // Check and request location permission on Android 10+
  if (await Permission.locationAlways.isRestricted) {
    await Permission.locationAlways.request();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serial BLE Terminal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}
