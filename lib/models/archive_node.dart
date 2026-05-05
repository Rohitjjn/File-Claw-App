import 'package:path/path.dart' as p;
import '../core/constants/app_constants.dart';

/// Tree node representing a file or folder inside an archive.
class ArchiveNode {
  final String name;
  final String? pathInArchive; // null for synthetic root
  final bool isDirectory;
  final int? size;
  final DateTime? modifiedDate;
  final List<ArchiveNode> children;
  final String? parentPath;

  ArchiveNode({
    required this.name,
    this.pathInArchive,
    required this.isDirectory,
    this.size,
    this.modifiedDate,
    List<ArchiveNode>? children,
    this.parentPath,
  }) : children = children ?? [];

  String get extension {
    final ext = p.extension(name);
    return ext.isEmpty ? '' : ext.substring(1).toLowerCase();
  }

  bool get isTextFile =>
      AppConstants.editableExtensions.contains(extension);

  bool get isImageFile =>
      AppConstants.imageExtensions.contains(extension);

  Map<String, dynamic> toJson() => {
        'name': name,
        'pathInArchive': pathInArchive,
        'isDirectory': isDirectory,
        'size': size,
        'modifiedDate': modifiedDate?.toIso8601String(),
        'parentPath': parentPath,
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory ArchiveNode.fromJson(Map<String, dynamic> json) {
    return ArchiveNode(
      name: json['name'] as String,
      pathInArchive: json['pathInArchive'] as String?,
      isDirectory: json['isDirectory'] as bool? ?? false,
      size: (json['size'] as num?)?.toInt(),
      modifiedDate:
          DateTime.tryParse(json['modifiedDate'] as String? ?? ''),
      parentPath: json['parentPath'] as String?,
      children: (json['children'] as List?)
              ?.map((c) => ArchiveNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
