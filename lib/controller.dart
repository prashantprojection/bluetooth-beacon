import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController{

  List<ScanResult> result = [];

  Future<void> checkBluetoothState() async {
     StreamSubscription subscription = await FlutterBluePlus.adapterState.listen((state){
      if (state != BluetoothAdapterState.on) {
        print('Bluetooth is not on. Please enable it.');
      }
    });


  }

  Future<void> scanForDevices() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 30));

    // Listen to scan results
     FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.remoteId} found! rssi: ${r.rssi}');
      }
    });

    // Stop scanning after a timeout (optional) as startScan timeout will autokill it
    // FlutterBluePlus.stopScan();
  }

Stream<List<ScanResult>> get device => FlutterBluePlus.scanResults;

  Future<SnackBar> connectToDevice(BluetoothDevice device) async {

      try {
        await device.connect();

        print('Connected to ${device.name} , Id: ${device.remoteId}');
        return SnackBar(content: Text("Connected to the Device"),); // Exit the loop if connection is successful
      } catch (e) {
        print('Failed to connect to device .');
    }

    return SnackBar(content: Text("Failed to connect to device. Try again!"),);
  }

  Future<SnackBar> disconnectToDevice(BluetoothDevice device)async{
    try{
      await device.disconnect();
      print('Disconnected from ${device.remoteId}');
      return SnackBar(content: Text("Device Disconnected Successfully."));
    }catch(e){
      print('Some Problem Occured, $e');
    }
    return SnackBar(content: Text("Some Problem occured, Please contact the developer."));
  }

}