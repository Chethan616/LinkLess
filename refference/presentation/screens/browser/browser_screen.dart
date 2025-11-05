import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/color_palette.dart';
import '../../widgets/liquid_glass_components.dart';
import '../../widgets/liquid_glass_bottom_bar.dart';
import '../settings/settings_screen.dart';
import '../servers/servers_list_screen.dart';
import 'browser_provider.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  final urlController = TextEditingController();
  int currentTab = 0;
  bool isLoading = false;
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
        ),
      );
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor:
          isDark ? ColorPalette.backgroundDark : ColorPalette.backgroundLight,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [ColorPalette.backgroundDark, ColorPalette.surfaceDark]
                    : [ColorPalette.backgroundLight, ColorPalette.surfaceLight],
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar with URL input
                _buildTopBar(context),

                // Content area
                Expanded(child: _buildContentArea(context, currentTab)),
              ],
            ),
          ),

          // Bottom navigation bar with liquid glass
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LiquidGlassBottomBar(
                tabs: [
                  LiquidGlassBottomBarTab(
                    label: 'Browser',
                    icon: CupertinoIcons.globe,
                    glowColor: const Color(0xFF1E3A8A), // Deep Blue
                  ),
                  LiquidGlassBottomBarTab(
                    label: 'Servers',
                    icon: CupertinoIcons.wifi,
                    glowColor: const Color(0xFF1E3A8A), // Deep Blue
                  ),
                  LiquidGlassBottomBarTab(
                    label: 'History',
                    icon: CupertinoIcons.time,
                    glowColor: const Color(0xFFFF6B35), // Orange
                  ),
                ],
                selectedIndex: currentTab,
                onTabSelected: (index) {
                  setState(() {
                    currentTab = index;
                  });
                },
                extraButton: LiquidGlassBottomBarExtraButton(
                  icon: CupertinoIcons.settings,
                  onTap: () {
                    // Navigate to settings
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => const _SettingsHost(),
                    ));
                  },
                  label: 'Settings',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final browserState = ref.watch(browserProvider);
        final isProcessing = browserState.status != BrowserStatus.idle &&
            browserState.status != BrowserStatus.complete &&
            browserState.status != BrowserStatus.error;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LiquidGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Back button
                LiquidGlassIconButton(
                  icon: CupertinoIcons.back,
                  onTap: () {
                    // Navigate back
                  },
                  size: 40,
                ),
                const SizedBox(width: 12),

                // URL Input
                Expanded(
                  child: LiquidGlassTextField(
                    controller: urlController,
                    hintText: 'Enter URL...',
                    prefixIcon: CupertinoIcons.search,
                    suffixIcon: isProcessing
                        ? CupertinoIcons.hourglass
                        : CupertinoIcons.arrow_right_circle_fill,
                    onSuffixTap: isProcessing
                        ? null
                        : () {
                            final url = urlController.text.trim();
                            if (url.isNotEmpty) {
                              ref
                                  .read(browserProvider.notifier)
                                  .requestUrl(url);
                            }
                          },
                    onSubmitted: (value) {
                      if (!isProcessing && value.trim().isNotEmpty) {
                        ref
                            .read(browserProvider.notifier)
                            .requestUrl(value.trim());
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Refresh button
                LiquidGlassIconButton(
                  icon: CupertinoIcons.refresh,
                  onTap: () {
                    if (!isProcessing) {
                      final url = urlController.text.trim();
                      if (url.isNotEmpty) {
                        ref.read(browserProvider.notifier).requestUrl(url);
                      }
                    }
                  },
                  size: 40,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentArea(BuildContext context, int currentTab) {
    return switch (currentTab) {
      0 => _buildBrowserTab(context),
      1 => _buildServersTab(context),
      2 => _buildHistoryTab(context),
      _ => _buildBrowserTab(context),
    };
  }

  Widget _buildBrowserTab(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final browserState = ref.watch(browserProvider);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // SMS Status Card
              _buildSmsStatusCard(context, browserState),
              const SizedBox(height: 16),

              // Web Content Preview
              Expanded(
                child: _buildContentPreview(context, browserState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentPreview(BuildContext context, BrowserState browserState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show HTML content in WebView if available
    if (browserState.status == BrowserStatus.complete &&
        browserState.htmlContent != null &&
        webViewController != null) {
      // Load HTML content into WebView
      webViewController!.loadHtmlString(
        browserState.htmlContent!,
        baseUrl: browserState.currentUrl ?? 'about:blank',
      );

      return LiquidGlassCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: WebViewWidget(controller: webViewController!),
        ),
      );
    }

    // Show error message
    if (browserState.status == BrowserStatus.error) {
      return LiquidGlassCard(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: ColorPalette.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ColorPalette.error,
                    ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  browserState.errorMessage ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? ColorPalette.textSecondaryDark
                            : ColorPalette.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    return LiquidGlassCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 64,
              color: isDark
                  ? ColorPalette.textSecondaryDark
                  : ColorPalette.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No page loaded',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark
                        ? ColorPalette.textSecondaryDark
                        : ColorPalette.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a URL and tap send to browse',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? ColorPalette.textTertiaryDark
                        : ColorPalette.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsStatusCard(BuildContext context, BrowserState browserState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine status info
    final statusInfo = _getStatusInfo(browserState);

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Status indicator with glow
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusInfo.color.withOpacity(0.2),
              boxShadow: browserState.status != BrowserStatus.idle
                  ? [
                      BoxShadow(
                        color: statusInfo.color.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              statusInfo.icon,
              color: statusInfo.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? ColorPalette.textPrimaryDark
                            : ColorPalette.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusInfo.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? ColorPalette.textSecondaryDark
                            : ColorPalette.textSecondary,
                      ),
                ),
                if (browserState.totalChunks > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: browserState.progress,
                    backgroundColor: statusInfo.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusInfo.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${browserState.receivedChunks}/${browserState.totalChunks} chunks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? ColorPalette.textTertiaryDark
                              : ColorPalette.textTertiary,
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(BrowserState browserState) {
    switch (browserState.status) {
      case BrowserStatus.idle:
        return _StatusInfo(
          icon: CupertinoIcons.wifi,
          color: ColorPalette.smsIdle,
          title: 'Ready',
          subtitle: 'Waiting for request...',
        );
      case BrowserStatus.sendingRequest:
        return _StatusInfo(
          icon: CupertinoIcons.arrow_up_circle,
          color: ColorPalette.smsSending,
          title: 'Sending',
          subtitle: 'Encoding and sending request...',
        );
      case BrowserStatus.receivingSms:
        return _StatusInfo(
          icon: CupertinoIcons.arrow_down_circle,
          color: ColorPalette.smsReceiving,
          title: 'Receiving',
          subtitle: 'Waiting for SMS response...',
        );
      case BrowserStatus.assemblingChunks:
        return _StatusInfo(
          icon: CupertinoIcons.square_stack_3d_down_right,
          color: ColorPalette.smsReceiving,
          title: 'Assembling',
          subtitle: 'Collecting message chunks...',
        );
      case BrowserStatus.decodingData:
        return _StatusInfo(
          icon: CupertinoIcons.lock_open,
          color: ColorPalette.accent,
          title: 'Decoding',
          subtitle: 'Decompressing and decoding data...',
        );
      case BrowserStatus.complete:
        return _StatusInfo(
          icon: CupertinoIcons.check_mark_circled,
          color: ColorPalette.success,
          title: 'Complete',
          subtitle: 'Page loaded successfully',
        );
      case BrowserStatus.error:
        return _StatusInfo(
          icon: CupertinoIcons.exclamationmark_triangle,
          color: ColorPalette.error,
          title: 'Error',
          subtitle: browserState.errorMessage ?? 'Unknown error',
        );
    }
  }

  Widget _buildServersTab(BuildContext context) {
    return const ServersListScreen();
  }

  Widget _buildHistoryTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse History',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LiquidGlassCard(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 64,
                      color: isDark
                          ? ColorPalette.textSecondaryDark
                          : ColorPalette.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? ColorPalette.textSecondaryDark
                                : ColorPalette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for status info
class _StatusInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _StatusInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

// Small host widget that imports the settings screen lazily to avoid cycles
class _SettingsHost extends StatelessWidget {
  const _SettingsHost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Import inside build to keep dependencies explicit and avoid top-level import
    return const SettingsScreen();
  }
}
