import 'dart:async';
import 'dart:convert';

import 'package:esp_blufi/esp_blufi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _espBlufiPlugin = EspBlufi();

  String contentJson = 'Unknown';
  Map<String, dynamic> scanResult = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _espBlufiPlugin.onMessageReceived(
      successCallback: (String? data) {
        debugPrint("success data: $data");
        setState(() {
          contentJson = data ?? 'null';
          Map<String, dynamic> mapData = json.decode(data ?? '');
          if (mapData.containsKey('key')) {
            String key = mapData['key'];
            if (key == 'ble_scan_result') {
              Map<String, dynamic> peripheral = mapData['value'];

              String address = peripheral['address'];
              String name = peripheral['name'];
              int rssi = peripheral['rssi'];
              debugPrint('rssi: $rssi');
              scanResult[address] = name;
            }
          }
        });
      },
      errorCallback: (error) {},
    );
  }

  @override
  void dispose() {
    _espBlufiPlugin.stopScan();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _espBlufiPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    debugPrint('Platform version: $platformVersion');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextButton(onPressed: () async {
              await _espBlufiPlugin.startScan(filterString: 'BLUFI');
            }, child: const Text('Scan')),
            TextButton(onPressed: () async {
             await _espBlufiPlugin.stopScan();
            }, child: const Text('Stop Scan')),
            TextButton(onPressed: () async {
             await _espBlufiPlugin.connect(deviceAddress: scanResult.keys.first);
            }, child: const Text('Connect Peripheral')),
            TextButton(onPressed: () async {
             await _espBlufiPlugin.requestCloseConnection();
            }, child: const Text('Close Connect')),
            TextButton(onPressed: () async {
            //  await _espBlufiPlugin.configProvision(username: 'ABCXYZ', password: '0913456789');
            }, child: const Text('Config Provision')),
            TextButton(onPressed: () async {
              String command = '12345678';
              await _espBlufiPlugin.sendCustomData(data: command);
            }, child: const Text('Send Custom Data')),
            Text(contentJson),
          ],
        ),
      ),
    );
  }
}
