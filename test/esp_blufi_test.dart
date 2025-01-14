import 'package:esp_blufi/esp_blufi_method_channel.dart';
import 'package:esp_blufi/esp_blufi_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MockEspBlufiPlatform
    with MockPlatformInterfaceMixin
    implements EspBlufiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  
  @override
  Future<bool?> startScan({String? filterString}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> stopScan() {
    throw UnimplementedError();
  }

  @override
  Future<bool> connect({String? deviceAddress}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestCloseConnection() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestDeviceWifiScan() {
    throw UnimplementedError();
  }

  @override
  Future<void> configProvision({String? username, String? password}) {
    throw UnimplementedError();
  }

  // @override
  // Future<void> getAllPairedDevice() {
  //   throw UnimplementedError();
  // }

  // @override
  // Future<void> requestDeviceStatus() {
  //   throw UnimplementedError();
  // }

  @override
  Future<bool> sendCustomData({String? data}) {
    throw UnimplementedError();
  }


  // @override
  // void onMessageReceived({ResultCallback? successCallback, ResultCallback? errorCallback}) {
  // }
}

void main() {
  final EspBlufiPlatform initialPlatform = EspBlufiPlatform.instance;
  test('$MethodChannelEspBlufi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEspBlufi>());
  });

  // test('getPlatformVersion', () async {
  //   EspBlufi espBlufiPlugin = EspBlufi();
  //   MockEspBlufiPlatform fakePlatform = MockEspBlufiPlatform();
  //   EspBlufiPlatform.instance = fakePlatform;
  
  //   expect(await espBlufiPlugin.getPlatformVersion(), '42');
  // });
}
