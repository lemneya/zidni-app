import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/deal_folder.dart';
import '../services/offline_settings_service.dart';
import '../services/local_companion_client.dart';

/// Bottom sheet shown after a capture is saved to a folder.
/// Provides one-tap access to copy proof block and follow-up templates.
/// When offline mode is enabled, uses local LLM for smarter templates.
class PostCaptureActionsSheet extends StatefulWidget {
  final DealFolder folder;
  final String transcript;

  const PostCaptureActionsSheet({
    Key? key,
    required this.folder,
    required this.transcript,
  }) : super(key: key);

  @override
  State<PostCaptureActionsSheet> createState() => _PostCaptureActionsSheetState();
}

class _PostCaptureActionsSheetState extends State<PostCaptureActionsSheet> {
  bool _generatingArabic = false;
  bool _generatingChinese = false;

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
                      widget.folder.displayName,
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
            icon: _generatingArabic
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.copy),
            label: Text(_generatingArabic ? 'Generating...' : 'Copy Arabic Follow-up'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.blue),
            ),
            onPressed: _generatingArabic ? null : () => _copyArabicTemplate(context),
          ),
          const SizedBox(height: 12),
          
          // Copy Chinese Follow-up Button
          OutlinedButton.icon(
            icon: _generatingChinese
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.copy),
            label: Text(_generatingChinese ? 'Generating...' : 'Copy Chinese Follow-up'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.green),
            ),
            onPressed: _generatingChinese ? null : () => _copyChineseTemplate(context),
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
    buffer.writeln('📋 ${widget.folder.displayName}');
    if (widget.folder.category != null) {
      buffer.writeln('Category: ${widget.folder.category}');
    }
    if (widget.folder.priority != null) {
      buffer.writeln('Priority: ${widget.folder.priority}');
    }
    if (widget.folder.boothHall != null) {
      buffer.writeln('Booth/Hall: ${widget.folder.boothHall}');
    }
    if (widget.transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Notes:');
      buffer.writeln(widget.transcript);
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proof block copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyArabicTemplate(BuildContext context) async {
    // Check if offline mode is enabled
    final isOffline = await OfflineSettingsService.isOfflineModeEnabled();
    
    if (isOffline) {
      // Use local LLM for smarter generation
      setState(() => _generatingArabic = true);
      
      final url = await OfflineSettingsService.getCompanionUrl();
      final client = LocalCompanionClient(baseUrl: url);
      
      final generated = await client.generateArabicFollowup(
        folderName: widget.folder.displayName,
        transcript: widget.transcript,
        category: widget.folder.category,
        boothHall: widget.folder.boothHall,
      );
      
      if (!mounted) return;
      setState(() => _generatingArabic = false);
      
      if (generated != null && generated.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: generated));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('AI-generated Arabic follow-up copied'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      // Fall through to template if LLM fails
    }
    
    // Use static template
    if (!context.mounted) return;
    _copyArabicTemplateStatic(context);
  }

  void _copyArabicTemplateStatic(BuildContext context) {
    final category = widget.folder.category ?? 'غير محدد';
    final priority = widget.folder.priority ?? 'غير محدد';
    final boothHall = widget.folder.boothHall ?? 'غير محدد';
    final supplier = widget.folder.supplierName ?? widget.folder.displayName;
    
    final buffer = StringBuffer();
    buffer.writeln('السلام عليكم،');
    buffer.writeln();
    buffer.writeln('شكراً لكم على اللقاء في المعرض.');
    buffer.writeln();
    buffer.writeln('المورد: $supplier');
    buffer.writeln('الفئة: $category');
    buffer.writeln('الأولوية: $priority');
    buffer.writeln('الموقع: $boothHall');
    
    if (widget.transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ملاحظات من اللقاء:');
      buffer.writeln(widget.transcript);
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

  Future<void> _copyChineseTemplate(BuildContext context) async {
    // Check if offline mode is enabled
    final isOffline = await OfflineSettingsService.isOfflineModeEnabled();
    
    if (isOffline) {
      // Use local LLM for smarter generation
      setState(() => _generatingChinese = true);
      
      final url = await OfflineSettingsService.getCompanionUrl();
      final client = LocalCompanionClient(baseUrl: url);
      
      final generated = await client.generateChineseFollowup(
        folderName: widget.folder.displayName,
        transcript: widget.transcript,
        category: widget.folder.category,
        boothHall: widget.folder.boothHall,
      );
      
      if (!mounted) return;
      setState(() => _generatingChinese = false);
      
      if (generated != null && generated.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: generated));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('AI-generated Chinese follow-up copied'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      // Fall through to template if LLM fails
    }
    
    // Use static template
    if (!context.mounted) return;
    _copyChineseTemplateStatic(context);
  }

  void _copyChineseTemplateStatic(BuildContext context) {
    final category = widget.folder.category ?? '未指定';
    final priority = widget.folder.priority ?? '未指定';
    final boothHall = widget.folder.boothHall ?? '未指定';
    final supplier = widget.folder.supplierName ?? widget.folder.displayName;
    
    final buffer = StringBuffer();
    buffer.writeln('您好，');
    buffer.writeln();
    buffer.writeln('感谢您在展会上的会面。');
    buffer.writeln();
    buffer.writeln('供应商: $supplier');
    buffer.writeln('类别: $category');
    buffer.writeln('优先级: $priority');
    buffer.writeln('展位: $boothHall');
    
    if (widget.transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('会议记录:');
      buffer.writeln(widget.transcript);
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
