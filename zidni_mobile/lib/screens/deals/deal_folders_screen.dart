import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deal_folder.dart';
import '../../services/firestore_service.dart';
import '../../services/offline_capture_queue.dart';
import 'deal_folder_detail.dart';
import 'followup_queue_screen.dart';

class DealFoldersScreen extends StatefulWidget {
  const DealFoldersScreen({Key? key}) : super(key: key);

  @override
  State<DealFoldersScreen> createState() => _DealFoldersScreenState();
}

class _DealFoldersScreenState extends State<DealFoldersScreen> {
  int _pendingCount = 0;
  List<PendingCapture> _pendingItems = [];
  final Set<int> _syncingIndices = {};

  @override
  void initState() {
    super.initState();
    _loadPendingQueue();
  }

  Future<void> _loadPendingQueue() async {
    final queue = await OfflineCaptureQueue.getQueue();
    if (mounted) {
      setState(() {
        _pendingItems = queue;
        _pendingCount = queue.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Folders'),
        actions: [
          // Pending uploads badge
          if (_pendingCount > 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: 'Pending uploads',
                  onPressed: () => _showPendingUploadsSheet(context, firestoreService),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showPendingUploadsSheet(BuildContext context, FirestoreService firestoreService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Uploads',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_pendingCount capture${_pendingCount == 1 ? '' : 's'} waiting to sync',
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
              
              // Pending items list with status
              if (_pendingItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending captures'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pendingItems.length,
                    itemBuilder: (context, index) {
                      final item = _pendingItems[index];
                      final isSyncing = _syncingIndices.contains(index);
                      final status = isSyncing 
                          ? PendingCaptureStatus.syncing 
                          : item.status;
                      
                      return ListTile(
                        leading: _buildStatusIcon(status),
                        title: Row(
                          children: [
                            Expanded(child: Text(item.folderName)),
                            _buildStatusBadge(status),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.transcriptPreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.truncated)
                              Text(
                                'Truncated for offline storage',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          _formatTime(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              
              // Retry button with in-flight guard
              ElevatedButton.icon(
                icon: OfflineCaptureQueue.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(OfflineCaptureQueue.isSyncing ? 'Syncing...' : 'Retry Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: OfflineCaptureQueue.isSyncing
                    ? null
                    : () => _retryPendingUploads(context, firestoreService, setSheetState),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PendingCaptureStatus status) {
    switch (status) {
      case PendingCaptureStatus.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PendingCaptureStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case PendingCaptureStatus.queued:
      default:
        return const Icon(Icons.pending, color: Colors.orange);
    }
  }

  Widget _buildStatusBadge(PendingCaptureStatus status) {
    String text;
    Color bgColor;
    
    switch (status) {
      case PendingCaptureStatus.syncing:
        text = 'Syncing';
        bgColor = Colors.blue;
        break;
      case PendingCaptureStatus.failed:
        text = 'Failed';
        bgColor = Colors.red;
        break;
      case PendingCaptureStatus.queued:
      default:
        text = 'Queued';
        bgColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: bgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _retryPendingUploads(
    BuildContext context,
    FirestoreService firestoreService,
    StateSetter setSheetState,
  ) async {
    // In-flight guard: prevent duplicate sync attempts
    if (!OfflineCaptureQueue.startSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync already in progress'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setSheetState(() {});
    setState(() {});

    int successCount = 0;
    int failCount = 0;

    // Process queue (oldest first)
    for (int i = 0; i < _pendingItems.length; i++) {
      // Mark item as syncing
      setSheetState(() {
        _syncingIndices.add(0); // Always index 0 since we remove from front
      });

      final capture = _pendingItems[i];
      try {
        await firestoreService.saveCaptureToFolder(
          capture.folderId,
          capture.transcript,
        );
        successCount++;
        // Remove from queue after successful upload
        await OfflineCaptureQueue.removeFromQueue(0);
        
        // Reload queue to reflect changes
        await _loadPendingQueue();
        setSheetState(() {
          _syncingIndices.clear();
        });
      } catch (e) {
        failCount++;
        // Mark as failed and stop
        setSheetState(() {
          _syncingIndices.clear();
          if (_pendingItems.isNotEmpty) {
            _pendingItems[0].status = PendingCaptureStatus.failed;
          }
        });
        break;
      }
    }

    // End sync
    OfflineCaptureQueue.endSync();
    
    // Reload pending count
    await _loadPendingQueue();

    setSheetState(() {});
    setState(() {});

    if (!context.mounted) return;

    // Show result
    final messenger = ScaffoldMessenger.of(context);
    if (successCount > 0 && failCount == 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Synced $successCount capture${successCount == 1 ? '' : 's'}'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (_pendingCount == 0) {
        Navigator.pop(context); // Close sheet if all synced
      }
    } else if (failCount > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('$successCount synced, $failCount failed - check connection'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sync failed - check your connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Widget _buildFolderTile(BuildContext context, DealFolder folder) {
    return ListTile(
      leading: _buildPriorityIndicator(folder.priority),
      title: Text(folder.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (folder.category != null)
            Text('Category: ${folder.category}'),
          if (folder.boothHall != null)
            Text('Booth/Hall: ${folder.boothHall}'),
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
    final supplierController = TextEditingController();
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
                      controller: supplierController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Name (optional)',
                        hintText: 'e.g., ABC Electronics Co.',
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
                    // At least one of supplierName, category, or boothHall should be provided
                    if (supplierController.text.isNotEmpty || 
                        selectedCategory != null || 
                        boothController.text.isNotEmpty) {
                      firestoreService.createDealFolder(
                        supplierName: supplierController.text.isNotEmpty ? supplierController.text : null,
                        boothHall: boothController.text.isNotEmpty ? boothController.text : null,
                        category: selectedCategory,
                        priority: selectedPriority,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill at least one field')),
                      );
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
