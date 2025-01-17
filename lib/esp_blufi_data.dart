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
        return BlufiScanSSIDResults.fromJson(value);
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
}

class BlufiDeviceStatusResponse extends EspBlufiData {
  final int status;
  final int opCode;
  final int subCode;
  final int value;

  BlufiDeviceStatusResponse({
    required this.status,
    required this.opCode,
    required this.subCode,
    required this.value,
  });

  factory BlufiDeviceStatusResponse.fromJson(Map<String, dynamic> json) {
    return BlufiDeviceStatusResponse(
      status: json['status'],
      opCode: json['op_code'],
      subCode: json['sub_code'],
      value: json['value'],
    );
  }
}

class BlufiScanSSIDResults extends EspBlufiData {
  final int status;
  final List<BlufiScanSSIDResult> results;

  BlufiScanSSIDResults({
    required this.status,
    required this.results,
  });

  factory BlufiScanSSIDResults.fromJson(Map<String, dynamic> json) {
    return BlufiScanSSIDResults(
      status: json['status'],
      results: (json['results'] as List).map((e) => BlufiScanSSIDResult.fromJson(e)).toList(),
    );
  }
}

class BlufiScanSSIDResult {
  final String address;
  final String name;
  final int rssi;

  BlufiScanSSIDResult({
    required this.address,
    required this.name,
    required this.rssi,
  });

  factory BlufiScanSSIDResult.fromJson(Map<String, dynamic> json) {
    return BlufiScanSSIDResult(
      address: json['address'],
      name: json['name'],
      rssi: json['rssi'],
    );
  }
}


class BlufiDeviceVersion extends EspBlufiData {
  final int status;
  final int version;

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
}

class BlufiError extends EspBlufiData {
  final int errorCode;

  BlufiError({
    required this.errorCode,
  });

  factory BlufiError.fromJson(Map<String, dynamic> json) {
    return BlufiError(
      errorCode: json['error_code'],
    );
  }
}