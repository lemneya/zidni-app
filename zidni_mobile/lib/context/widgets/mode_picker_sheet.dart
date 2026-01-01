import 'package:flutter/material.dart';
import '../models/context_pack.dart';
import '../context_packs.dart';
import '../../kits/kits.dart';

/// Mode Picker Sheet
/// Gate LOC-1: Context Packs + Mode Selector
///
/// Bottom sheet showing all available context packs
/// with radio selection and save.

class ModePickerSheet extends StatefulWidget {
  /// Currently selected pack
  final ContextPack? currentPack;
  
  const ModePickerSheet({
    super.key,
    this.currentPack,
  });
  
  /// Show the mode picker sheet
  static Future<ContextPack?> show(
    BuildContext context, {
    ContextPack? currentPack,
  }) {
    return showModalBottomSheet<ContextPack>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModePickerSheet(currentPack: currentPack),
    );
  }

  @override
  State<ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<ModePickerSheet> {
  late ContextPack _selectedPack;
  
  @override
  void initState() {
    super.initState();
    _selectedPack = widget.currentPack ?? ContextPacks.defaultPack;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر الوضع',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'حدد سياق استخدامك لتجربة مخصصة',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white12, height: 1),
              
              // Pack list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: ContextPacks.all.length,
                  itemBuilder: (context, index) {
                    final pack = ContextPacks.all[index];
                    return _buildPackTile(pack);
                  },
                ),
              ),
              
              // Kits link
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KitsScreen()),
                  );
                },
                icon: const Icon(Icons.inventory_2, color: Colors.white70, size: 18),
                label: const Text(
                  'حِزم جاهزة',
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Save button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedPack),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPack.themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPackTile(ContextPack pack) {
    final isSelected = pack.id == _selectedPack.id;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPack = pack;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? pack.themeColor.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? pack.themeColor 
              : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? pack.themeColor : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pack.themeColor,
                      ),
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            
            // Pack icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: pack.themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                pack.icon,
                color: pack.themeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Pack info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.titleAr,
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: isSelected ? pack.themeColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pack.descriptionAr,
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Language pair badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pack.themeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pack.defaultLangPair.arabicName,
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: pack.themeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loud mode indicator
            if (pack.loudModeDefault)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
