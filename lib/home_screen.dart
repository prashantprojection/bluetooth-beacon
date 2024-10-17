import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_beacon/controller.dart';
import 'package:bluetooth_beacon/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothController blController = BluetoothController();
  bool _isConnecting = false;

  @override
  void initState() {
    requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Bluetooth Beacon",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth, size: 40, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        "Scan for Devices",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Bluetooth devices list
                  Expanded(
                    child: StreamBuilder<List<ScanResult>>(
                      stream: blController.device,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (ctx, index) {
                              final data = snapshot.data![index];
                              return _buildDeviceCard(data);
                            },
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.devices,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: 20),
                                Text(
                                  "No Devices Found!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      blController.scanForDevices();
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    icon: Icon(Icons.search, color: Colors.white),
                    label: Text(
                      "Start Scanning",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Overlay for Connection in Progress
            if (_isConnecting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Connecting...",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(ScanResult data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: data.device.isConnected ? Colors.green : Colors.grey,
          size: 40,
        ),
        title: Text(
          data.device.name.isNotEmpty ? data.device.name : 'Unknown Device',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          data.device.remoteId.toString(),
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: IconButton(
          onPressed: () async {
            SnackBar msg = SnackBar(content: Text(""));
            if (data.device.isConnected) {
              await blController.disconnectToDevice(data.device).then((val) {
                msg = val;
              });
            } else {
              setState(() {
                _isConnecting = true; // Show overlay
              });
              await blController.connectToDevice(data.device).then((val) {
                msg = val;
              });

              setState(() {
                _isConnecting = false; // Hide overlay after connection attempt
              });
              ScaffoldMessenger.of(context).showSnackBar(msg);
            }
          },
          icon: Icon(
            data.device.isConnected ? Icons.link : Icons.link_off,
            color: data.device.isConnected ? Colors.green : Colors.redAccent,
            size: 28,
          ),
        ),
      ),
    );
  }
}
