import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationManager
{
  static bool get isAuthenticationEnabled => Hive.box("preferences").get("appLockEnabled") ?? false;

  static set isAuthenticationEnabled(bool enabled) => Hive.box("preferences").put("appLockEnabled", enabled);

  static Future<bool> authenticate() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();

    bool didAuthenticate = await localAuthentication.authenticateWithBiometrics(
      localizedReason: "Accedi"
    );

    return didAuthenticate;
  }
}