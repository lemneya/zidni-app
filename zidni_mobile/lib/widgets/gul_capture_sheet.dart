import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zidni_mobile/models/deal_folder.dart';
import 'package:zidni_mobile/models/gul_capture.dart';
import 'package:zidni_mobile/services/firestore_service.dart';
import 'package:zidni_mobile/services/last_folder_service.dart';
import 'package:zidni_mobile/services/offline_capture_queue.dart';
import 'package:zidni_mobile/widgets/post_capture_actions_sheet.dart';

class GulCaptureSheet extends StatefulWidget {
  final String transcript;
  final Function(GulCapture)? onSave;

  const GulCaptureSheet({
    Key? key,
    required this.transcript,
    this.onSave,
  }) : super(key: key);

  @override
  State<GulCaptureSheet> createState() => _GulCaptureSheetState();
}

class _GulCaptureSheetState extends State<GulCaptureSheet> {
  DealFolder? _selectedFolder;
  bool _saving = false;
  String? _lastFolderId;
  String? _lastFolderName;
  bool _loadingLastFolder = true;

  @override
  void initState() {
    super.initState();
    _loadLastFolder();
  }

  Future<void> _loadLastFolder() async {
    final lastId = await LastFolderService.getLastFolderId();
    final lastName = await LastFolderService.getLastFolderName();
    if (mounted) {
      setState(() {
        _lastFolderId = lastId;
        _lastFolderName = lastName;
        _loadingLastFolder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Capture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          
          // Transcript
          const SizedBox(height: 8),
          const Text(
            'Transcript:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(widget.transcript),
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Save to Last Folder Button
          if (!_loadingLastFolder && _lastFolderId != null && _lastFolderName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on, size: 20),
                  label: Text('Save to "$_lastFolderName"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saving
                      ? null
                      : () => _quickSaveToLastFolder(context, firestoreService),
                ),
              ),
            ),
          
          // Folder Selector
          const Text(
            'Save to folder:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<DealFolder>>(
            stream: firestoreService.getDealFolders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No folders available. Create one first.');
              }
              final folders = snapshot.data!;
              return DropdownButtonFormField<DealFolder>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Select a folder'),
                value: _selectedFolder,
                items: folders.map((folder) {
                  return DropdownMenuItem(
                    value: folder,
                    child: Text(folder.displayName),
                  );
                }).toList(),
                onChanged: (folder) {
                  setState(() {
                    _selectedFolder = folder;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.transcript));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transcript copied'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectedFolder == null || _saving
                    ? null
                    : () => _saveCapture(context, firestoreService),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _quickSaveToLastFolder(BuildContext context, FirestoreService firestoreService) async {
    if (_lastFolderId == null) return;
    
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final folderId = _lastFolderId!;
    final folderName = _lastFolderName!;
    final transcript = widget.transcript;
    
    setState(() {
      _saving = true;
    });

    try {
      // Save capture to Firestore
      await firestoreService.saveCaptureToFolder(folderId, transcript);

      // Call legacy onSave callback if provided
      widget.onSave?.call(
        GulCapture(
          transcript: transcript,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      // Close the capture sheet
      navigator.pop();

      // Show post-capture actions sheet with a placeholder folder
      if (context.mounted) {
        // Create a minimal DealFolder for the post-capture sheet
        final folder = DealFolder(
          id: folderId,
          ownerUid: '',
          createdAt: DateTime.now(),
          mode: 'personal',
          supplierName: folderName,
        );
        showPostCaptureActionsSheet(
          context,
          folder: folder,
          transcript: transcript,
        );
      }
    } catch (e) {
      // Network error - save to offline queue with size cap
      await OfflineCaptureQueue.addToQueueWithSizeCap(
        folderId: folderId,
        folderName: folderName,
        transcript: transcript,
      );

      if (!mounted) return;

      // Close the capture sheet
      navigator.pop();

      // Show offline saved message
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Saved offline - will sync when online'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveCapture(BuildContext context, FirestoreService firestoreService) async {
    if (_selectedFolder == null) return;
    
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final folder = _selectedFolder!;
    final transcript = widget.transcript;
    
    setState(() {
      _saving = true;
    });

    try {
      // Save capture to Firestore
      await firestoreService.saveCaptureToFolder(
        folder.id,
        transcript,
      );

      // Save as last used folder
      await LastFolderService.setLastFolder(folder.id, folder.displayName);

      // Call legacy onSave callback if provided
      widget.onSave?.call(
        GulCapture(
          transcript: transcript,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      // Close the capture sheet
      navigator.pop();

      // Show post-capture actions sheet
      if (context.mounted) {
        showPostCaptureActionsSheet(
          context,
          folder: folder,
          transcript: transcript,
        );
      }
    } catch (e) {
      // Network error - save to offline queue with size cap
      await OfflineCaptureQueue.addToQueueWithSizeCap(
        folderId: folder.id,
        folderName: folder.displayName,
        transcript: transcript,
      );

      // Still save as last used folder
      await LastFolderService.setLastFolder(folder.id, folder.displayName);

      if (!mounted) return;

      // Close the capture sheet
      navigator.pop();

      // Show offline saved message
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Saved offline - will sync when online'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
