import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'esp_blufi_method_channel.dart';

abstract class EspBlufiPlatform extends PlatformInterface {
  /// Constructs a EspBlufiPlatform.
  EspBlufiPlatform() : super(token: _token);

  static final Object _token = Object();

  static EspBlufiPlatform _instance = MethodChannelEspBlufi.instance;

  /// The default instance of [EspBlufiPlatform] to use.
  ///
  /// Defaults to [MethodChannelEspBlufi].
  static EspBlufiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EspBlufiPlatform] when
  /// they register themselves.
  static set instance(EspBlufiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> startScan({String? filterString}) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<bool> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Future<bool> connect({String? deviceAddress}) {
    throw UnimplementedError('connect() has not been implemented');
  }

  Future<bool> requestCloseConnection() async {
    throw UnimplementedError('requestCloseConnection() has not been implemented');
  }

  Future<bool> requestDeviceWifiScan() async {
    throw UnimplementedError('requestDeviceWifiScan() has not been implemented');
  }

  Future<void> configProvision({String? username, String? password}) async {
    throw UnimplementedError('configProvision() has not been implemented');
  }

  Future<void> getAllPairedDevice() async {
    throw UnimplementedError('getAllPairedDevice');
  }

  Future<void> requestDeviceStatus() async {
    throw UnimplementedError('requestDeviceStatus');
  }

  Future<bool> sendCustomData({String? data}) async {
    throw UnimplementedError('sendCustomData');
  }

  void onMessageReceived(
      {ResultCallback? successCallback, ResultCallback? errorCallback}) {
    throw UnimplementedError('onMessageReceived() has not been implemented');
  }
}
