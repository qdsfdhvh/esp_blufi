import 'dart:convert';

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

  // ResultCallback? _resultSuccessCallback;
  // ResultCallback? _resultErrorCallback;

  static final MethodChannelEspBlufi _instance = MethodChannelEspBlufi._();
  static MethodChannelEspBlufi get instance => _instance;

  final List<BlufiDataCallback> _messageReceivedCallbacks = [];
  final List<ResultCallback> _errorReceivedCallbacks = [];

  MethodChannelEspBlufi._() {
    methodChannel.setMethodCallHandler(null);
    _eventChannel.receiveBroadcastStream().listen(
          _speechResultsHandler,
          onError: _speechResultErrorHandler,
        );
  }

  _speechResultsHandler(dynamic event) {
    if (_messageReceivedCallbacks.isNotEmpty) {
      Map<String, dynamic> mapData = json.decode(event);
      final blufiData = EspBlufiData.fromJson(mapData);
      for (var callback in _messageReceivedCallbacks) {
        callback(blufiData);
      }
    }
  }

  _speechResultErrorHandler(dynamic error) {
    if (_errorReceivedCallbacks.isNotEmpty) {
      for (var callback in _errorReceivedCallbacks) {
        callback(error);
      }
    }
  }

  @override
  void addMessageReceived({BlufiDataCallback? callback}) {
    _messageReceivedCallbacks.add(callback!);
  }

  @override
  void removeMessageReceived({BlufiDataCallback? callback}) {
    _messageReceivedCallbacks.remove(callback);
  }

  @override
  void addErrorReceived({ResultCallback? callback}) {
    _errorReceivedCallbacks.add(callback!);
  }

  @override
  void removeErrorReceived({ResultCallback? callback}) {
    _errorReceivedCallbacks.remove(callback);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<ScanResult>> getAllPairedDevice() async {
    final list =
        await methodChannel.invokeMethod<List<String>>('getAllPairedDevice');
    return list?.map((e) {
          Map<String, dynamic> mapData = json.decode(e);
          return ScanResult.fromJson(mapData);
        }).toList() ??
        [];
  }

  @override
  Future<bool?> startScan({String? filterString}) async {
    final bool? isEnable = await methodChannel
        .invokeMethod('startScan', <String, dynamic>{'filter': filterString});
    return isEnable;
  }

  @override
  Future<bool> stopScan() async {
    return await methodChannel.invokeMethod('stopScan');
  }

  @override
  Future<bool> connect({String? deviceAddress}) async {
    return await methodChannel.invokeMethod(
        'connect', <String, dynamic>{'deviceAddress': deviceAddress});
  }

  @override
  Future<bool> requestCloseConnection() async {
    return await methodChannel.invokeMethod('requestCloseConnection');
  }

  @override
  Future<bool> requestDeviceVersion() async {
    return await methodChannel.invokeMethod('requestDeviceVersion');
  }

  @override
  Future<bool> requestDeviceStatus() async {
    return await methodChannel.invokeMethod('requestDeviceStatus');
  }

  @override
  Future<bool> requestDeviceWifiScan() async {
    return await methodChannel.invokeMethod('requestDeviceWifiScan');
  }

  @override
  Future<void> configProvision({String? username, String? password}) async {
    await methodChannel.invokeMethod('configProvision',
        <String, dynamic>{'username': username, 'password': password});
  }

  @override
  Future<bool> sendCustomData({String? data}) async {
    return await methodChannel
        .invokeMethod('sendCustomData', <String, dynamic>{'data': data});
  }

  @override
  Future<bool> negotiateSecurity() async {
    return await methodChannel.invokeMethod('negotiateSecurity');
  }
}
