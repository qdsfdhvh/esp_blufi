import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiScanPage extends StatefulWidget {
  const WifiScanPage({Key? key}) : super(key: key);

  @override
  State<WifiScanPage> createState() => _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
  List<WiFiAccessPoint> _accessPoints = <WiFiAccessPoint>[];
  WiFiAccessPoint? _selectAccessPoints;

  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  bool _isShowPassword = false;

  late final TextEditingController _passwordController;
  bool _isCanConnect = false;

  bool _isFilter5G = true;

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
    _startListeningToScanResults(context);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _stopListeningToScanResults();
    super.dispose();
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    // check if can-getScannedResults
    final can = await WiFiScan.instance.canGetScannedResults();
    // if can-not, then show error
    if (can != CanGetScannedResults.yes) {
      if (context.mounted) {
        _toast("Cannot get scanned results: $can");
      }
      _accessPoints = <WiFiAccessPoint>[];
      return false;
    }
    return true;
  }

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable
          .listen((result) => setState(() => _accessPoints = result));
    }
  }

  void _stopListeningToScanResults() {
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Wifi'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          const Text('Filter 5G', style: TextStyle(
            fontSize: 16,
          )),
          const SizedBox(width: 4),
          Switch(value: _isFilter5G, onChanged: (value) {
            setState(() {
              _isFilter5G = value;
            });
          }),
           const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320), // 动画时长
        child: _selectAccessPoints == null
            ? _wifiScanContent()
            : _wifiConnectContent(_selectAccessPoints!),
      ),
    );
  }

  Widget _wifiScanContent() {
    if (_accessPoints.isEmpty) {
      return const Center(
        child: Text("NO SCANNED RESULTS"),
      );
    }
    final displayAccessPoints = _isFilter5G
        ? _accessPoints.where((element) => element.frequency < 5000).toList()
        : _accessPoints;
    return ListView.separated(
      itemCount: displayAccessPoints.length,
      itemBuilder: (context, index) {
        final accessPoint = displayAccessPoints[index];
        final is5GHz = accessPoint.frequency >= 5000;
        return ListTile(
          onTap: () {
            setState(() {
              _selectAccessPoints = accessPoint;
            });
          },
          title: Text(accessPoint.ssid),
          subtitle: Text(accessPoint.bssid),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (is5GHz) _label5G(),
              if (is5GHz) const SizedBox(width: 8),
              Text("${accessPoint.level} dBm"),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          color: Colors.black12,
        );
      },
    );
  }

  Widget _wifiConnectContent(WiFiAccessPoint accessPoint) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  accessPoint.ssid,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (accessPoint.frequency >= 5000) _label5G(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Input Password",
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isShowPassword = !_isShowPassword;
                  });
                },
                icon: Icon(_isShowPassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded),
              ),
            ),
            obscureText: !_isShowPassword,
            maxLines: 1,
            onChanged: (value) {
              setState(() {
                _isCanConnect = value.isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isCanConnect
                ? () {
                    Navigator.pop(context, {
                      'ssid': accessPoint.ssid,
                      'password': _passwordController.text,
                    });
                  }
                : null,
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

  Widget _label5G() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          "5G",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
