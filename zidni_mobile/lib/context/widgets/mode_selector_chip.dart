import 'package:flutter/material.dart';
import '../models/context_pack.dart';
import '../services/context_service.dart';
import 'mode_picker_sheet.dart';

/// Mode Selector Chip
/// Gate LOC-1: Context Packs + Mode Selector
///
/// Small chip/row on the GUL screen showing current context pack
/// with option to change via bottom sheet.

class ModeSelectorChip extends StatefulWidget {
  /// Callback when pack changes
  final ValueChanged<ContextPack>? onPackChanged;
  
  const ModeSelectorChip({
    super.key,
    this.onPackChanged,
  });

  @override
  State<ModeSelectorChip> createState() => _ModeSelectorChipState();
}

class _ModeSelectorChipState extends State<ModeSelectorChip> {
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
  
  Future<void> _openModePicker() async {
    final selectedPack = await ModePickerSheet.show(
      context,
      currentPack: _currentPack,
    );
    
    if (selectedPack != null && selectedPack != _currentPack) {
      await ContextService.setSelectedPack(selectedPack);
      setState(() {
        _currentPack = selectedPack;
      });
      widget.onPackChanged?.call(selectedPack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPack == null) {
      return const SizedBox.shrink();
    }
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: _openModePicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _currentPack!.themeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _currentPack!.themeColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode label
              Text(
                'الوضع:',
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              
              // Pack icon
              Icon(
                _currentPack!.icon,
                color: _currentPack!.themeColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              
              // Pack name
              Text(
                _currentPack!.titleAr,
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: _currentPack!.themeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              
              // Change button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _currentPack!.themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'تغيير',
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    color: _currentPack!.themeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
