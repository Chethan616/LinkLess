import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

/// Brotli Compression/Decompression Service
/// Note: For demo purposes, using GZip. Replace with proper Brotli when available
class BrotliService {
  /// Compress data using GZip (placeholder for Brotli)
  static Uint8List compress(Uint8List data) {
    try {
      final compressed = GZipCodec().encode(data);
      return Uint8List.fromList(compressed);
    } catch (e) {
      throw Exception('Compression failed: $e');
    }
  }

  /// Decompress GZip-compressed data (placeholder for Brotli)
  static Uint8List decompress(Uint8List compressedData) {
    try {
      final decompressed = GZipCodec().decode(compressedData);
      return Uint8List.fromList(decompressed);
    } catch (e) {
      throw Exception('Decompression failed: $e');
    }
  }

  /// Compress string and return compressed bytes
  static Uint8List compressString(String text) {
    final bytes = Uint8List.fromList(utf8.encode(text));
    return compress(bytes);
  }

  /// Decompress bytes and return string
  static String decompressString(Uint8List compressedData) {
    final decompressed = decompress(compressedData);
    return utf8.decode(decompressed);
  }
}
