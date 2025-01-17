import 'package:esp_blufi/esp_blufi_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'esp_blufi_platform_interface.dart';

typedef BlufiDataCallback = void Function(EspBlufiData data);
typedef ResultCallback = void Function(String? data);


/// An implementation of [EspBlufiPlatform] that uses method channels.
class MethodChannelEspBlufi extends EspBlufiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('esp_blufi');
  final EventChannel _eventChannel = const EventChannel('esp_blufi/state');

  ResultCallback? _resultSuccessCallback;
  ResultCallback? _resultErrorCallback;

  static  final MethodChannelEspBlufi _instance = MethodChannelEspBlufi._();
  static MethodChannelEspBlufi get instance => _instance;

  MethodChannelEspBlufi._() {
    methodChannel.setMethodCallHandler(null);

    _eventChannel.receiveBroadcastStream().listen(speechResultsHandler, onError: speechResultErrorHandler);
  }

  @override
  void onMessageReceived({ResultCallback? successCallback, ResultCallback? errorCallback}) {
    _resultSuccessCallback = successCallback;
    _resultErrorCallback = errorCallback;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> startScan({String? filterString}) async {
    final bool? isEnable = await methodChannel.invokeMethod('startScan', <String, dynamic>{'filter': filterString});
    return isEnable;
  }

  @override
  Future<bool> stopScan() async {
    return await methodChannel.invokeMethod('stopScan');
  }

  @override
  Future<bool> connect({String? deviceAddress}) async {
    return await methodChannel.invokeMethod('connect', <String, dynamic>{'deviceAddress': deviceAddress});
  }

  @override
  Future<bool> requestCloseConnection() async {
    return await methodChannel.invokeMethod('requestCloseConnection');
  }

  @override
  Future<bool> requestDeviceWifiScan() async {
    return await methodChannel.invokeMethod('requestDeviceWifiScan');
  }

  @override
  Future<void> configProvision({String? username, String? password}) async {
    await methodChannel.invokeMethod('configProvision', <String, dynamic>{'username': username, 'password': password});
  }

  @override
  Future<void> getAllPairedDevice() async {
    await methodChannel.invokeMethod('getAllPairedDevice');
  }

  @override
  Future<void> requestDeviceStatus() async {
    await methodChannel.invokeMethod('requestDeviceStatus');
  }

  @override
  Future<bool> sendCustomData({String? data}) async {
    return await methodChannel.invokeMethod('sendCustomData', <String, dynamic>{'data': data});
  }

  speechResultsHandler(dynamic event) {
    if (_resultSuccessCallback != null) _resultSuccessCallback!(event);
  }

  speechResultErrorHandler(dynamic error) {
    if (_resultErrorCallback != null) _resultErrorCallback!(error);
  }
}
