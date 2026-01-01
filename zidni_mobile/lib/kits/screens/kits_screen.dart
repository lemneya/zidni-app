/// Kits Screen
/// Gate LOC-3: Offline Kits + Safe Optional Updates
///
/// Shows installed kits, active kit, and update checking.

import 'package:flutter/material.dart';
import '../models/offline_kit.dart';
import '../services/kit_service.dart';
import '../services/kit_update_service.dart';

class KitsScreen extends StatefulWidget {
  const KitsScreen({super.key});

  @override
  State<KitsScreen> createState() => _KitsScreenState();
}

class _KitsScreenState extends State<KitsScreen> {
  List<OfflineKit> _installedKits = [];
  OfflineKit? _activeKit;
  bool _isLoading = true;
  bool _isCheckingUpdates = false;
  bool _updateAvailable = false;
  String? _updateMessage;
  
  @override
  void initState() {
    super.initState();
    _loadKits();
  }
  
  Future<void> _loadKits() async {
    setState(() => _isLoading = true);
    
    try {
      final installed = await KitService.getInstalledKits();
      final active = await KitService.getActiveKit();
      final hasUpdate = await KitUpdateService.isUpdateAvailable();
      
      setState(() {
        _installedKits = installed;
        _activeKit = active;
        _updateAvailable = hasUpdate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdates = true;
      _updateMessage = null;
    });
    
    final result = await KitUpdateService.checkForUpdates();
    
    setState(() {
      _isCheckingUpdates = false;
      if (result.success) {
        if (result.hasUpdates) {
          _updateMessage = 'تم العثور على ${result.newKitsCount + result.updatedKitsCount} تحديثات';
          _updateAvailable = true;
        } else {
          _updateMessage = 'لا توجد تحديثات جديدة';
        }
      } else {
        _updateMessage = 'فشل التحقق: ${result.errorMessage}';
      }
    });
    
    // Reload kits if updates were found
    if (result.hasUpdates) {
      await _loadKits();
    }
  }
  
  Future<void> _activateKit(OfflineKit kit) async {
    await KitService.activateKit(kit);
    setState(() => _activeKit = kit);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تفعيل: ${kit.titleAr}',
            style: const TextStyle(fontFamily: 'NotoSansArabic'),
          ),
          backgroundColor: kit.themeColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'حِزم جاهزة',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_updateAvailable)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تحديث متاح',
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Update check section
                _buildUpdateSection(),
                
                // Installed kits list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _installedKits.length,
                    itemBuilder: (context, index) {
                      final kit = _installedKits[index];
                      final isActive = _activeKit?.id == kit.id;
                      return _buildKitCard(kit, isActive);
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildUpdateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF0F3460), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCheckingUpdates ? null : _checkForUpdates,
                  icon: _isCheckingUpdates
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isCheckingUpdates ? 'جاري التحقق...' : 'التحقق من التحديثات',
                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_updateMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _updateMessage!,
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                color: _updateMessage!.contains('فشل')
                    ? Colors.red.shade300
                    : Colors.green.shade300,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildKitCard(OfflineKit kit, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? kit.themeColor.withOpacity(0.2) : const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? kit.themeColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isActive ? null : () => _activateKit(kit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Kit icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kit.themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  kit.icon,
                  color: kit.themeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Kit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kit.titleAr,
                            style: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kit.themeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'نشط',
                              style: TextStyle(
                                fontFamily: 'NotoSansArabic',
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (kit.isBundled)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'مدمج',
                              style: TextStyle(
                                fontFamily: 'NotoSansArabic',
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kit.descriptionAr,
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Phrase packs preview
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: kit.phrasePacks.take(4).map((pack) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pack.titleAr,
                            style: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Activate button
              if (!isActive)
                IconButton(
                  onPressed: () => _activateKit(kit),
                  icon: const Icon(Icons.play_circle_outline),
                  color: kit.themeColor,
                  iconSize: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
