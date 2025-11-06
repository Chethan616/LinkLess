import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/app_mode_service.dart';
import '../../services/sms_service.dart';
import '../../core/color_palette.dart';
import '../widgets/liquid_glass_components.dart';

/// Settings Tab - Configure app mode and preferences
class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final AppModeService _appModeService = AppModeService.instance;
  final SmsService _smsService = SmsService.instance;

  AppMode _currentMode = AppMode.client;
  String? _gatewayNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    _currentMode = await _appModeService.getMode();
    _gatewayNumber = await _appModeService.getGatewayNumber();

    setState(() => _isLoading = false);
  }

  Future<void> _switchMode(AppMode newMode) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch App Mode?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newMode == AppMode.gateway
                  ? 'Switch to Gateway Mode?\n\nYour phone will:'
                  : 'Switch to Client Mode?\n\nYour phone will:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (newMode == AppMode.gateway) ...[
              const Text('✅ Receive URL requests via SMS'),
              const Text('✅ Fetch webpages using internet'),
              const Text('✅ Send content back via SMS'),
              const SizedBox(height: 8),
              const Text(
                '⚠️ This phone will act as a gateway server',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ] else ...[
              const Text('✅ Browse the web via SMS'),
              const Text('✅ Send URL requests to gateway'),
              const Text('✅ Receive webpage content'),
              const SizedBox(height: 8),
              const Text(
                '⚠️ You need a gateway phone to use this mode',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
            ),
            child: const Text('Switch Mode'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show restart requirement dialog
    await _appModeService.setMode(newMode);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: ColorPalette.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Mode Changed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newMode == AppMode.gateway
                  ? '🌐 Gateway Mode Activated'
                  : '📱 Client Mode Activated',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Restart Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please close and reopen the app for changes to take effect.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _editGatewayNumber() async {
    final controller = TextEditingController(text: _gatewayNumber ?? '');

    final newNumber = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gateway Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the phone number of your Gateway device:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+1234567890',
                prefixIcon: Icon(CupertinoIcons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '💡 Tip: Make sure the gateway phone is in Gateway Mode and has internet connection.',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newNumber != null && newNumber.isNotEmpty) {
      await _appModeService.setGatewayNumber(newNumber);
      _smsService.setGatewayNumber(newNumber);
      setState(() {
        _gatewayNumber = newNumber;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gateway number saved: $newNumber'),
          backgroundColor: ColorPalette.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Header
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorPalette.textPrimaryDark
                  : ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your Linkless experience',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? ColorPalette.textSecondaryDark
                  : ColorPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // App Mode Section
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorPalette.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.device_phone_portrait,
                        color: ColorPalette.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'App Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'How this device operates',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? ColorPalette.textSecondaryDark
                                  : ColorPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Client Mode Option
                _buildModeOption(
                  title: '📱 Client Mode',
                  description: 'Browse the web via SMS',
                  isSelected: _currentMode == AppMode.client,
                  onTap: () => _switchMode(AppMode.client),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Gateway Mode Option
                _buildModeOption(
                  title: '🌐 Gateway Mode',
                  description: 'Fetch web content for others',
                  isSelected: _currentMode == AppMode.gateway,
                  onTap: () => _switchMode(AppMode.gateway),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Client Mode Settings
          if (_currentMode == AppMode.client) ...[
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorPalette.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                          color: ColorPalette.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Gateway Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_gatewayNumber != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.phone_fill,
                            color: ColorPalette.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gateway Number',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? ColorPalette.textSecondaryDark
                                        : ColorPalette.textSecondary,
                                  ),
                                ),
                                Text(
                                  _gatewayNumber!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _editGatewayNumber,
                            icon: const Icon(CupertinoIcons.pencil),
                            tooltip: 'Edit',
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    LiquidGlassButton(
                      text: 'Set Gateway Number',
                      onTap: _editGatewayNumber,
                      icon: CupertinoIcons.add_circled_solid,
                      height: 48,
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Gateway Mode Info
          if (_currentMode == AppMode.gateway) ...[
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorPalette.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.checkmark_shield_fill,
                          color: ColorPalette.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Gateway Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorPalette.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.antenna_radiowaves_left_right,
                              color: ColorPalette.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Gateway Active',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This device will receive URL requests via SMS, fetch webpages, and send content back.',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '📋 Requirements:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '✅ Keep app running in background',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          '✅ Maintain internet connection',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          '✅ Grant SMS permissions',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // About Section
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.info_circle_fill,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About Linkless',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Browse the web without internet using SMS relay',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? ColorPalette.textSecondaryDark
                        : ColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Version 1.0.0 (Test Mode)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorPalette.primary.withOpacity(0.15)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorPalette.primary
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? ColorPalette.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? ColorPalette.textSecondaryDark
                          : ColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: ColorPalette.primary,
                size: 28,
              )
            else
              Icon(
                CupertinoIcons.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
