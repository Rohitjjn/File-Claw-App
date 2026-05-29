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
import '../../../../services/local_search_service.dart';
import '../../../history/presentation/providers/history_provider.dart';

/// Search screen for filtering the file history list and local device files.
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
  List<FileItem> _localResults = [];
  bool _searchingLocal = false;
  bool _showAllHistory = false;

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
      if (mounted) {
        setState(() {
          _query = value.trim();
          _showAllHistory = false;
        });
        _searchLocal();
      }
    });
  }

  Future<void> _searchLocal() async {
    if (_query.isEmpty) {
      if (mounted) {
        setState(() {
          _localResults = [];
          _searchingLocal = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _searchingLocal = true);

    final results = await LocalSearchService.instance.search(_query);

    if (mounted && _query.isNotEmpty) {
      setState(() {
        _localResults = results;
        _searchingLocal = false;
      });
    }
  }

  List<FileItem> _filter(List<FileItem> all) {
    if (_query.isEmpty) return [];
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
    final historyResults = _filter(history);
    final historyPaths = history.map((e) => e.path).toSet();

    // Deduplicate local results that are already in history based on path
    final deduplicatedLocalResults = _localResults.where((local) => !historyPaths.contains(local.path)).toList();

    final displayedHistoryResults = _showAllHistory || historyResults.length <= 3
        ? historyResults
        : historyResults.take(3).toList();

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
              child: _query.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.search,
                      title: 'Search files',
                      subtitle: 'Type to search history and local files.',
                    )
                  : historyResults.isEmpty && deduplicatedLocalResults.isEmpty && !_searchingLocal
                      ? const EmptyStateView(
                          icon: Icons.search_off,
                          title: 'No files found',
                          subtitle: 'Try a different name or extension.',
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            if (historyResults.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('History', style: Theme.of(context).textTheme.titleSmall),
                                    if (historyResults.length > 3 && !_showAllHistory)
                                      TextButton(
                                        onPressed: () => setState(() => _showAllHistory = true),
                                        child: const Text('Show more'),
                                      ),
                                  ],
                                ),
                              ),
                              ...displayedHistoryResults.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _SearchResultCard(
                                  item: item,
                                  query: _query,
                                  isLocal: false,
                                  onTap: () {
                                    Navigator.of(context).pushReplacementNamed('/preview', arguments: item);
                                  },
                                ),
                              )),
                            ],
                            if (_searchingLocal)
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (deduplicatedLocalResults.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Text('Local Files', style: Theme.of(context).textTheme.titleSmall),
                              ),
                              ...deduplicatedLocalResults.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _SearchResultCard(
                                  item: item,
                                  query: _query,
                                  isLocal: true,
                                  onTap: () async {
                                    await ref.read(historyProvider.notifier).addOrPromote(item);
                                    if (!context.mounted) return;
                                    Navigator.of(context).pushReplacementNamed('/preview', arguments: item);
                                  },
                                ),
                              )),
                            ],
                          ],
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
  final bool isLocal;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.item,
    required this.query,
    this.isLocal = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;

    // As per the requirement: blue cards for local, orange if in history (isLocal=false)
    final backgroundColor = isLocal
        ? (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50)
        : (isDark ? ClaudeColors.primary.withOpacity(0.1) : ClaudeColors.primary.withOpacity(0.05));

    return ClaudeCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      backgroundColor: backgroundColor,
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
