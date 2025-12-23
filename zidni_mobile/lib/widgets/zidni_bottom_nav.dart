import 'package:flutter/material.dart';

class ZidniBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const ZidniBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(context, theme, Icons.home_outlined, 'Home', 0),
          _buildNavItem(context, theme, Icons.support_agent_outlined, 'Alwakeel', 1),
          const IgnorePointer(child: SizedBox(width: 48)), // GUL placeholder
          _buildNavItem(context, theme, Icons.payment_outlined, 'Pay', 3),
          _buildNavItem(context, theme, Icons.person_outline, 'Me', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    int index,
  ) {
    final color = selectedIndex == index
        ? theme.colorScheme.primary
        : Colors.grey;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
