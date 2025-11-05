import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/entities/server.dart';
import '../../widgets/liquid_glass_components.dart';
import 'server_provider.dart';

class ServersListScreen extends ConsumerStatefulWidget {
  const ServersListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ServersListScreen> createState() => _ServersListScreenState();
}

class _ServersListScreenState extends ConsumerState<ServersListScreen> {
  void _showAddServerDialog() {
    print('🔵 Add Server button tapped!'); // Debug log

    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) {
        print('🟢 Building dialog...'); // Debug log
        return CupertinoAlertDialog(
          title: const Text('Add Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Server Name',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: phoneController,
                placeholder: 'Phone Number',
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                print('🟡 Add button pressed in dialog'); // Debug log
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  final actions = ref.read(serverActionsProvider);
                  print(
                      '🟠 Adding server: ${nameController.text} - ${phoneController.text}'); // Debug log
                  await actions.addServer(
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                  );
                  print('🟢 Server added successfully!'); // Debug log
                  if (mounted) Navigator.pop(context);
                } else {
                  print('❌ Fields are empty!'); // Debug log
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serversAsync = ref.watch(serverListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'SMS Servers',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              LiquidGlassIconButton(
                icon: CupertinoIcons.add,
                onTap: _showAddServerDialog,
                size: 44,
                backgroundColor: ColorPalette.primary,
                iconColor: Colors.white,
              ),
            ],
          ),
        ),

        // Server List
        Expanded(
          child: serversAsync.when(
            data: (servers) {
              if (servers.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return _buildServerList(servers, isDark);
            },
            loading: () => const Center(
              child: CupertinoActivityIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.antenna_radiowaves_left_right,
              size: 80,
              color: isDark
                  ? ColorPalette.textSecondaryDark
                  : ColorPalette.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No servers configured',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark
                        ? ColorPalette.textSecondaryDark
                        : ColorPalette.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add an SMS server to start browsing',
              textAlign: TextAlign.center,
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

  Widget _buildServerList(List<Server> servers, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ServerCard(server: server),
        );
      },
    );
  }
}

class _ServerCard extends ConsumerWidget {
  final Server server;

  const _ServerCard({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () async {
        // Toggle active status
        final actions = ref.read(serverActionsProvider);
        await actions.setActiveServer(server.id);
      },
      child: Row(
        children: [
          // Active indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (server.isActive
                      ? ColorPalette.success
                      : ColorPalette.textTertiary)
                  .withOpacity(0.2),
              boxShadow: server.isActive
                  ? [
                      BoxShadow(
                        color: ColorPalette.success.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              server.isActive
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.wifi,
              color: server.isActive
                  ? ColorPalette.success
                  : (isDark
                      ? ColorPalette.textSecondaryDark
                      : ColorPalette.textSecondary),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Server info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  server.phoneNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? ColorPalette.textSecondaryDark
                            : ColorPalette.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: () async {
              final confirmed = await showCupertinoDialog<bool>(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Delete Server'),
                  content: Text('Remove ${server.name}?'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final actions = ref.read(serverActionsProvider);
                await actions.deleteServer(server.id);
              }
            },
            child: Icon(
              CupertinoIcons.trash,
              color: ColorPalette.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
