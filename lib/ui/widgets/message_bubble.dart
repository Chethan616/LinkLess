import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/colors.dart';

/// Message bubble widget for displaying sent/received content
/// Follows flat design principles with no gradients
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSent;
  final DateTime timestamp;
  final VoidCallback? onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSent,
    required this.timestamp,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSent) _buildAvatar(isDark, false),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                        : (isDark
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSent
                          ? Colors.transparent
                          : (isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFE0E0E0)),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isSent
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isSent) _buildAvatar(isDark, true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isSent) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSent
            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
            : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSent ? CupertinoIcons.person_fill : CupertinoIcons.phone_fill,
        size: 16,
        color: isSent
            ? (isDark ? Colors.black : Colors.white)
            : (isDark ? AppColors.darkText : AppColors.lightText),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Content display bubble for showing webpage content
class ContentBubble extends StatelessWidget {
  final String content;
  final String? url;
  final bool isLoading;

  const ContentBubble({
    Key? key,
    required this.content,
    this.url,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary.withOpacity(0.15)
                    : AppColors.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimary.withOpacity(0.2)
                          : AppColors.lightPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      CupertinoIcons.globe,
                      size: 16,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      url!,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.darkPrimary.withOpacity(0.15),
                                  AppColors.darkPrimary.withOpacity(0.05),
                                ]
                              : [
                                  AppColors.lightPrimary.withOpacity(0.1),
                                  AppColors.lightPrimary.withOpacity(0.02),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fetching content...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SelectableText(
              content,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
        ],
      ),
    );
  }
}
