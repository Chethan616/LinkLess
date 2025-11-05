import 'dart:typed_data';
import 'dart:convert';
import '../../core/constants/encoding_tables.dart';

/// Base-114 Encoder
/// Converts binary data to Base-114 encoded string using GSM-7 symbols
class Base114Encoder {
  /// Encode bytes to Base-114 string
  static String encode(Uint8List data) {
    if (data.isEmpty) return '';

    final symbols = EncodingTables.base114Symbols;
    final base = symbols.length; // 114
    final buffer = StringBuffer();

    // Convert bytes to big integer value
    var value = BigInt.zero;
    for (var byte in data) {
      value = (value << 8) | BigInt.from(byte);
    }

    // Convert to base-114
    if (value == BigInt.zero) {
      return symbols[0];
    }

    while (value > BigInt.zero) {
      final remainder = (value % BigInt.from(base)).toInt();
      buffer.write(symbols[remainder]);
      value = value ~/ BigInt.from(base);
    }

    // Reverse the string (we built it backwards)
    return buffer.toString().split('').reversed.join();
  }

  /// Encode string to Base-114 using UTF-8 encoding
  static String encodeString(String text) {
    // Use UTF-8 encoding instead of UTF-16 code units
    return encode(Uint8List.fromList(utf8.encode(text)));
  }
}
