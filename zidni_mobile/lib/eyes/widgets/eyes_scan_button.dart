import 'package:flutter/material.dart';
import 'package:zidni_mobile/eyes/screens/eyes_scan_screen.dart';

/// Eyes Scan Button - Entry point for Zidni Eyes
/// Gate EYES-1: Scan icon on GUL screen
class EyesScanButton extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const EyesScanButton({
    super.key,
    this.size = 24,
    this.color,
    this.backgroundColor,
  });

  void _openEyesScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EyesScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _openEyesScan(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.document_scanner,
            size: size,
            color: color ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Eyes Scan FAB - Floating action button variant
class EyesScanFab extends StatelessWidget {
  final bool mini;

  const EyesScanFab({
    super.key,
    this.mini = false,
  });

  void _openEyesScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EyesScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: mini,
      onPressed: () => _openEyesScan(context),
      backgroundColor: Colors.green,
      tooltip: 'عيون زدني - مسح المنتج',
      child: const Icon(Icons.document_scanner, color: Colors.white),
    );
  }
}
