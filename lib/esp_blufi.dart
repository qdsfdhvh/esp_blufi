import 'package:esp_blufi/esp_blufi_data.dart';
import 'package:esp_blufi/esp_blufi_method_channel.dart';

import 'esp_blufi_platform_interface.dart';

typedef ResultCallback = void Function(String? data);

class EspBlufi {
  static EspBlufiPlatform get instance => EspBlufiPlatform.instance;

  Future<String?> getPlatformVersion() {
    return EspBlufi.instance.getPlatformVersion();
  }

  void addMessageReceived({ required BlufiDataCallback callback }) {
    EspBlufi.instance.addMessageReceived(callback: callback);
  }

  void removeMessageReceived({ required BlufiDataCallback callback }) {
    EspBlufi.instance.removeMessageReceived(callback: callback);
  }

  void addErrorReceived({ required ResultCallback callback }) {
    EspBlufi.instance.addErrorReceived(callback: callback);
  }

  void removeErrorReceived({ required ResultCallback callback }) {
    EspBlufi.instance.removeErrorReceived(callback: callback);
  }

  Future<List<ScanResult>> getAllPairedDevice() async {
    return await EspBlufi.instance.getAllPairedDevice();
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

  Future<bool> requestDeviceVersion() async {
    return EspBlufi.instance.requestDeviceVersion();
  }

  Future requestDeviceStatus() async {
    return EspBlufi.instance.requestDeviceStatus();
  }

  Future<bool> requestDeviceWifiScan() async {
    return EspBlufi.instance.requestDeviceWifiScan();
  }

  Future configProvision({String? ssid, String? password}) async {
    return EspBlufi.instance
        .configProvision(ssid: ssid, password: password);
  }

  Future<bool> sendCustomData({String? data}) async {
    return EspBlufi.instance.sendCustomData(data: data);
  }

  Future<bool> negotiateSecurity() async {
    return EspBlufi.instance.negotiateSecurity();
  }
}
