import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/claude_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/claude_app_bar.dart';
import '../../../../core/widgets/claude_button.dart';
import '../../../../core/widgets/claude_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/file_icon.dart';
import '../../../../models/file_item.dart';
import '../../../../services/file_picker_service.dart';
import '../../../../services/permission_service.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../sidebar/presentation/widgets/sidebar_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _picking = false;
  final ScrollController _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    // Request storage permissions on startup
    try {
      await PermissionService.instance.ensureStorage();
    } catch (_) {
      // Ignore errors if permission is denied
    }
  }

  void _onScroll() {
    final next = _scroll.hasClients && _scroll.offset > 4;
    if (next != _scrolled && mounted) {
      setState(() => _scrolled = next);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickAndOpen() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await FilePickerService.instance.pickFile();
      if (picked != null && mounted) {
        await ref.read(historyProvider.notifier).addOrPromote(picked);
        if (!mounted) return;
        await Navigator.of(context).pushNamed('/preview', arguments: picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendly(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _openHistoryItem(FileItem item) {
    Navigator.of(context).pushNamed('/preview', arguments: item);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good evening';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('PermissionDeniedFailure')) {
      return 'Storage permission required.';
    }
    return 'Could not open the file. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final recent = history.take(AppConstants.recentFilesOnHome).toList();

    return Scaffold(
      drawer: SidebarDrawer(
        onFileTap: _openHistoryItem,
        onNewFile: _pickAndOpen,
        onOpenSettings: () => Navigator.of(context).pushNamed('/settings'),
        onOpenAbout: () => Navigator.of(context).pushNamed('/about'),
        onSearch: () => Navigator.of(context).pushNamed('/search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ClaudeAppBar(
              showBottomDivider: _scrolled,
              leading: Builder(
                builder: (ctx) => IconButton(
                  tooltip: 'Open menu',
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: const Text(AppConstants.appName,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () => Navigator.of(context).pushNamed('/search'),
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
            Expanded(
              child: history.isEmpty
                  ? _EmptyHome(onSelect: _pickAndOpen, picking: _picking)
                  : _PopulatedHome(
                      controller: _scroll,
                      greeting: _greeting(),
                      recent: recent,
                      historyCount: history.length,
                      onTap: _openHistoryItem,
                      onPick: _pickAndOpen,
                      picking: _picking,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  final VoidCallback onSelect;
  final bool picking;
  const _EmptyHome({required this.onSelect, required this.picking});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyStateView(
              icon: Icons.description_outlined,
              title: 'Open a file to begin',
              subtitle:
                  'Select any file from your device to preview or edit.',
              iconSize: 96,
              action: ClaudePrimaryButton(
                label: 'Select File',
                icon: Icons.add,
                onPressed: onSelect,
                isLoading: picking,
                width: 320,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recent files appear here',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopulatedHome extends StatelessWidget {
  final ScrollController controller;
  final String greeting;
  final List<FileItem> recent;
  final int historyCount;
  final void Function(FileItem) onTap;
  final VoidCallback onPick;
  final bool picking;

  const _PopulatedHome({
    required this.controller,
    required this.greeting,
    required this.recent,
    required this.historyCount,
    required this.onTap,
    required this.onPick,
    required this.picking,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "What would you like to open today?",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ClaudeColors.darkTextSecondary
                        : ClaudeColors.lightTextSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recent Files',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const Spacer(),
                if (historyCount > recent.length)
                  TextButton(
                    onPressed: () =>
                        Scaffold.of(context).openDrawer(),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AnimationLimiter(
              child: Column(
                children: List.generate(recent.length, (i) {
                  final item = recent[i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 250),
                    child: SlideAnimation(
                      verticalOffset: 12,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecentFileCard(item: item, onTap: () => onTap(item)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: ClaudePillButton(
                label: picking ? 'Opening…' : 'Open New File',
                icon: Icons.add,
                onPressed: picking ? null : onPick,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentFileCard extends StatelessWidget {
  final FileItem item;
  final VoidCallback onTap;
  const _RecentFileCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    return ClaudeCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          FileIconBadge(type: item.type, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.extension.toUpperCase()} • ${item.formattedSize} • ${TimeFormat.relative(item.lastOpened)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: secondary, size: 22),
        ],
      ),
    );
  }
}
