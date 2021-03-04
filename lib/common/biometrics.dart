import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class Biometrics {
  // static bool _canCheckBiometrics = false;
  static List<BiometricType> _availableBiometrics;

  /*
  static bool get canCheckBiometrics {
    return _canCheckBiometrics;
  }
  */

  /*
  static bool get canCheckFingerprint {
    return (_availableBiometrics != null) &&
        (_availableBiometrics.contains(BiometricType.fingerprint));
  }
  */

  static bool get canCheckBiometrics {
    return (_availableBiometrics != null) && (_availableBiometrics.length > 0);
  }

  static Future<void> checkBiometricsInfo() async {
    LocalAuthentication auth = LocalAuthentication();
    try {
      // _canCheckBiometrics = await auth.canCheckBiometrics;
      _availableBiometrics = await auth.getAvailableBiometrics();

      // print('Can check biometrics: $_canCheckBiometrics');
      // print('Available biometrics: $_availableBiometrics');
      // print('Can check fingerprint: $canCheckFingerprint');
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
