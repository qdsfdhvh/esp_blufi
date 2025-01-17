import 'dart:convert';

import 'package:esp_blufi/esp_blufi_data.dart';
import 'package:esp_blufi/esp_blufi_method_channel.dart';

import 'esp_blufi_platform_interface.dart';

typedef ResultCallback = void Function(String? data);

class EspBlufi {
  static EspBlufiPlatform get instance => EspBlufiPlatform.instance;

  Future<String?> getPlatformVersion() {
    return EspBlufi.instance.getPlatformVersion();
  }

  Future<bool?> startScan({String? filterString}) {
    return EspBlufi.instance.startScan(filterString: filterString);
  }

  Future<bool> stopScan() async {
    return EspBlufi.instance.stopScan();
  }

  Future<bool> connect({String? deviceAddress}) async {
    return EspBlufi.instance.connect(deviceAddress: deviceAddress);
  }

  Future<bool> requestCloseConnection() async {
    return EspBlufi.instance.requestCloseConnection();
  }

  Future<bool> requestDeviceWifiScan() async {
    return EspBlufi.instance.requestDeviceWifiScan();
  }

  Future configProvision({String? username, String? password}) async {
    return EspBlufi.instance
        .configProvision(username: username, password: password);
  }

  void onMessageReceived(
      {BlufiDataCallback? successCallback, ResultCallback? errorCallback}) {
    EspBlufi.instance.onMessageReceived(
        successCallback: (String? data) {
          if (successCallback != null && data != null) {
            Map<String, dynamic> mapData = json.decode(data);
            final blufiData = EspBlufiData.fromJson(mapData);
            successCallback.call(blufiData);
          }
        },
        errorCallback: errorCallback);
  }

  Future getAllPairedDevice() async {
    return EspBlufi.instance.getAllPairedDevice();
  }

  Future requestDeviceStatus() async {
    return EspBlufi.instance.requestDeviceStatus();
  }

  Future<bool> sendCustomData({String? data}) async {
    return EspBlufi.instance.sendCustomData(data: data);
  }
}
