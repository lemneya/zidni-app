import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../context_packs.dart';
import '../models/context_pack.dart';
import '../services/context_service.dart';

/// A row of quick action shortcuts that changes based on the selected context pack.
/// 
/// Guangzhou pack: Eyes Scan, Create Deal, 1688, Baidu
/// USA/Egypt/Travel: Eyes Scan, History, Taxi, Hotel
class PackShortcutsRow extends StatefulWidget {
  /// Callback when Eyes Scan is tapped
  final VoidCallback? onEyesScanTap;
  
  /// Callback when Create Deal is tapped
  final VoidCallback? onCreateDealTap;
  
  /// Callback when History is tapped
  final VoidCallback? onHistoryTap;
  
  const PackShortcutsRow({
    super.key,
    this.onEyesScanTap,
    this.onCreateDealTap,
    this.onHistoryTap,
  });

  @override
  State<PackShortcutsRow> createState() => _PackShortcutsRowState();
}

class _PackShortcutsRowState extends State<PackShortcutsRow> {
  ContextPack? _currentPack;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentPack();
  }
  
  Future<void> _loadCurrentPack() async {
    final pack = await ContextService.getSelectedPack();
    if (mounted) {
      setState(() {
        _currentPack = pack;
      });
    }
  }
  
  bool get _isGuangzhouMode => _currentPack?.id == 'guangzhou_cantonfair';
  
  @override
  Widget build(BuildContext context) {
    if (_currentPack == null) {
      return const SizedBox.shrink();
    }
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _isGuangzhouMode
                ? _buildGuangzhouShortcuts()
                : _buildDefaultShortcuts(),
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildGuangzhouShortcuts() {
    return [
      _buildShortcutButton(
        icon: Icons.document_scanner,
        label: 'مسح المنتج',
        color: Colors.purple,
        onTap: widget.onEyesScanTap,
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.handshake,
        label: 'إنشاء صفقة',
        color: Colors.green,
        onTap: widget.onCreateDealTap,
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.store,
        label: '1688',
        color: Colors.orange,
        onTap: () => _launchUrl('https://www.1688.com'),
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.search,
        label: 'بايدو',
        color: Colors.blue,
        onTap: () => _launchUrl('https://www.baidu.com'),
      ),
    ];
  }
  
  List<Widget> _buildDefaultShortcuts() {
    return [
      _buildShortcutButton(
        icon: Icons.document_scanner,
        label: 'مسح المنتج',
        color: Colors.purple,
        onTap: widget.onEyesScanTap,
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.history,
        label: 'السجل',
        color: Colors.teal,
        onTap: widget.onHistoryTap,
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.local_taxi,
        label: 'تاكسي',
        color: Colors.amber,
        onTap: null, // Placeholder
      ),
      const SizedBox(width: 8),
      _buildShortcutButton(
        icon: Icons.hotel,
        label: 'فندق',
        color: Colors.indigo,
        onTap: null, // Placeholder
      ),
    ];
  }
  
  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled 
              ? color.withOpacity(0.15)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled 
                ? color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? color : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                color: isEnabled ? color : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// A helper widget that shows the pack-specific header accent
class PackAccentHeader extends StatefulWidget {
  const PackAccentHeader({super.key});

  @override
  State<PackAccentHeader> createState() => _PackAccentHeaderState();
}

class _PackAccentHeaderState extends State<PackAccentHeader> {
  ContextPack? _currentPack;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentPack();
  }
  
  Future<void> _loadCurrentPack() async {
    final pack = await ContextService.getSelectedPack();
    if (mounted) {
      setState(() {
        _currentPack = pack;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentPack == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentPack!.themeColor.withOpacity(0.8),
            _currentPack!.themeColor.withOpacity(0.2),
          ],
        ),
      ),
    );
  }
}
