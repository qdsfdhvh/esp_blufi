import 'package:esp_blufi/esp_blufi.dart';
import 'package:esp_blufi/esp_blufi_data.dart';
import 'package:esp_blufi_example/wifi_scan_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceDetailPage extends StatefulWidget {
  final String deviceAddress;
  final String deviceName;

  const DeviceDetailPage({
    required this.deviceAddress,
    required this.deviceName,
    super.key,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceDetailPage>
    with SingleTickerProviderStateMixin {
  final _espBlufiPlugin = EspBlufi();

  final List<String> _consoles = [];

  bool _isConnected = false;
  bool _isWaitingConnect = false;

  @override
  void initState() {
    super.initState();
    _espBlufiPlugin.addMessageReceived(
      callback: _onMessageReceived,
    );
  }

  @override
  void dispose() {
    _espBlufiPlugin.removeMessageReceived(
      callback: _onMessageReceived,
    );
    if (_isConnected) {
      _espBlufiPlugin.requestCloseConnection();
    }
    super.dispose();
  }

  void _onMessageReceived(EspBlufiData data) {
    switch (data) {
      case ConnectionStateChange():
        if (data.address == widget.deviceAddress && data.status == 0) {
          setState(() {
            // 0: discconnect 1:connecting 2:connected
            _isConnected = data.state == 2;
            _isWaitingConnect = false;
          });
        } else {
          setState(() {
            _isConnected = false;
            _isWaitingConnect = false;
          });
        }
        break;
      case MtuChange():
        setState(() {
          _consoles.add('MTU: ${data.mtu}');
        });
        break;
      case SetNotification():
        // do nothing
        break;
      case BlufiGattPrepared():
        // do nothing
        break;
      case BlufiDeviceVersion():
        setState(() {
          if (data.status == 0) {
            _consoles.add('Device Version: ${data.version}');
          } else {
            _consoles.add('Failed to get device version');
          }
        });
        break;
      case BlufiScanSSIDsResult():
        setState(() {
          if (data.status == 0) {
            _consoles.add('Wifi Scan Results(${data.results.length}):');
            for (final ssid in data.results) {
              _consoles.add(
                  '  ${ssid.ssid} ${ssid.type == 1 ? 'Wifi' : 'type:${ssid.type}'} rssi:${ssid.rssi}');
            }
          } else {
            _consoles.add('Failed to get wifi scan result');
          }
        });
        break;
      case BlufiDeviceStatusResponse():
        if (data.opMode == 1 || data.opMode == 3) {
          if (data.staConnectionStatus == 0) {
            setState(() {
              _consoles.add('Device connected, ');
              _consoles.add('  BSSID: ${data.staBSSID}');
              _consoles.add('  SSID: ${data.staSSID}');
              // _consoles.add('  PASSWORD: ${data.staPassword}');
            });
          } else {
            setState(() {
              _consoles.add(
                  'Device not connected, opMode: ${data.opMode}, staConnectionStatus: ${data.staConnectionStatus}');
            });
          }
        } else {
          setState(() {
            _consoles.add('Device not connected, opMode: ${data.opMode}');
          });
        }
      case BlufiPostCustomDataResult():
        setState(() {
          if (data.status == 0) {
            _consoles.add("Success to send -> '${data.data}'");
          } else {
            _consoles.add("Failed to send -> '${data.data}'");
          }
        });
        break;
      case BlufiError():
        setState(() {
          _isWaitingConnect = false;
          _consoles.add('Error: ${data.errorCode}');
        });
        break;
      default:
        setState(() {
          _consoles.add(data.toString());
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.deviceName),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Stack(
        children: [
          _body(),
          if (_isWaitingConnect)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _consoles.length,
            itemBuilder: (context, index) {
              return Text(_consoles[index]);
            },
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            _button(
              text: 'Connect',
              enabled: !_isConnected,
              onPressed: () async {
                setState(() {
                  _consoles.add('Connecting...');
                });
                final success = await _espBlufiPlugin.connect(
                    deviceAddress: widget.deviceAddress);
                if (success) {
                  setState(() {
                    _consoles.add('Connected Successfully');
                    _isWaitingConnect = true;
                  });
                } else {
                  setState(() {
                    _consoles.add('Failed to connect');
                  });
                }
              },
            ),
            _button(
              text: 'Disconnect',
              enabled: _isConnected && !_isWaitingConnect,
              onPressed: () async {
                setState(() {
                  _consoles.add('Disconnecting...');
                });
                final success = await _espBlufiPlugin.requestCloseConnection();
                if (success) {
                  setState(() {
                    _consoles.add('Disconnected Successfully');
                    _isWaitingConnect = true;
                  });
                } else {
                  setState(() {
                    _consoles.add('Failed to disconnect');
                  });
                }
              },
            ),
            _button(
              text: 'Device Version',
              enabled: _isConnected,
              onPressed: () {
                _espBlufiPlugin.requestDeviceVersion();
              },
            ),
            _button(
              text: 'Device Status',
              enabled: _isConnected,
              onPressed: () {
                _espBlufiPlugin.requestDeviceStatus();
              },
            ),
            _button(
              text: 'Wifi Scan',
              enabled: _isConnected,
              onPressed: () {
                _espBlufiPlugin.requestDeviceWifiScan();
              },
            ),
            _button(
              text: 'Config',
              enabled: _isConnected,
              onPressed: () async {
                // _espBlufiPlugin.configProvision(
                //   username: 'admin',
                //   password: 'admin',
                // );

                final map = await Navigator.push<Map<String, String>>(
                  context,
                  CupertinoPageRoute(builder: (_) {
                    return const WifiScanPage();
                  }),
                );
                if (map != null &&
                    map.containsKey('ssid') &&
                    map.containsKey('password')) {
                  _espBlufiPlugin.configProvision(
                    ssid: map['ssid']!,
                    password: map['password']!,
                  );
                }
              },
            ),
            _button(
              text: 'Custom Data',
              enabled: _isConnected,
              onPressed: () {
                _espBlufiPlugin.sendCustomData(data: 'Hello');
              },
            ),
            _button(
              text: 'Security',
              enabled: _isConnected,
              onPressed: () {
                _espBlufiPlugin.negotiateSecurity();
              },
            ),
            _button(
              text: 'Clear',
              enabled: _consoles.isNotEmpty,
              onPressed: () {
                setState(() {
                  _consoles.clear();
                });
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _button({
    required String text,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: Text(text),
    );
  }
}
