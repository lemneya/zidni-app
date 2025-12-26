import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../models/gul_capture.dart';
import '../../services/firestore_service.dart';

class DealFolderDetailScreen extends StatelessWidget {
  final DealFolder folder;

  const DealFolderDetailScreen({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.title),
        actions: [
          IconButton(
            icon: Icon(folder.followupDone ? Icons.check_circle : Icons.check_circle_outline),
            tooltip: folder.followupDone ? 'Mark as needs follow-up' : 'Mark as done',
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
                  _buildInfoRow('Category', folder.category ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Priority', folder.priority ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Booth/Hall', folder.booth ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Supplier', folder.supplierName ?? 'N/A'),
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
                stream: firestoreService.getCapturesForFolder(folder.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No captures in this folder.'));
                  }
                  final captures = snapshot.data!;
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
          
          // Arabic Template
          _buildTemplateCard(
            context: context,
            title: 'Arabic Template',
            template: _generateArabicTemplate(),
            firestoreService: firestoreService,
          ),
          const SizedBox(height: 12),
          
          // Chinese Template
          _buildTemplateCard(
            context: context,
            title: 'Chinese Template',
            template: _generateChineseTemplate(),
            firestoreService: firestoreService,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard({
    required BuildContext context,
    required String title,
    required String template,
    required FirestoreService firestoreService,
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
    final category = folder.category ?? 'غير محدد';
    final priority = folder.priority ?? 'غير محدد';
    final booth = folder.booth ?? 'غير محدد';
    final supplier = folder.supplierName ?? folder.title;
    
    return '''السلام عليكم،

شكراً لكم على اللقاء في المعرض.

المورد: $supplier
الفئة: $category
الأولوية: $priority
الموقع: $booth

نتطلع للتعاون معكم.

مع أطيب التحيات''';
  }

  String _generateChineseTemplate() {
    final category = folder.category ?? '未指定';
    final priority = folder.priority ?? '未指定';
    final booth = folder.booth ?? '未指定';
    final supplier = folder.supplierName ?? folder.title;
    
    return '''您好，

感谢您在展会上的会面。

供应商: $supplier
类别: $category
优先级: $priority
展位: $booth

期待与您合作。

此致敬礼''';
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
    final newValue = !folder.followupDone;
    final messenger = ScaffoldMessenger.of(context);
    await firestoreService.updateFollowupDone(folder.id, newValue);
    messenger.showSnackBar(
      SnackBar(
        content: Text(newValue ? 'Marked as done' : 'Marked as needs follow-up'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
