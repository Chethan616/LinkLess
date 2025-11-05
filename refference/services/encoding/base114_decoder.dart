import 'dart:typed_data';
import '../../core/constants/encoding_tables.dart';

/// Base-114 Decoder
/// Converts Base-114 encoded string back to binary data
class Base114Decoder {
  /// Decode Base-114 string to bytes
  static Uint8List decode(String encoded) {
    if (encoded.isEmpty) return Uint8List(0);

    final symbolToIndex = EncodingTables.symbolToIndex;
    final base = EncodingTables.base114Symbols.length; // 114

    // Convert base-114 string to big integer
    var value = BigInt.zero;
    for (var i = 0; i < encoded.length; i++) {
      final symbol = encoded[i];
      final index = symbolToIndex[symbol];

      if (index == null) {
        throw FormatException('Invalid Base-114 character: $symbol');
      }

      value = (value * BigInt.from(base)) + BigInt.from(index);
    }

    // Convert big integer to bytes
    if (value == BigInt.zero) {
      return Uint8List.fromList([0]);
    }

    final bytes = <int>[];
    while (value > BigInt.zero) {
      bytes.add((value & BigInt.from(0xFF)).toInt());
      value = value >> 8;
    }

    // Reverse bytes (we built the list backwards)
    return Uint8List.fromList(bytes.reversed.toList());
  }

  /// Decode Base-114 string to UTF-8 string
  static String decodeString(String encoded) {
    final bytes = decode(encoded);
    return String.fromCharCodes(bytes);
  }
}
