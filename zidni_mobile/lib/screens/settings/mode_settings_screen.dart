import 'package:flutter/material.dart';
import '../../models/app_mode.dart';
import '../../services/mode/mode_coordinator.dart';
import '../../services/mode/mode_state_store.dart';

/// Settings screen for manually selecting app mode.
/// 
/// This screen allows users to:
/// - View and select their preferred app mode
/// - Enable/disable automatic mode switching
/// - Reset mode preferences
class ModeSettingsScreen extends StatefulWidget {
  const ModeSettingsScreen({super.key});

  @override
  State<ModeSettingsScreen> createState() => _ModeSettingsScreenState();
}

class _ModeSettingsScreenState extends State<ModeSettingsScreen> {
  late AppMode _selectedMode;
  late bool _autoModeEnabled;

  @override
  void initState() {
    super.initState();
    _selectedMode = ModeCoordinator.instance.currentMode;
    _autoModeEnabled = ModeStateStore.instance.autoModeEnabled;
  }

  void _onModeSelected(AppMode mode) async {
    setState(() {
      _selectedMode = mode;
    });
    await ModeCoordinator.instance.setMode(mode);
  }

  void _onAutoModeChanged(bool value) async {
    setState(() {
      _autoModeEnabled = value;
    });
    await ModeStateStore.instance.setAutoModeEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'إعدادات الوضع' : 'Mode Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Auto mode toggle
            Card(
              child: SwitchListTile(
                title: Text(
                  isArabic ? 'التبديل التلقائي للوضع' : 'Auto Mode Switching',
                ),
                subtitle: Text(
                  isArabic
                      ? 'اقتراح الوضع المناسب بناءً على موقعك'
                      : 'Suggest appropriate mode based on your location',
                ),
                value: _autoModeEnabled,
                onChanged: _onAutoModeChanged,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                isArabic ? 'اختر الوضع' : 'Select Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Mode options
            ...AppMode.values.map((mode) => _buildModeCard(mode, isArabic)),
            
            const SizedBox(height: 24),
            
            // Reset button
            OutlinedButton.icon(
              onPressed: _onReset,
              icon: const Icon(Icons.refresh),
              label: Text(
                isArabic ? 'إعادة تعيين التفضيلات' : 'Reset Preferences',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(AppMode mode, bool isArabic) {
    final isSelected = mode == _selectedMode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: _getModeColor(mode), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _onModeSelected(mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mode icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getModeColor(mode).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getModeIcon(mode),
                  color: _getModeColor(mode),
                ),
              ),
              const SizedBox(width: 16),
              
              // Mode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.getLocalizedName(isArabic ? 'ar' : 'en'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getModeDescription(mode, isArabic),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: _getModeColor(mode),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        return AlertDialog(
          title: Text(isArabic ? 'إعادة تعيين؟' : 'Reset?'),
          content: Text(
            isArabic
                ? 'سيتم إعادة تعيين جميع تفضيلات الوضع إلى الإعدادات الافتراضية.'
                : 'All mode preferences will be reset to defaults.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isArabic ? 'إعادة تعيين' : 'Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ModeStateStore.instance.reset();
      setState(() {
        _selectedMode = AppMode.travel;
        _autoModeEnabled = true;
      });
    }
  }

  Color _getModeColor(AppMode mode) {
    switch (mode) {
      case AppMode.immigration:
        return Colors.blue;
      case AppMode.cantonFair:
        return Colors.orange;
      case AppMode.home:
        return Colors.green;
      case AppMode.travel:
        return Colors.purple;
    }
  }

  IconData _getModeIcon(AppMode mode) {
    switch (mode) {
      case AppMode.immigration:
        return Icons.assignment_ind;
      case AppMode.cantonFair:
        return Icons.store;
      case AppMode.home:
        return Icons.home;
      case AppMode.travel:
        return Icons.flight;
    }
  }

  String _getModeDescription(AppMode mode, bool isArabic) {
    if (isArabic) {
      switch (mode) {
        case AppMode.immigration:
          return 'للمهاجرين العرب في الولايات المتحدة';
        case AppMode.cantonFair:
          return 'للتجار في معرض كانتون والصين';
        case AppMode.home:
          return 'للمستخدمين في منطقة الشرق الأوسط وشمال أفريقيا';
        case AppMode.travel:
          return 'للمسافرين حول العالم';
      }
    } else {
      switch (mode) {
        case AppMode.immigration:
          return 'For Arab immigrants in the USA';
        case AppMode.cantonFair:
          return 'For traders at Canton Fair and China';
        case AppMode.home:
          return 'For users in the MENA region';
        case AppMode.travel:
          return 'For travelers around the world';
      }
    }
  }
}
