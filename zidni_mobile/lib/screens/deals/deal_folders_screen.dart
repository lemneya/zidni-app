
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../services/firestore_service.dart';
import 'deal_folder_detail.dart';

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
              return ListTile(
                title: Text(folder.title),
                subtitle: Text('Created on ${folder.createdAt}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DealFolderDetailScreen(folder: folder),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, FirestoreService firestoreService) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Deal Folder'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Folder title'),
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
                  firestoreService.createDealFolder(titleController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
