import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../services/firestore_service.dart';
import 'deal_folder_detail.dart';
import 'followup_queue_screen.dart';

class DealFoldersScreen extends StatelessWidget {
  const DealFoldersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: 'Follow-up Queue',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FollowupQueueScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateFolderDialog(context, firestoreService),
          ),
        ],
      ),
      body: StreamBuilder<List<DealFolder>>(
        stream: firestoreService.getDealFolders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No deal folders found.'));
          }
          final folders = snapshot.data!;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return _buildFolderTile(context, folder);
            },
          );
        },
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, DealFolder folder) {
    return ListTile(
      leading: _buildPriorityIndicator(folder.priority),
      title: Text(folder.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (folder.category != null)
            Text('Category: ${folder.category}'),
          Text('Created: ${_formatDate(folder.createdAt)}'),
        ],
      ),
      trailing: folder.followupDone
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealFolderDetailScreen(folder: folder),
          ),
        );
      },
    );
  }

  Widget _buildPriorityIndicator(String? priority) {
    Color color;
    
    switch (priority) {
      case 'Hot':
        color = Colors.red;
        break;
      case 'Warm':
        color = Colors.orange;
        break;
      case 'Cold':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    
    return CircleAvatar(
      radius: 8,
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateFolderDialog(BuildContext context, FirestoreService firestoreService) {
    final titleController = TextEditingController();
    final boothController = TextEditingController();
    String? selectedCategory;
    String? selectedPriority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Deal Folder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Folder title',
                        hintText: 'e.g., Supplier ABC',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: boothController,
                      decoration: const InputDecoration(
                        labelText: 'Booth/Hall',
                        hintText: 'e.g., Hall A - B123',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                        DropdownMenuItem(value: 'Textiles', child: Text('Textiles')),
                        DropdownMenuItem(value: 'Machinery', child: Text('Machinery')),
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Priority'),
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'Hot', child: Text('🔥 Hot')),
                        DropdownMenuItem(value: 'Warm', child: Text('☀️ Warm')),
                        DropdownMenuItem(value: 'Cold', child: Text('❄️ Cold')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      firestoreService.createDealFolder(
                        titleController.text,
                        booth: boothController.text.isNotEmpty ? boothController.text : null,
                        category: selectedCategory,
                        priority: selectedPriority,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
