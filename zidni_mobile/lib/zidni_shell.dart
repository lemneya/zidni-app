import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zidni_mobile/models/deal_folder.dart';
import 'package:zidni_mobile/screens/deals/deal_folders_screen.dart';
import 'package:zidni_mobile/services/firestore_service.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
import 'package:zidni_mobile/widgets/gul_capture_sheet.dart';
import 'package:zidni_mobile/widgets/gul_control.dart';
import 'package:zidni_mobile/widgets/zidni_app_bar.dart';
import 'package:zidni_mobile/widgets/zidni_bottom_nav.dart';

// Placeholder screen for demonstrating navigation
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class ZidniShell extends StatefulWidget {
  final SttEngine sttEngine;
  const ZidniShell({super.key, required this.sttEngine});

  @override
  State<ZidniShell> createState() => _ZidniShellState();
}

class _ZidniShellState extends State<ZidniShell> {
  int _selectedIndex = 0;
  bool _isSheetOpen = false;
  String? _lastSelectedFolderId; // In-memory "last selected folder"

  static const List<Widget> _widgetOptions = <Widget>[
    PlaceholderScreen(title: 'Home'),
    DealFoldersScreen(),
    SizedBox.shrink(), // Placeholder for index 2 (GUL)
    PlaceholderScreen(title: 'Pay'),
    PlaceholderScreen(title: 'Me'),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // GUL is FAB only, no action on nav bar
    setState(() => _selectedIndex = index);
  }

  void _handleSaveCapture(BuildContext context, String transcript) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    if (_lastSelectedFolderId != null) {
      firestoreService.saveCaptureToFolder(_lastSelectedFolderId!, transcript);
    } else {
      _showFolderChooser(context, transcript);
    }
  }

  void _showFolderChooser(BuildContext context, String transcript) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<List<DealFolder>>(
          stream: firestoreService.getDealFolders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final folders = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.create_new_folder),
                  title: const Text('Create New Folder'),
                  onTap: () {
                    Navigator.pop(context);
                    _showNewFolderDialog(context, transcript);
                  },
                ),
                ...folders.map((folder) {
                  return ListTile(
                    title: Text(folder.title),
                    onTap: () {
                      _lastSelectedFolderId = folder.id;
                      firestoreService.saveCaptureToFolder(folder.id, transcript);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  void _showNewFolderDialog(BuildContext context, String transcript) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Deal Folder'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Folder Title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final newFolder = await firestoreService.createDealFolder(titleController.text);
                  _lastSelectedFolderId = newFolder.id;
                  firestoreService.saveCaptureToFolder(newFolder.id, transcript);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create & Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleSttResult(SttPayload finalResult) {
    if (finalResult.transcript.trim().isNotEmpty && !_isSheetOpen) {
      setState(() => _isSheetOpen = true);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => GulCaptureSheet(
          transcript: finalResult.transcript,
          onSave: (capture) {
            _handleSaveCapture(context, capture.transcript);
          },
        ),
      ).whenComplete(() => setState(() => _isSheetOpen = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [Provider<FirestoreService>(create: (_) => FirestoreService())],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: const ZidniAppBar(),
            body: _widgetOptions[_selectedIndex],
            floatingActionButton: GulControl(
              sttEngine: widget.sttEngine,
              onSttResult: _handleSttResult,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: ZidniBottomNav(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ));
  }
}
