import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../core/widgets/claude_card.dart';
import '../../../../models/archive_node.dart';
import '../../../../services/archive_service.dart';

/// Expandable tree explorer for ZIP/TAR archives. Tapping a directory toggles
/// its expansion; tapping a small text/image file opens an in-place preview
/// sheet. Larger files prompt the user to extract first.
class ArchiveTreeView extends StatefulWidget {
  final String archivePath;
  final ArchiveNode root;

  const ArchiveTreeView({
    super.key,
    required this.archivePath,
    required this.root,
  });

  @override
  State<ArchiveTreeView> createState() => _ArchiveTreeViewState();
}

class _ArchiveTreeViewState extends State<ArchiveTreeView> {
  final Set<String> _expanded = <String>{''};

  @override
  Widget build(BuildContext context) {
    final summary = ArchiveService.instance.summarise(widget.root);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ClaudeCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.folder_zip_outlined, color: ClaudeColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.root.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.fileCount} files • ${SizeFormatter.formatBytes(summary.totalSize)} uncompressed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: _buildNodes(widget.root, depth: 0),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNodes(ArchiveNode parent, {required int depth}) {
    final widgets = <Widget>[];
    for (final node in parent.children) {
      final key =
          node.pathInArchive ?? '${parent.pathInArchive ?? ''}/${node.name}';
      final isExpanded = _expanded.contains(key);
      widgets.add(_NodeRow(
        node: node,
        depth: depth,
        isExpanded: isExpanded,
        onTap: () async {
          if (node.isDirectory) {
            setState(() {
              if (isExpanded) {
                _expanded.remove(key);
              } else {
                _expanded.add(key);
              }
            });
          } else {
            await _previewEntry(node);
          }
        },
      ));
      if (node.isDirectory && isExpanded) {
        widgets.addAll(_buildNodes(node, depth: depth + 1));
      }
    }
    return widgets;
  }

  Future<void> _previewEntry(ArchiveNode node) async {
    final entryPath = node.pathInArchive;
    if (entryPath == null) return;
    final size = node.size ?? 0;
    if (!node.isTextFile && !node.isImageFile) {
      _showSnack(
          'This file type cannot be previewed inside the archive. Extract it first.');
      return;
    }
    if (size > 1024 * 1024) {
      _showSnack('File is larger than 1 MB. Extract it first to preview.');
      return;
    }
    try {
      final bytes = await ArchiveService.instance
          .extractEntry(widget.archivePath, entryPath);
      if (bytes == null) {
        _showSnack('Entry not found in archive.');
        return;
      }
      if (!mounted) return;
      if (node.isImageFile) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _ArchiveImageSheet(name: node.name, bytes: bytes),
        );
      } else {
        final text = utf8.decode(bytes, allowMalformed: true);
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _ArchiveTextSheet(name: node.name, content: text),
        );
      }
    } catch (_) {
      _showSnack('Could not read this archive entry.');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _NodeRow extends StatelessWidget {
  final ArchiveNode node;
  final int depth;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NodeRow({
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: ClaudeColors.primary.withValues(alpha: 0.10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0 + depth * 18.0, 10, 16, 10),
          child: Row(
            children: [
              Icon(
                node.isDirectory
                    ? (isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right)
                    : Icons.insert_drive_file_outlined,
                size: 20,
                color: node.isDirectory ? ClaudeColors.primary : secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: node.isDirectory
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                    ),
                    if (!node.isDirectory)
                      Text(
                        SizeFormatter.formatBytes(node.size ?? 0),
                        style: TextStyle(fontSize: 11.5, color: secondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveTextSheet extends StatelessWidget {
  final String name;
  final String content;
  const _ArchiveTextSheet({required this.name, required this.content});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetGrabber(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    content,
                    style: GoogleFonts.robotoMono(fontSize: 13, height: 1.55),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArchiveImageSheet extends StatelessWidget {
  final String name;
  final List<int> bytes;
  const _ArchiveImageSheet({required this.name, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetGrabber(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: InteractiveViewer(
                  child: Image.memory(
                    Uint8List.fromList(bytes),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
