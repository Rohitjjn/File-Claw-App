/// Converts byte sizes into human-readable strings.
///
/// Examples:
///   formatBytes(0) -> '0 B'
///   formatBytes(1024) -> '1.0 KB'
///   formatBytes(2_500_000) -> '2.4 MB'
class SizeFormatter {
  SizeFormatter._();

  static const List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < _units.length - 1) {
      size /= 1024;
      unit++;
    }
    final formatted = unit == 0
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(decimals);
    return '$formatted ${_units[unit]}';
  }
}
