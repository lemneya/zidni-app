import 'package:flutter/material.dart';
import 'package:zidni_mobile/screens/conversation/conversation_mode_screen.dart';
import 'package:zidni_mobile/services/stt_engine.dart';

class ZidniAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SttEngine sttEngine;
  
  const ZidniAppBar({
    super.key,
    required this.sttEngine,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      // START (right in RTL): Search, Map
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Search'),
          IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () {},
              tooltip: 'Map'),
        ],
      ),
      leadingWidth: 120,
      // CENTER: Eyes (OCR)
      title: IconButton(
          icon: const Icon(Icons.visibility_outlined),
          onPressed: () {},
          tooltip: 'Eyes'),
      centerTitle: true,
      // END (left in RTL): Ravigh (Conversation Mode), Apps
      actions: [
        IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _openConversationMode(context),
            tooltip: 'Ravigh - Conversation Mode'),
        IconButton(
            icon: const Icon(Icons.apps), onPressed: () {}, tooltip: 'Apps'),
      ],
    );
  }
  
  void _openConversationMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationModeScreen(
          sttEngine: sttEngine,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
