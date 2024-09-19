import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'bluetoothProvider.dart';
import 'connectScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Serial BLE Terminal', style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh,color: Colors.white,),
              onPressed: () {
                bluetoothProvider.startScan();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: bluetoothProvider.scannedDevices.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = bluetoothProvider.scannedDevices[index];
                  return ListTile(
                    title: Text(device.platformName.isNotEmpty ? device.platformName : "Unknown Device"),
                    subtitle: Text(device.remoteId.toString()),
                    onTap: () async {
                      bluetoothProvider.stopScan();
                      await bluetoothProvider.connectToDevice(device);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
