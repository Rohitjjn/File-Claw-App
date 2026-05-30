import 'package:flutter/material.dart';

/// Reusable wrapper to add pinch-to-zoom to text-based preview screens.
/// Uses InteractiveViewer while disabling pan when fully zoomed out
/// so internal scrolling (ListView) doesn't conflict with InteractiveViewer's pan.
class ZoomableView extends StatefulWidget {
  final Widget child;
  const ZoomableView({super.key, required this.child});

  @override
  State<ZoomableView> createState() => _ZoomableViewState();
}

class _ZoomableViewState extends State<ZoomableView> {
  final TransformationController _controller = TransformationController();
  bool _panEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScaleChanged);
  }

  void _onScaleChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    final shouldPan = scale > 1.0;
    if (_panEnabled != shouldPan && mounted) {
      setState(() {
        _panEnabled = shouldPan;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScaleChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.5,
      maxScale: 4.0,
      panEnabled: _panEnabled,
      scaleEnabled: true,
      child: widget.child,
    );
  }
}
