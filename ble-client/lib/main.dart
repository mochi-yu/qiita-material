import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
  setup();
}

void setup() async {
  // Bluetoothが有効でパーミッションが許可されるまで待機
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _deviceNameMap = {"Key": "鍵", "Remote": "リモコン"};
  String _displayText = "近くにデバイスがありません。";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));

    int maxRssi = -1000000;
    String maxRssiDevice = "";

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // debugPrint(r.advertisementData.advName);
        if(_deviceNameMap.containsKey(r.advertisementData.advName)) {
          // 最も近いものを記録しておく
          if(r.rssi > maxRssi) {
            maxRssi = r.rssi;
            maxRssiDevice = _deviceNameMap[r.advertisementData.advName]!;

            setState(() {
              _displayText = "近くに$maxRssiDeviceがあります。";
            });
          }
        }
      }
    });

    // Restart the scan every 4 seconds to keep it continuous
    Future.delayed(const Duration(seconds: 3), () {
      if(maxRssi == -1000000) {
        setState(() {
          _displayText = "近くにデバイスがありません。";
        });
      }
      // 再度スキャンする
      FlutterBluePlus.stopScan();
      startScan();
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("近くのデバイスを探します"),
            Text(_displayText, style: const TextStyle(fontSize: 25),),
          ],
        ),
      ),
    );
  }
}
