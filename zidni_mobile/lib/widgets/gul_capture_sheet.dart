import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/models/gul_capture.dart';

class GulCaptureSheet extends StatelessWidget {
  final String transcript;
  final Function(GulCapture) onSave;

  const GulCaptureSheet({
    Key? key,
    required this.transcript,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Text(transcript),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: transcript));
                },
                child: const Text('Copy'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  onSave(
                    GulCapture(
                      id: '', // ID will be assigned by Firestore
                      transcript: transcript,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
