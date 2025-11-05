import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/colors.dart';

/// Custom input field widget with Cupertino styling
/// Follows the flat design principles from app.md
class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSubmitted;
  final VoidCallback? onSendPressed;
  final bool enabled;
  final int maxLines;
  final TextInputType keyboardType;

  const CustomInputField({
    Key? key,
    required this.controller,
    this.hintText = 'Enter text...',
    this.onSubmitted,
    this.onSendPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.compass,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          if (onSendPressed != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: enabled ? onSendPressed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: enabled
                      ? LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.darkPrimary,
                                  AppColors.darkPrimary.withOpacity(0.8),
                                ]
                              : [
                                  AppColors.lightPrimary,
                                  AppColors.lightPrimary.withOpacity(0.8),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !enabled
                      ? (isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFD1D1D6))
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  CupertinoIcons.arrow_up,
                  color: enabled
                      ? (isDark ? Colors.black87 : Colors.white)
                      : (isDark
                            ? const Color(0xFF48484A)
                            : const Color(0xFF8E8E93)),
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple text input field variant without send button
class SimpleInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const SimpleInputField({
    Key? key,
    required this.controller,
    this.hintText = 'Enter text...',
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(hintText: hintText, filled: true),
      onChanged: onChanged,
    );
  }
}
