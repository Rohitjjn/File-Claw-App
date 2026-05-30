import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/claude_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/claude_app_bar.dart';
import '../../../../core/widgets/claude_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/file_icon.dart';
import '../../../../models/file_item.dart';
import '../../../history/presentation/providers/history_provider.dart';

/// Search screen for filtering the file history list.
///
/// Search is debounced (300ms) and matches both file name and extension
/// (case-insensitive).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  List<FileItem> _filter(List<FileItem> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.extension.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final results = _filter(history);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ClaudeAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text('Search'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search file history…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                          },
                        ),
                  filled: true,
                  fillColor: isDark
                      ? ClaudeColors.darkSurface
                      : ClaudeColors.lightSurface,
                ),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.history,
                      title: 'No history yet',
                      subtitle: 'Files you open will appear here.',
                    )
                  : results.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.search_off,
                          title: 'No files found',
                          subtitle:
                              'Try a different name or extension.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final item = results[i];
                            return _SearchResultCard(
                              item: item,
                              query: _query,
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                    '/preview',
                                    arguments: item);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final FileItem item;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.item,
    required this.query,
    required this.onTap,
  });

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
          FileIconBadge(type: item.type, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.extension.toUpperCase()} • ${item.formattedSize} • ${TimeFormat.relative(item.lastOpened)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: secondary),
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
