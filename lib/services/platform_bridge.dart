import 'package:flutter/services.dart';

/// PlatformBridge handles communication between Dart and Kotlin
/// Used for web fetching operations on the Gateway device
class PlatformBridge {
  static const MethodChannel _channel = MethodChannel('linkless_gateway');

  // Singleton instance
  static PlatformBridge? _instance;
  static PlatformBridge get instance {
    _instance ??= PlatformBridge._();
    return _instance!;
  }

  PlatformBridge._();

  /// Fetch web page content via Kotlin/Jsoup
  /// This is used by the Gateway device to retrieve web pages
  ///
  /// Parameters:
  /// - url: The URL to fetch
  ///
  /// Returns:
  /// - Plain text content of the webpage (up to 1200 characters)
  Future<String> fetchWebContent(String url) async {
    try {
      final String result = await _channel.invokeMethod('fetchWeb', {
        'url': url,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to fetch web content: ${e.message}');
    }
  }

  /// Check if the platform bridge is available
  /// Useful for determining if we're on a platform that supports the bridge
  Future<bool> isAvailable() async {
    try {
      await _channel.invokeMethod('ping');
      return true;
    } catch (e) {
      return false;
    }
  }
}
