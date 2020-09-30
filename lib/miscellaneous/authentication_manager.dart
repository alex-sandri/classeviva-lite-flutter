import 'package:classeviva_lite/miscellaneous/PreferencesManager.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationManager
{
  static bool get isAuthenticationEnabled => PreferencesManager.get("appLockEnabled") ?? false;

  static set isAuthenticationEnabled(bool enabled) => PreferencesManager.set("appLockEnabled", enabled);

  static Future<bool> authenticate() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();

    bool didAuthenticate = await localAuthentication.authenticateWithBiometrics(
      localizedReason: "Accedi"
    );

    return didAuthenticate;
  }
}