import 'package:shared_preferences/shared_preferences.dart';

/// App operating modes
enum AppMode {
  client, // Browse the web via SMS
  gateway, // Fetch web content and send back via SMS
}

/// AppModeService - Manages the app's operating mode (Client or Gateway)
/// This allows a single APK to work as either a browsing client or gateway
class AppModeService {
  static const String _modeKey = 'app_mode';
  static const String _gatewayNumberKey = 'gateway_number';

  // Singleton instance
  static AppModeService? _instance;
  static AppModeService get instance {
    _instance ??= AppModeService._();
    return _instance!;
  }

  AppModeService._();

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the current app mode
  Future<AppMode> getMode() async {
    if (_prefs == null) await initialize();
    final modeString = _prefs!.getString(_modeKey);
    if (modeString == 'gateway') {
      return AppMode.gateway;
    }
    return AppMode.client; // Default to client mode
  }

  /// Set the app mode
  Future<void> setMode(AppMode mode) async {
    if (_prefs == null) await initialize();
    await _prefs!.setString(
      _modeKey,
      mode == AppMode.gateway ? 'gateway' : 'client',
    );
  }

  /// Check if in gateway mode
  Future<bool> isGatewayMode() async {
    return await getMode() == AppMode.gateway;
  }

  /// Check if in client mode
  Future<bool> isClientMode() async {
    return await getMode() == AppMode.client;
  }

  /// Get the saved gateway number (for client mode)
  Future<String?> getGatewayNumber() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_gatewayNumberKey);
  }

  /// Set the gateway number (for client mode)
  Future<void> setGatewayNumber(String? number) async {
    if (_prefs == null) await initialize();
    if (number == null) {
      await _prefs!.remove(_gatewayNumberKey);
    } else {
      await _prefs!.setString(_gatewayNumberKey, number);
    }
  }
}
