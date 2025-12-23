import 'package:flutter/material.dart';
import 'services/stt_engine.dart';
import 'widgets/gul_control.dart';

// Placeholder screens for the bottom navigation
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

  const ZidniShell({
    super.key,
    required this.sttEngine,
  });

  @override
  State<ZidniShell> createState() => _ZidniShellState();
}

class _ZidniShellState extends State<ZidniShell> {
  int _selectedIndex = 0;

  // GUL has no screen, so we map indices to screen widgets
  final List<Widget> _screens = const [
    PlaceholderScreen(title: 'Home'),
    PlaceholderScreen(title: 'Alwakeel'),
    SizedBox.shrink(), // Placeholder for GUL index
    PlaceholderScreen(title: 'Pay'),
    PlaceholderScreen(title: 'Me'),
  ];

  void _onItemTapped(int index) {
    // GUL is at index 2 and has no screen.
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Per instructions, force RTL for the shell
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const _ZidniAppBar(),
        body: SafeArea(child: _screens[_selectedIndex]),
        floatingActionButton: GulControl(
          sttEngine: widget.sttEngine,
          onSttResult: (_) {
            // No actions for now
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _ZidniBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class _ZidniAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ZidniAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      // RTL layout: Search/Map are at the start (right)
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.map_outlined), onPressed: () {}),
        ],
      ),
      leadingWidth: 120,
      // Ravigh/Apps are at the end (left)
      actions: [
        IconButton(icon: const Icon(Icons.apps), onPressed: () {}),
        IconButton(icon: const Icon(Icons.lightbulb_outline), onPressed: () {}), // Placeholder for Ravigh
      ],
      // Eyes (OCR) is in the center
      title: IconButton(icon: const Icon(Icons.visibility_outlined), onPressed: () {}),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class _ZidniBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ZidniBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(context, icon: Icons.home_outlined, label: 'Home', index: 0),
          _buildNavItem(context, icon: Icons.support_agent_outlined, label: 'Alwakeel', index: 1),
          const SizedBox(width: 48), // The placeholder for the FAB
          _buildNavItem(context, icon: Icons.payment_outlined, label: 'Pay', index: 3),
          _buildNavItem(context, icon: Icons.person_outline, label: 'Me', index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final bool isSelected = currentIndex == index;
    // Get the theme color for the icon
    final Color color = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => onTap(index),
      tooltip: label,
    );
  }
}
