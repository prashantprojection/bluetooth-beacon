import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
    // Required on Android, even if you're not using location data directly
  ].request();

  if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
      statuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
      statuses[Permission.location] != PermissionStatus.granted) {
    // Handle permission denial
    print('Bluetooth or location permissions denied');
  }
}