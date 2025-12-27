import 'package:flutter/material.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
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

  static const List<Widget> _widgetOptions = <Widget>[
    PlaceholderScreen(title: 'Home'),
    PlaceholderScreen(title: 'Alwakeel'),
    SizedBox.shrink(), // Placeholder for index 2 (GUL)
    PlaceholderScreen(title: 'Pay'),
    PlaceholderScreen(title: 'Me'),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // GUL is FAB only, no action on nav bar
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: ZidniAppBar(sttEngine: widget.sttEngine),
        body: _widgetOptions[_selectedIndex],
        floatingActionButton: GulControl(
          sttEngine: widget.sttEngine,
          onSttResult: (_) {}, // no logs / no auto-actions
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ZidniBottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
