
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deal_folder.dart';
import '../models/gul_capture.dart';
import '../services/firestore_service.dart';

class DealFolderDetailScreen extends StatelessWidget {
  final DealFolder folder;

  const DealFolderDetailScreen({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Supplier: ${folder.supplierName ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Booth: ${folder.booth ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
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
    );
  }
}
