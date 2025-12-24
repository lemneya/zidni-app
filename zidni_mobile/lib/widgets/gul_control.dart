import 'dart:async';

import 'package:flutter/material.dart';

import '../services/stt_engine.dart';

class GulControl extends StatefulWidget {
  final SttEngine sttEngine;

  /// Optional: parent decides what to do with STT result (no auto-actions here).
  final ValueChanged<SttPayload>? onSttResult;

  const GulControl({
    super.key,
    required this.sttEngine,
    this.onSttResult,
  });

  @override
  State<GulControl> createState() => _GulControlState();
}

class _GulControlState extends State<GulControl> {
  SttStatus _status = SttStatus.idle;
  StreamSubscription<SttStatus>? _statusSubscription;

  @override
  void initState() {
    super.initState();

    // Status stream drives visuals only.
    _statusSubscription = widget.sttEngine.status.listen((status) {
      if (!mounted) return;
      setState(() => _status = status);
    });

    // Result handoff ONLY (no logs, no navigation, no auto-actions).
    widget.sttEngine.onResult = (payload) {
      widget.onSttResult?.call(payload);
    };
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    widget.sttEngine.startListening();
  }

  void _onPointerUp(PointerUpEvent event) {
    widget.sttEngine.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: Material(
        elevation: 8.0,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: _getFabColor(context),
          child: _getFabIcon(),
        ),
      ),
    );
  }

  Color _getFabColor(BuildContext context) {
    switch (_status) {
      case SttStatus.listening:
        return Colors.red.shade700;
      case SttStatus.processing:
        return Colors.lightBlue.shade700;
      case SttStatus.blocked:
        return Colors.grey;
      case SttStatus.idle:
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Widget _getFabIcon() {
    switch (_status) {
      case SttStatus.listening:
        return const Icon(Icons.mic_none, color: Colors.white, size: 40);
      case SttStatus.processing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        );
      case SttStatus.blocked:
        return const Icon(Icons.mic_off_outlined, color: Colors.white, size: 40);
      case SttStatus.idle:
      default:
        return const Icon(Icons.mic_none, color: Colors.white, size: 40);
    }
  }
}
