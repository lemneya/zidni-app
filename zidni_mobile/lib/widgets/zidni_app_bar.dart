import 'package:flutter/material.dart';

class ZidniAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZidniAppBar({super.key});

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
      // END (left in RTL): Ravigh, Apps
      actions: [
        IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {},
            tooltip: 'Ravigh'),
        IconButton(
            icon: const Icon(Icons.apps), onPressed: () {}, tooltip: 'Apps'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
