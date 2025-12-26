import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../models/gul_capture.dart';
import '../../services/firestore_service.dart';

class DealFolderDetailScreen extends StatefulWidget {
  final DealFolder folder;

  const DealFolderDetailScreen({Key? key, required this.folder}) : super(key: key);

  @override
  State<DealFolderDetailScreen> createState() => _DealFolderDetailScreenState();
}

class _DealFolderDetailScreenState extends State<DealFolderDetailScreen> {
  String? _latestTranscript;
  bool _loadingTranscript = true;

  @override
  void initState() {
    super.initState();
    _loadLatestTranscript();
  }

  Future<void> _loadLatestTranscript() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final capture = await firestoreService.getLatestCapture(widget.folder.id);
    if (mounted) {
      setState(() {
        _latestTranscript = capture?.transcript;
        _loadingTranscript = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.displayName),
        actions: [
          IconButton(
            icon: Icon(widget.folder.followupDone ? Icons.check_circle : Icons.check_circle_outline),
            tooltip: widget.folder.followupDone ? 'Mark as needs follow-up' : 'Mark as done',
            onPressed: () => _toggleFollowupDone(context, firestoreService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Category', widget.folder.category ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Priority', widget.folder.priority ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Booth/Hall', widget.folder.boothHall ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Supplier', widget.folder.supplierName ?? 'N/A'),
                ],
              ),
            ),
            const Divider(),
            
            // Follow-up Template Section
            _buildFollowupTemplateSection(context, firestoreService),
            
            const Divider(),
            
            // Captures Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Captures',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              child: StreamBuilder<List<GulCapture>>(
                stream: firestoreService.getCapturesForFolder(widget.folder.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No captures in this folder.'));
                  }
                  final captures = snapshot.data!;
                  
                  // Update latest transcript if captures changed
                  if (captures.isNotEmpty && _latestTranscript != captures.first.transcript) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _latestTranscript = captures.first.transcript;
                        });
                      }
                    });
                  }
                  
                  return ListView.builder(
                    itemCount: captures.length,
                    itemBuilder: (context, index) {
                      final capture = captures[index];
                      return ListTile(
                        title: Text(capture.transcript),
                        subtitle: Text('Captured on ${capture.createdAt}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildFollowupTemplateSection(BuildContext context, FirestoreService firestoreService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow-up Template',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (_loadingTranscript)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Arabic Template
            _buildTemplateCard(
              context: context,
              title: 'Arabic Template',
              template: _generateArabicTemplate(),
            ),
            const SizedBox(height: 12),
            
            // Chinese Template
            _buildTemplateCard(
              context: context,
              title: 'Chinese Template',
              template: _generateChineseTemplate(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateCard({
    required BuildContext context,
    required String title,
    required String template,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  onPressed: () => _copyToClipboard(context, template),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                template,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateArabicTemplate() {
    final category = widget.folder.category ?? 'غير محدد';
    final priority = widget.folder.priority ?? 'غير محدد';
    final boothHall = widget.folder.boothHall ?? 'غير محدد';
    final supplier = widget.folder.supplierName ?? widget.folder.displayName;
    final transcript = _latestTranscript;
    
    final buffer = StringBuffer();
    buffer.writeln('السلام عليكم،');
    buffer.writeln();
    buffer.writeln('شكراً لكم على اللقاء في المعرض.');
    buffer.writeln();
    buffer.writeln('المورد: $supplier');
    buffer.writeln('الفئة: $category');
    buffer.writeln('الأولوية: $priority');
    buffer.writeln('الموقع: $boothHall');
    
    if (transcript != null && transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ملاحظات من اللقاء:');
      buffer.writeln(transcript);
    }
    
    buffer.writeln();
    buffer.writeln('نتطلع للتعاون معكم.');
    buffer.writeln();
    buffer.write('مع أطيب التحيات');
    
    return buffer.toString();
  }

  String _generateChineseTemplate() {
    final category = widget.folder.category ?? '未指定';
    final priority = widget.folder.priority ?? '未指定';
    final boothHall = widget.folder.boothHall ?? '未指定';
    final supplier = widget.folder.supplierName ?? widget.folder.displayName;
    final transcript = _latestTranscript;
    
    final buffer = StringBuffer();
    buffer.writeln('您好，');
    buffer.writeln();
    buffer.writeln('感谢您在展会上的会面。');
    buffer.writeln();
    buffer.writeln('供应商: $supplier');
    buffer.writeln('类别: $category');
    buffer.writeln('优先级: $priority');
    buffer.writeln('展位: $boothHall');
    
    if (transcript != null && transcript.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('会议记录:');
      buffer.writeln(transcript);
    }
    
    buffer.writeln();
    buffer.writeln('期待与您合作。');
    buffer.writeln();
    buffer.write('此致敬礼');
    
    return buffer.toString();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFollowupDone(BuildContext context, FirestoreService firestoreService) async {
    final newValue = !widget.folder.followupDone;
    final messenger = ScaffoldMessenger.of(context);
    await firestoreService.updateFollowupDone(widget.folder.id, newValue);
    messenger.showSnackBar(
      SnackBar(
        content: Text(newValue ? 'Marked as done' : 'Marked as needs follow-up'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
