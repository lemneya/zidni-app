import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../services/firestore_service.dart';
import 'deal_folder_detail.dart';

class FollowupQueueScreen extends StatefulWidget {
  const FollowupQueueScreen({Key? key}) : super(key: key);

  @override
  State<FollowupQueueScreen> createState() => _FollowupQueueScreenState();
}

class _FollowupQueueScreenState extends State<FollowupQueueScreen> {
  bool _showDone = false;
  final Set<String> _selectedPriorities = {'Hot'};
  
  // Cache for latest transcripts by folder ID
  final Map<String, String?> _transcriptCache = {};

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow-up Queue'),
        actions: [
          IconButton(
            icon: Icon(_showDone ? Icons.visibility : Icons.visibility_off),
            tooltip: _showDone ? 'Hide completed' : 'Show completed',
            onPressed: () {
              setState(() {
                _showDone = !_showDone;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Priority Filter Chips
          _buildPriorityFilter(),
          const Divider(height: 1),
          
          // Queue List
          Expanded(
            child: StreamBuilder<List<DealFolder>>(
              stream: firestoreService.getFollowupQueue(
                showDone: _showDone,
                priorities: _selectedPriorities.isNotEmpty 
                    ? _selectedPriorities.toList() 
                    : null,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showDone 
                              ? 'No folders match the filter' 
                              : 'All caught up! No pending follow-ups.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final folders = snapshot.data!;
                // Preload transcripts for all folders
                _preloadTranscripts(folders, firestoreService);
                
                return ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return _buildQueueItem(context, folder, firestoreService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _preloadTranscripts(List<DealFolder> folders, FirestoreService firestoreService) {
    for (final folder in folders) {
      if (!_transcriptCache.containsKey(folder.id)) {
        _transcriptCache[folder.id] = null; // Mark as loading
        firestoreService.getLatestCapture(folder.id).then((capture) {
          if (mounted) {
            setState(() {
              _transcriptCache[folder.id] = capture?.transcript;
            });
          }
        });
      }
    }
  }

  Widget _buildPriorityFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Hot'),
            selected: _selectedPriorities.contains('Hot'),
            selectedColor: Colors.red[100],
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedPriorities.add('Hot');
                } else {
                  _selectedPriorities.remove('Hot');
                }
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Warm'),
            selected: _selectedPriorities.contains('Warm'),
            selectedColor: Colors.orange[100],
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedPriorities.add('Warm');
                } else {
                  _selectedPriorities.remove('Warm');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(BuildContext context, DealFolder folder, FirestoreService firestoreService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: _buildPriorityIndicator(folder.priority),
            title: Text(
              folder.displayName,
              style: TextStyle(
                decoration: folder.followupDone ? TextDecoration.lineThrough : null,
                color: folder.followupDone ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (folder.category != null)
                  Text('Category: ${folder.category}'),
                if (folder.boothHall != null)
                  Text('Booth/Hall: ${folder.boothHall}'),
                if (folder.lastCaptureAt != null)
                  Text(
                    'Last capture: ${_formatDate(folder.lastCaptureAt!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                folder.followupDone ? Icons.check_circle : Icons.check_circle_outline,
                color: folder.followupDone ? Colors.green : Colors.grey,
              ),
              tooltip: folder.followupDone ? 'Mark as pending' : 'Mark as done',
              onPressed: () => _toggleFollowupDone(folder, firestoreService),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealFolderDetailScreen(folder: folder),
                ),
              );
            },
          ),
          // One-tap Copy Buttons
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Arabic'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => _copyArabicTemplate(context, folder),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Chinese'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => _copyChineseTemplate(context, folder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(String? priority) {
    Color color;
    IconData icon;
    
    switch (priority) {
      case 'Hot':
        color = Colors.red;
        icon = Icons.local_fire_department;
        break;
      case 'Warm':
        color = Colors.orange;
        icon = Icons.wb_sunny;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _copyArabicTemplate(BuildContext context, DealFolder folder) {
    final transcript = _transcriptCache[folder.id];
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
    
    if (transcript != null && transcript.isNotEmpty) {
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
        content: Text('Arabic template copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyChineseTemplate(BuildContext context, DealFolder folder) {
    final transcript = _transcriptCache[folder.id];
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
    
    if (transcript != null && transcript.isNotEmpty) {
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
        content: Text('Chinese template copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFollowupDone(DealFolder folder, FirestoreService firestoreService) async {
    final newValue = !folder.followupDone;
    await firestoreService.updateFollowupDone(folder.id, newValue);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue ? 'Marked as done' : 'Marked as needs follow-up'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              firestoreService.updateFollowupDone(folder.id, !newValue);
            },
          ),
        ),
      );
    }
  }
}
