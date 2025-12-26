import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/deal_folder.dart';

/// Bottom sheet shown after a capture is saved to a folder.
/// Provides one-tap access to copy proof block and follow-up templates.
class PostCaptureActionsSheet extends StatelessWidget {
  final DealFolder folder;
  final String transcript;

  const PostCaptureActionsSheet({
    Key? key,
    required this.folder,
    required this.transcript,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capture Saved!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      folder.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Quick Actions Title
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          
          // Copy Proof Block Button
          ElevatedButton.icon(
            icon: const Icon(Icons.content_copy),
            label: const Text('Copy Proof Block'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _copyProofBlock(context),
          ),
          const SizedBox(height: 12),
          
          // Copy Arabic Follow-up Button
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Arabic Follow-up'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.blue),
            ),
            onPressed: () => _copyArabicTemplate(context),
          ),
          const SizedBox(height: 12),
          
          // Copy Chinese Follow-up Button
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Chinese Follow-up'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.green),
            ),
            onPressed: () => _copyChineseTemplate(context),
          ),
          const SizedBox(height: 16),
          
          // Done Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _copyProofBlock(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('📋 ${folder.displayName}');
    if (folder.category != null) {
      buffer.writeln('Category: ${folder.category}');
    }
    if (folder.priority != null) {
      buffer.writeln('Priority: ${folder.priority}');
    }
    if (folder.boothHall != null) {
      buffer.writeln('Booth/Hall: ${folder.boothHall}');
    }
    if (transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Notes:');
      buffer.writeln(transcript);
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proof block copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyArabicTemplate(BuildContext context) {
    final category = folder.category ?? 'غير محدد';
    final priority = folder.priority ?? 'غير محدد';
    final boothHall = folder.boothHall ?? 'غير محدد';
    final supplier = folder.supplierName ?? folder.displayName;
    
    final buffer = StringBuffer();
    buffer.writeln('السلام عليكم،');
    buffer.writeln();
    buffer.writeln('شكراً لكم على اللقاء في المعرض.');
    buffer.writeln();
    buffer.writeln('المورد: $supplier');
    buffer.writeln('الفئة: $category');
    buffer.writeln('الأولوية: $priority');
    buffer.writeln('الموقع: $boothHall');
    
    if (transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ملاحظات من اللقاء:');
      buffer.writeln(transcript);
    }
    
    buffer.writeln();
    buffer.writeln('نتطلع للتعاون معكم.');
    buffer.writeln();
    buffer.write('مع أطيب التحيات');
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arabic follow-up copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyChineseTemplate(BuildContext context) {
    final category = folder.category ?? '未指定';
    final priority = folder.priority ?? '未指定';
    final boothHall = folder.boothHall ?? '未指定';
    final supplier = folder.supplierName ?? folder.displayName;
    
    final buffer = StringBuffer();
    buffer.writeln('您好，');
    buffer.writeln();
    buffer.writeln('感谢您在展会上的会面。');
    buffer.writeln();
    buffer.writeln('供应商: $supplier');
    buffer.writeln('类别: $category');
    buffer.writeln('优先级: $priority');
    buffer.writeln('展位: $boothHall');
    
    if (transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('会议记录:');
      buffer.writeln(transcript);
    }
    
    buffer.writeln();
    buffer.writeln('期待与您合作。');
    buffer.writeln();
    buffer.write('此致敬礼');
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chinese follow-up copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Helper function to show the post-capture actions sheet
void showPostCaptureActionsSheet(
  BuildContext context, {
  required DealFolder folder,
  required String transcript,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => PostCaptureActionsSheet(
      folder: folder,
      transcript: transcript,
    ),
  );
}
