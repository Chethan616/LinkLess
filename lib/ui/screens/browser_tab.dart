import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/sms_service.dart';
import '../../services/crypto_service.dart';
import '../../core/color_palette.dart';
import '../widgets/liquid_glass_components.dart';

/// Browser Tab - Main screen for browsing via SMS with Liquid Glass UI
/// Allows user to enter URLs and displays fetched content
class BrowserTab extends StatefulWidget {
  const BrowserTab({Key? key}) : super(key: key);

  @override
  State<BrowserTab> createState() => _BrowserTabState();
}

class _BrowserTabState extends State<BrowserTab> {
  final TextEditingController _urlController = TextEditingController();
  final SmsService _smsService = SmsService.instance;
  final CryptoService _cryptoService = CryptoService.instance;

  String? _currentContent;
  String? _currentUrl;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize crypto service
      await _cryptoService.initialize();

      // Initialize SMS service
      final hasPermissions = await _smsService.initialize();

      if (!hasPermissions) {
        setState(() {
          _errorMessage =
              'SMS permissions not granted. Please enable SMS permissions.';
        });
        return;
      }

      // Set up message callback
      _smsService.setMessageCallback(_handleIncomingMessage);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  void _handleIncomingMessage(String message, String sender) {
    setState(() {
      _currentContent = message;
      _isLoading = false;
    });

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received response from $sender'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sendRequest() async {
    var url = _urlController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a URL')));
      return;
    }

    // Format URL properly - add https:// if no protocol specified
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // Validate URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || uri.host.isEmpty) {
        throw const FormatException('Invalid URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL format: ${e.toString()}')),
      );
      return;
    }

    if (_smsService.gatewayNumber == null) {
      _showGatewayNumberDialog();
      return;
    }

    if (!_cryptoService.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Crypto service not ready. Please setup encryption keys.',
          ),
          action: SnackBarAction(
            label: 'Setup',
            onPressed: _setupSinglePhoneTesting,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _currentUrl = url;
      _currentContent = null;
      _errorMessage = null;
    });

    try {
      final success = await _smsService.sendRequest(url);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent! Waiting for response...'),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to send SMS request';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _showGatewayNumberDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Gateway Number'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter the phone number of your Gateway device:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+1234567890',
                  prefixIcon: Icon(CupertinoIcons.phone),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Testing with one phone?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can use your own phone number and public key for testing.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _setupSinglePhoneTesting();
                },
                icon: const Icon(CupertinoIcons.device_phone_portrait),
                label: const Text('Setup Single Phone Test'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final number = controller.text.trim();
              if (number.isNotEmpty) {
                _smsService.setGatewayNumber(number);
                Navigator.pop(context);
                _sendRequest();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _setupSinglePhoneTesting() async {
    try {
      // Get the client's public key
      final publicKey = await _cryptoService.getClientPublicKey();

      // Set it as the gateway public key (for testing purposes)
      await _cryptoService.setGatewayPublicKey(publicKey);

      // Show dialog with setup info
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green),
              SizedBox(width: 12),
              Text('Test Mode Setup'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your device is now configured for single-phone testing.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text('Your Public Key:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: SelectableText(
                    publicKey,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
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
                      Row(
                        children: [
                          Icon(CupertinoIcons.info_circle, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Note:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• This is for UI testing only\n'
                        '• You can test the interface and encryption\n'
                        '• SMS messages will be sent to yourself\n'
                        '• For real use, you need a second phone as gateway',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              },
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to setup test mode: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && _errorMessage == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // URL Input Section with Liquid Glass
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LiquidGlassTextField(
                  controller: _urlController,
                  hintText: 'Enter URL (e.g., wikipedia.org)',
                  enabled: _isInitialized && !_isLoading,
                  keyboardType: TextInputType.url,
                  prefixIcon: CupertinoIcons.search,
                  suffixIcon: _isLoading
                      ? CupertinoIcons.hourglass
                      : CupertinoIcons.arrow_right_circle_fill,
                  onSubmitted: (_) => _sendRequest(),
                  onSuffixTap: _sendRequest,
                ),
                if (_smsService.gatewayNumber != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.phone_fill,
                          size: 14,
                          color: ColorPalette.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gateway: ${_smsService.gatewayNumber}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? ColorPalette.textPrimaryDark
                                      : ColorPalette.textPrimary,
                                ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showGatewayNumberDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Change',
                              style: TextStyle(
                                color: ColorPalette.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content Display Section
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_errorMessage != null) {
      return LiquidGlassCard(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorPalette.error.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorPalette.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorPalette.error.withOpacity(isDark ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 48,
                    color: ColorPalette.error,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? ColorPalette.textPrimaryDark
                        : ColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                LiquidGlassButton(
                  text: 'Retry',
                  onTap: _initializeServices,
                  icon: CupertinoIcons.refresh,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading || _currentContent != null) {
      return LiquidGlassCard(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentUrl != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ColorPalette.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          CupertinoIcons.globe,
                          size: 16,
                          color: ColorPalette.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _currentUrl!,
                          style: TextStyle(
                            color: ColorPalette.primary,
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
              if (_isLoading)
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
                                      ColorPalette.primaryLight.withOpacity(
                                        0.15,
                                      ),
                                      ColorPalette.primaryLight.withOpacity(
                                        0.05,
                                      ),
                                    ]
                                  : [
                                      ColorPalette.primary.withOpacity(0.1),
                                      ColorPalette.primary.withOpacity(0.02),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CupertinoActivityIndicator(
                            radius: 16,
                            color: ColorPalette.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fetching content...',
                          style: TextStyle(
                            color: isDark
                                ? ColorPalette.textSecondaryDark
                                : ColorPalette.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_currentContent != null)
                SelectableText(
                  _currentContent!,
                  style: TextStyle(
                    color: isDark
                        ? ColorPalette.textPrimaryDark
                        : ColorPalette.textPrimary,
                    fontSize: 15,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Empty state - Liquid Glass welcome message
    return LiquidGlassCard(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            ColorPalette.primaryLight.withOpacity(0.15),
                            ColorPalette.primaryLight.withOpacity(0.05),
                          ]
                        : [
                            ColorPalette.primary.withOpacity(0.1),
                            ColorPalette.primary.withOpacity(0.02),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.doc_text_search,
                  size: 72,
                  color: ColorPalette.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Browse the Web via SMS',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: isDark
                      ? ColorPalette.textPrimaryDark
                      : ColorPalette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Enter a URL above to fetch webpage content through encrypted SMS messages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isDark
                        ? ColorPalette.textSecondaryDark
                        : ColorPalette.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
