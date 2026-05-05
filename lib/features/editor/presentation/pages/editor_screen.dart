import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';
import '../../../../core/widgets/claude_app_bar.dart';
import '../../../../core/widgets/claude_button.dart';
import '../../../../core/widgets/claude_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../models/editor_state.dart';
import '../../../../models/file_item.dart';
import '../../../../models/file_type.dart';
import '../../../../services/file_reader_service.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/editor_provider.dart';

/// Full-screen text/code/markdown editor with Claude-styled toolbar,
/// undo/redo stacks, encoding control and discard-changes guard.
class EditorScreen extends ConsumerStatefulWidget {
  final FileItem file;
  const EditorScreen({super.key, required this.file});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  bool _loading = true;
  String? _error;
  String _encoding = 'utf-8';
  late StateNotifierProvider<EditorController, EditorState> _provider;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cfg = ref.read(settingsProvider);
    try {
      final result = await FileReaderService.instance.readText(
        widget.file.path,
        preferredEncoding: widget.file.encoding ?? cfg.defaultEncoding,
      );
      _encoding = result.encoding;
      _textController.text = result.content;
      _provider = StateNotifierProvider<EditorController, EditorState>((ref) {
        final c = EditorController(widget.file, result.content, _encoding);
        c.setBaseContent(result.content);
        return c;
      });
      // Periodic auto-save of drafts (not the file itself).
      if (cfg.autoSaveDrafts) {
        _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          ref.read(_provider.notifier).persistDraft();
        });
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load file for editing.';
        });
      }
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final state = ref.read(_provider);
    if (!state.isModified) return true;
    return ClaudeConfirmDialog.show(
      context,
      title: 'Discard changes?',
      message: 'Your edits to this file will be lost.',
      confirmLabel: 'Discard',
      destructive: true,
    );
  }

  Future<void> _save() async {
    try {
      await ref.read(_provider.notifier).save();
      // Refresh history with new size/modified.
      final size = await FileReaderService.instance.sizeOf(widget.file.path);
      final updated = widget.file.copyWith(
        sizeInBytes: size,
        lastModified: DateTime.now(),
        encoding: _encoding,
      );
      await ref.read(historyProvider.notifier).addOrPromote(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
      final cfg = ref.read(settingsProvider);
      if (cfg.notificationOnSave) {
        ref
            .read(notificationServiceProvider)
            .notifyTransient('File saved', widget.file.name);
      }
      HapticFeedback.lightImpact();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the file.')),
      );
    }
  }

  void _insertWrap(String prefix, String suffix) {
    final sel = _textController.selection;
    final text = _textController.text;
    if (!sel.isValid) return;
    final selected =
        sel.isCollapsed ? '' : text.substring(sel.start, sel.end);
    final replacement = '$prefix$selected$suffix';
    final newText = text.replaceRange(sel.start, sel.end, replacement);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: sel.start + prefix.length + selected.length),
    );
    ref.read(_provider.notifier).onTextChanged(newText);
  }

  void _insertLinePrefix(String prefix) {
    final sel = _textController.selection;
    final text = _textController.text;
    if (!sel.isValid) return;
    final lineStart = text.lastIndexOf('\n', sel.start - 1) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.end + prefix.length),
    );
    ref.read(_provider.notifier).onTextChanged(newText);
  }

  void _insertTab() {
    final cfg = ref.read(settingsProvider);
    _insertWrap(' ' * cfg.tabSize, '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await _confirmDiscard();
        if (!mounted) return;
        if (ok) navigator.pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: _loading
              ? const ShimmerLoader(itemCount: 6)
              : _error != null
                  ? EmptyStateView(
                      icon: Icons.error_outline,
                      title: 'Editor unavailable',
                      subtitle: _error,
                    )
                  : _buildEditor(isDark),
        ),
      ),
    );
  }

  Widget _buildEditor(bool isDark) {
    final state = ref.watch(_provider);
    final cfg = ref.watch(settingsProvider);
    return Column(
      children: [
        ClaudeAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ok = await _confirmDiscard();
              if (ok && mounted) Navigator.of(context).pop();
            },
          ),
          title: Text(widget.file.name,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Undo',
              icon: const Icon(Icons.undo),
              onPressed: state.canUndo
                  ? () {
                      ref.read(_provider.notifier).undo();
                      _syncControllerWith(state.undoStack.isNotEmpty
                          ? state.undoStack.last
                          : state.content);
                    }
                  : null,
            ),
            IconButton(
              tooltip: 'Redo',
              icon: const Icon(Icons.redo),
              onPressed: state.canRedo
                  ? () {
                      ref.read(_provider.notifier).redo();
                      _syncControllerWith(state.redoStack.isNotEmpty
                          ? state.redoStack.last
                          : state.content);
                    }
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 36,
                child: ClaudePrimaryButton(
                  label: 'Save',
                  icon: Icons.check,
                  onPressed: state.canSave ? _save : null,
                  height: 36,
                ),
              ),
            ),
          ],
        ),
        _buildToolbar(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              scrollController: _scrollController,
              autofocus: true,
              onChanged: (v) =>
                  ref.read(_provider.notifier).onTextChanged(v),
              style: GoogleFonts.robotoMono(
                fontSize: 13.5 * cfg.fontScale,
                height: 1.55,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
        _buildStatusBar(state),
      ],
    );
  }

  /// Sync the TextEditingController to a target value while preserving cursor.
  void _syncControllerWith(String value) {
    if (_textController.text == value) return;
    _textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Widget _buildToolbar() {
    final type = widget.file.type;
    final isMd = type == FileType.markdown;
    final isCode = type == FileType.code;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? ClaudeColors.darkBorder
                : ClaudeColors.lightBorder,
            width: 1,
          ),
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? ClaudeColors.darkBorder
                : ClaudeColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          if (isMd) ...[
            _ToolbarBtn(icon: Icons.format_bold, tooltip: 'Bold', onTap: () => _insertWrap('**', '**')),
            _ToolbarBtn(icon: Icons.format_italic, tooltip: 'Italic', onTap: () => _insertWrap('_', '_')),
            _ToolbarBtn(icon: Icons.title, tooltip: 'Heading', onTap: () => _insertLinePrefix('# ')),
            _ToolbarBtn(icon: Icons.format_list_bulleted, tooltip: 'Bullet list', onTap: () => _insertLinePrefix('- ')),
            _ToolbarBtn(icon: Icons.format_list_numbered, tooltip: 'Numbered list', onTap: () => _insertLinePrefix('1. ')),
            _ToolbarBtn(icon: Icons.format_quote, tooltip: 'Quote', onTap: () => _insertLinePrefix('> ')),
            _ToolbarBtn(icon: Icons.code, tooltip: 'Code', onTap: () => _insertWrap('`', '`')),
          ] else if (isCode) ...[
            _ToolbarBtn(icon: Icons.keyboard_tab, tooltip: 'Indent', onTap: _insertTab),
            _ToolbarBtn(icon: Icons.code, tooltip: 'Inline code', onTap: () => _insertWrap('`', '`')),
            _ToolbarBtn(icon: Icons.comment_outlined, tooltip: 'Comment line', onTap: () => _insertLinePrefix('// ')),
          ] else ...[
            _ToolbarBtn(icon: Icons.keyboard_tab, tooltip: 'Indent', onTap: _insertTab),
          ],
          const VerticalDivider(width: 16),
          _ToolbarBtn(icon: Icons.undo, tooltip: 'Undo', onTap: () {
            ref.read(_provider.notifier).undo();
            final s = ref.read(_provider);
            _syncControllerWith(s.content);
          }),
          _ToolbarBtn(icon: Icons.redo, tooltip: 'Redo', onTap: () {
            ref.read(_provider.notifier).redo();
            final s = ref.read(_provider);
            _syncControllerWith(s.content);
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBar(EditorState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    final length = state.content.length;
    final lines = '\n'.allMatches(state.content).length + 1;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? ClaudeColors.darkSurfaceMuted
            : ClaudeColors.lightSurfaceMuted,
        border: Border(
          top: BorderSide(
            color: isDark ? ClaudeColors.darkBorder : ClaudeColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text('$lines lines · $length chars',
              style: TextStyle(fontSize: 11.5, color: secondary)),
          const Spacer(),
          if (state.isModified)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: _ModifiedDot(),
            ),
          Text(_encoding.toUpperCase(),
              style: TextStyle(fontSize: 11.5, color: secondary)),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 20),
        onPressed: onTap,
        splashRadius: 22,
      ),
    );
  }
}

class _ModifiedDot extends StatelessWidget {
  const _ModifiedDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: ClaudeColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Text('Modified',
            style: TextStyle(
              fontSize: 11.5,
              color: ClaudeColors.primary,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
