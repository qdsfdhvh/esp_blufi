sealed class EspBlufiData {
  const EspBlufiData();

  factory EspBlufiData.fromJson(Map<String, dynamic> json) {
    final key = json['key'];
    final value = json['value'] as Map<String, dynamic>;
    switch (key) {
      case 'ble_scan_result':
        return ScanResult.fromJson(value);
      case 'ble_gatt_state':
        return ConnectionStateChange.fromJson(value);
      case 'ble_mtu_change':
        return MtuChange.fromJson(value);
      case 'ble_set_notification':
        return SetNotification.fromJson(value);
      case 'blufi_gatt_prepared':
        return BlufiGattPrepared.fromJson(value);
      case 'blufi_negotiate_security_result':
        return BlufiNegotiateSecurityResult.fromJson(value);
      case 'blufi_post_configure_params':
        return BlufiPostConfigureParams.fromJson(value);
      case 'blufi_device_status_response':
        return BlufiDeviceStatusResponse.fromJson(value);
      case 'blufi_scan_result':
        return BlufiScanSSIDsResult.fromJson(value);
      case 'blufi_device_version':
        return BlufiDeviceVersion.fromJson(value);
      case 'blufi_post_custom_data_result':
        return BlufiPostCustomDataResult.fromJson(value);
      case 'blufi_receive_custom_data':
        return BlufiReceiveCustomData.fromJson(value);
      case 'blufi_error':
        return BlufiError.fromJson(value);
      default:
        throw Exception('Unknown key: $key');
    }
  }
}

class ScanResult extends EspBlufiData {
  final String address;
  final String name;
  final int rssi;

  ScanResult({
    required this.address,
    required this.name,
    required this.rssi,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      address: json['address'],
      name: json['name'],
      rssi: json['rssi'],
    );
  }

  @override
  String toString() {
    return 'ScanResult{address: $address, name: $name, rssi: $rssi}';
  }
}

class ConnectionStateChange extends EspBlufiData {
  final String address;
  final int status;
  final int state;

  ConnectionStateChange({
    required this.address,
    required this.status,
    required this.state,
  });

  factory ConnectionStateChange.fromJson(Map<String, dynamic> json) {
    return ConnectionStateChange(
      address: json['address'],
      status: json['status'],
      state: json['state'],
    );
  }

  @override
  String toString() {
    return 'ConnectionStateChange{address: $address, status: $status, state: $state}';
  }
}

class MtuChange extends EspBlufiData {
  final int mtu;

  MtuChange({
    required this.mtu,
  });

  factory MtuChange.fromJson(Map<String, dynamic> json) {
    return MtuChange(
      mtu: json['mtu'],
    );
  }

  @override
  String toString() {
    return 'MtuChange{mtu: $mtu}';
  }
}

class SetNotification extends EspBlufiData {
  final String address;
  final int status;

  SetNotification({
    required this.address,
    required this.status,
  });

  factory SetNotification.fromJson(Map<String, dynamic> json) {
    return SetNotification(
      address: json['address'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'SetNotification{address: $address, status: $status}';
  }
}

class BlufiGattPrepared extends EspBlufiData {
  final String address;
  final bool hasService;
  final bool hasWriteChar;
  final bool hasNotifyChar;
  final bool requestMtu;
  final int mtu;

  BlufiGattPrepared({
    required this.address,
    required this.hasService,
    required this.hasWriteChar,
    required this.hasNotifyChar,
    required this.requestMtu,
    required this.mtu,
  });

  factory BlufiGattPrepared.fromJson(Map<String, dynamic> json) {
    return BlufiGattPrepared(
      address: json['address'],
      hasService: json['has_service'],
      hasWriteChar: json['has_write_char'],
      hasNotifyChar: json['has_notify_char'],
      requestMtu: json['request_mtu'],
      mtu: json['mtu'],
    );
  }

  @override
  String toString() {
    return 'BlufiGattPrepared{address: $address, hasService: $hasService, hasWriteChar: $hasWriteChar, hasNotifyChar: $hasNotifyChar, requestMtu: $requestMtu, mtu: $mtu}';
  }
}

class BlufiNegotiateSecurityResult extends EspBlufiData {
  final int status;

  BlufiNegotiateSecurityResult({
    required this.status,
  });

  factory BlufiNegotiateSecurityResult.fromJson(Map<String, dynamic> json) {
    return BlufiNegotiateSecurityResult(
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'BlufiNegotiateSecurityResult{status: $status}';
  }
}

class BlufiPostConfigureParams extends EspBlufiData {
  final int status;

  BlufiPostConfigureParams({
    required this.status,
  });

  factory BlufiPostConfigureParams.fromJson(Map<String, dynamic> json) {
    return BlufiPostConfigureParams(
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'BlufiPostConfigureParams{status: $status}';
  }
}

class BlufiDeviceStatusResponse extends EspBlufiData {
  final int status;
  final int opMode;
  final int staConnectionStatus;
  final String? staBSSID;
  final String? staSSID;
  final String? staPassword;
  final int? softAPConnectionCount;
  final int? softAPMaxConnectionCount;
  final int? softAPSecurity;
  final int? softAPChannel;
  final String? softAPSSID;
  final String? softAPPassword;

  BlufiDeviceStatusResponse({
    required this.status,
    required this.opMode,
    required this.staConnectionStatus,
    required this.staBSSID,
    required this.staSSID,
    required this.staPassword,
    required this.softAPConnectionCount,
    required this.softAPMaxConnectionCount,
    required this.softAPSecurity,
    required this.softAPChannel,
    required this.softAPSSID,
    required this.softAPPassword,
  });

  factory BlufiDeviceStatusResponse.fromJson(Map<String, dynamic> json) {
    return BlufiDeviceStatusResponse(
      status: json['status'],
      opMode: json['op_mode'],
      staConnectionStatus: json['sta_connection_status'],
      staBSSID: json['sta_bssid'],
      staSSID: json['sta_ssid'],
      staPassword: json['sta_password'],
      softAPConnectionCount: json['soft_ap_connection_count'],
      softAPMaxConnectionCount: json['soft_ap_max_connection_count'],
      softAPSecurity: json['soft_ap_security'],
      softAPChannel: json['soft_ap_channel'],
      softAPSSID: json['soft_ap_ssid'],
      softAPPassword: json['soft_ap_password'],
    );
  }

  @override
  String toString() {
    return 'BlufiDeviceStatusResponse{status: $status, opMode: $opMode, staConnectionStatus: $staConnectionStatus, staBSSID: $staBSSID, staSSID: $staSSID, staPassword: $staPassword, softAPConnectionCount: $softAPConnectionCount, softAPMaxConnectionCount: $softAPMaxConnectionCount, softAPSecurity: $softAPSecurity, softAPChannel: $softAPChannel, softAPSSID: $softAPSSID, softAPPassword: $softAPPassword}';
  }
}

class BlufiScanSSIDsResult extends EspBlufiData {
  final int status;
  final List<BlufiScanSSIDResult> results;

  BlufiScanSSIDsResult({
    required this.status,
    required this.results,
  });

  factory BlufiScanSSIDsResult.fromJson(Map<String, dynamic> json) {
    return BlufiScanSSIDsResult(
      status: json['status'],
      results: (json['results'] as List).map((e) => BlufiScanSSIDResult.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'BlufiScanSSIDResults{status: $status, results: $results}';
  }
}

class BlufiScanSSIDResult {
  final String ssid;
  final int type;
  final int rssi;

  BlufiScanSSIDResult({
    required this.ssid,
    required this.type,
    required this.rssi,
  });

  factory BlufiScanSSIDResult.fromJson(Map<String, dynamic> json) {
    return BlufiScanSSIDResult(
      ssid: json['ssid'],
      type: json['type'],
      rssi: json['rssi'],
    );
  }

  @override
  String toString() {
    return 'BlufiScanSSIDResult{ssid: $ssid, type: $type, rssi: $rssi}';
  }
}


class BlufiDeviceVersion extends EspBlufiData {
  final int status;
  final String version;

  BlufiDeviceVersion({
    required this.status,
    required this.version,
  });

  factory BlufiDeviceVersion.fromJson(Map<String, dynamic> json) {
    return BlufiDeviceVersion(
      status: json['status'],
      version: json['version'],
    );
  }

  @override
  String toString() {
    return 'BlufiDeviceVersion{status: $status, version: $version}';
  }
}

class BlufiPostCustomDataResult extends EspBlufiData {
  final String data;
  final int status;

  BlufiPostCustomDataResult({
    required this.data,
    required this.status,
  });

  factory BlufiPostCustomDataResult.fromJson(Map<String, dynamic> json) {
    return BlufiPostCustomDataResult(
      data: json['data'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'BlufiPostCustomDataResult{data: $data, status: $status}';
  }
}

class BlufiReceiveCustomData extends EspBlufiData {
  final int status;
  final String data;

  BlufiReceiveCustomData({
    required this.status,
    required this.data,
  });

  factory BlufiReceiveCustomData.fromJson(Map<String, dynamic> json) {
    return BlufiReceiveCustomData(
      status: json['status'],
      data: json['data'],
    );
  }

  @override
  String toString() {
    return 'BlufiReceiveCustomData{status: $status, data: $data}';
  }
}

class BlufiError extends EspBlufiData {
  final int? errorCode;

  BlufiError({
    required this.errorCode,
  });

  factory BlufiError.fromJson(Map<String, dynamic> json) {
    return BlufiError(
      errorCode: json['err_code'],
    );
  }

  @override
  String toString() {
    return 'BlufiError{errorCode: $errorCode}';
  }
}