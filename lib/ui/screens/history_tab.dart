import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/color_palette.dart';
import '../widgets/liquid_glass_components.dart';

/// History Tab - Displays browsing history with Liquid Glass UI
/// Shows previously requested URLs with timestamps
class HistoryTab extends StatefulWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<HistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('browsing_history') ?? [];

      setState(() {
        _history =
            historyJson
                .map((item) => HistoryItem.fromJson(json.decode(item)))
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .map((item) => json.encode(item.toJson()))
          .toList();
      await prefs.setStringList('browsing_history', historyJson);
    } catch (e) {
      // Handle save error
    }
  }

  Future<void> _deleteHistoryItem(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    await _saveHistory();
  }

  Future<void> _clearAllHistory() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorPalette.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColorPalette.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          'Clear All History',
          style: TextStyle(
            color: isDark ? ColorPalette.textPrimary : ColorPalette.primaryDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all browsing history?',
          style: TextStyle(
            color: isDark
                ? ColorPalette.textSecondary
                : ColorPalette.primaryDark.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? ColorPalette.textSecondary
                  : ColorPalette.primaryDark,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: ColorPalette.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _history.clear();
      });
      await _saveHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('History cleared'),
            backgroundColor: isDark
                ? ColorPalette.glassDark
                : ColorPalette.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primary),
        ),
      );
    }

    if (_history.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header with clear all button
        if (_history.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_history.length} ${_history.length == 1 ? "item" : "items"}',
                  style: TextStyle(
                    color: isDark
                        ? ColorPalette.textSecondary
                        : ColorPalette.primaryDark.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                LiquidGlassButton(
                  text: 'Clear All',
                  icon: CupertinoIcons.trash,
                  onTap: _clearAllHistory,
                  isPrimary: false,
                ),
              ],
            ),
          ),

        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              return _buildHistoryItem(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(HistoryItem item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(item.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorPalette.error.withOpacity(0.7), ColorPalette.error],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          CupertinoIcons.trash_fill,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) => _deleteHistoryItem(index),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(0),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${item.url}'),
              backgroundColor: isDark
                  ? ColorPalette.glassDark
                  : ColorPalette.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorPalette.primary.withOpacity(0.15),
                  ColorPalette.primaryLight.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.globe,
              color: ColorPalette.primary,
              size: 22,
            ),
          ),
          title: Text(
            item.url,
            style: TextStyle(
              color: isDark
                  ? ColorPalette.textPrimary
                  : ColorPalette.primaryDark,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.clock_fill,
                  size: 12,
                  color: isDark
                      ? ColorPalette.textSecondary
                      : ColorPalette.primaryDark.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(item.timestamp),
                  style: TextStyle(
                    color: isDark
                        ? ColorPalette.textSecondary
                        : ColorPalette.primaryDark.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.trash,
              color: ColorPalette.error.withOpacity(0.8),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorPalette.primary.withOpacity(0.15),
                    ColorPalette.primaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.time,
                size: 72,
                color: ColorPalette.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No History Yet',
              style: TextStyle(
                color: isDark
                    ? ColorPalette.textPrimary
                    : ColorPalette.primaryDark,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              'Your browsing history will appear here',
              style: TextStyle(
                color: isDark
                    ? ColorPalette.textSecondary
                    : ColorPalette.primaryDark.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// History item model
class HistoryItem {
  final String url;
  final DateTime timestamp;

  HistoryItem({required this.url, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'url': url,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    url: json['url'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
