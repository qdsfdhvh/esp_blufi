import 'package:esp_blufi/esp_blufi.dart';
import 'package:esp_blufi/esp_blufi_data.dart';
import 'package:esp_blufi_example/device_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DeviceListPageState();
  }
}

class _DeviceListPageState extends State<DeviceListPage> {
  final _espBlufiPlugin = EspBlufi();

  bool _isScanning = false;

  final Map<String, ScanResult> _scanResults = {};

  @override
  void initState() {
    super.initState();
    _espBlufiPlugin.addMessageReceived(
      callback: _onMessageReceived,
    );
    _startScan();
  }

  @override
  void dispose() {
    _espBlufiPlugin.removeMessageReceived(
      callback: _onMessageReceived,
    );
    super.dispose();
  }

  void _onMessageReceived(EspBlufiData data) {
    switch (data) {
          case ScanResult():
            if (_scanResults.containsKey(data.address)) {
              final oldData = _scanResults[data.address]!;
              if (oldData.name != data.name || oldData.rssi != data.rssi) {
                _scanResults[data.address] = data;
                setState(() {});
              }
            } else {
              _scanResults[data.address] = data;
              setState(() {});
            }
            break;
          default:
            // do nothing
            break;
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP BLUFI DEMO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final key = _scanResults.keys.elementAt(index);
                final data = _scanResults[key]!;
                return ListTile(
                  title: Text(data.name),
                  subtitle: Text(data.address),
                  trailing: Text('${data.rssi}'),
                  onTap: () async {
                    var waitToRefreshScan = false;
                    if (_isScanning) {
                      _stopScan();
                      waitToRefreshScan = true;
                    }
                    await Navigator.push(context, CupertinoPageRoute(builder: (_) {
                      return DeviceDetailPage(
                        deviceAddress: data.address,
                        deviceName: data.name,
                      );
                    }));
                    if (waitToRefreshScan) {
                      _startScan();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isScanning ? _stopScan : _startScan,
            child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    final success = await _espBlufiPlugin.startScan(filterString: 'BLUFI');
    if (success ?? false) {
      setState(() {
        _scanResults.clear();
        _isScanning = true;
      });
    }
  }

  Future<void> _stopScan() async {
    final success = await _espBlufiPlugin.stopScan();
    if (success) {
      setState(() {
        _isScanning = false;
      });
    }
  }
}
