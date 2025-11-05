/// Base-114 Encoding Symbol Tables
/// Uses GSM-7 compatible character set for SMS transmission
class EncodingTables {
  /// Base-114 symbol table (GSM-7 compatible characters)
  /// These 114 characters are safe for SMS transmission
  static const List<String> base114Symbols = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', // 0-9
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', // 10-19
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', // 20-29
    'U', 'V', 'W', 'X', 'Y', 'Z', // 30-35
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', // 36-45
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', // 46-55
    'u', 'v', 'w', 'x', 'y', 'z', // 56-61
    ' ', '!', '"', '#', '\$', '%', '&', "'", '(', ')', // 62-71
    '*', '+', ',', '-', '.', '/', ':', ';', '<', '=', // 72-81
    '>', '?', '@', '[', '\\', ']', '^', '_', '`', '{', // 82-91
    '|', '}', '~', '¡', '£', '¤', '¥', '§', '¿', 'Ä', // 92-101
    'Å', 'Æ', 'Ç', 'É', 'Ñ', 'Ö', 'Ø', 'Ü', 'ß', 'à', // 102-111
    'ä', 'å', // 112-113
  ];

  /// Reverse lookup map for fast decoding
  static final Map<String, int> symbolToIndex = {
    for (var i = 0; i < base114Symbols.length; i++) base114Symbols[i]: i,
  };

  /// SMS chunk metadata markers
  static const String chunkStartMarker = '<<<';
  static const String chunkEndMarker = '>>>';
  static const String chunkSeparator = ':';

  /// Maximum SMS length (GSM-7 encoding)
  static const int maxSmsLength = 160;

  /// Safe chunk size to account for metadata
  static const int safeChunkSize = 140;
}
