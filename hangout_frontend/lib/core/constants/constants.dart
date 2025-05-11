import 'dart:io';

class Constants {
  // Server URLs - 10.0.2.2 is used for Android emulator to reference localhost
  static String _localhost = "http://localhost:8000";
  static String _emulatorHost = "http://10.0.2.2:8000";

  // For physical device testing, replace with your computer's IP address on the network
  // static String _networkHost = "http://192.168.1.x:8000"; // Change to your IP

  static String get backendUri {
    // Try to determine the correct backend URL based on platform
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return _emulatorHost;
    } else {
      // iOS simulator can use localhost directly
      return _localhost;
    }

    // For physical devices, you should uncomment and use _networkHost
    // return _networkHost;
  }
}
