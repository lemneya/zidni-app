/// Offline Pack Screen for Call Companion Mode
/// UI for downloading and managing offline models

import 'package:flutter/material.dart';

import '../../models/call_companion/offline_pack_status.dart';
import '../../services/call_companion/offline_pack_manager.dart';

/// Screen for managing offline packs
class OfflinePackScreen extends StatefulWidget {
  const OfflinePackScreen({super.key});

  @override
  State<OfflinePackScreen> createState() => _OfflinePackScreenState();
}

class _OfflinePackScreenState extends State<OfflinePackScreen> {
  final _packManager = OfflinePackManager.instance;
  late OfflinePackStatus _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();

    // Listen for status changes
    _packManager.onStatusChanged = (status) {
      setState(() {
        _status = status;
      });
    };
  }

  Future<void> _loadStatus() async {
    final status = await _packManager.initialize();
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  Future<void> _downloadAll() async {
    await _packManager.downloadAll();
  }

  Future<void> _downloadPack(String packId) async {
    switch (packId) {
      case 'whisper_base':
        await _packManager.downloadWhisperModel();
        break;
      case 'mlkit_zh':
        await _packManager.downloadChineseTranslation();
        break;
      case 'mlkit_ar':
        await _packManager.downloadArabicTranslation();
        break;
    }
  }

  Future<void> _deletePack(String packId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف النموذج'),
        content: const Text('هل أنت متأكد من حذف هذا النموذج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _packManager.deletePack(packId);
    }
  }

  void _showTtsInstructions(String languageCode) {
    final instructions = _packManager.getTtsInstallInstructions(languageCode);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageCode == 'zh' ? 'تثبيت الصوت الصيني' : 'تثبيت الصوت العربي'),
        content: Text(instructions),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _packManager.refreshTtsStatus();
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'النماذج للعمل بدون إنترنت',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status summary
                    _buildStatusSummary(),

                    const SizedBox(height: 24),

                    // Download all button
                    if (!_status.allPacksReady)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _downloadAll,
                          icon: const Icon(Icons.download),
                          label: Text(
                            'تحميل الكل (${_status.totalSizeDisplay})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Pack list
                    const Text(
                      'النماذج المطلوبة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Whisper model
                    _buildPackCard(_status.whisperModel),

                    // Chinese translation
                    _buildPackCard(_status.chineseTranslation),

                    // Arabic translation
                    _buildPackCard(_status.arabicTranslation),

                    const SizedBox(height: 24),

                    // TTS section
                    const Text(
                      'أصوات النظام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chinese TTS
                    _buildTtsCard(
                      'الصوت الصيني',
                      'zh',
                      _status.chineseTtsAvailable,
                    ),

                    // Arabic TTS
                    _buildTtsCard(
                      'الصوت العربي',
                      'ar',
                      _status.arabicTtsAvailable,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    final isReady = _status.isFullyReady;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReady
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.warning_amber,
            color: isReady ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? 'جاهز للعمل بدون إنترنت' : 'يتطلب تحميل النماذج',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _status.readinessSummaryAr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(OfflinePackItem pack) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status icon
              _buildStatusIcon(pack.status),
              const SizedBox(width: 12),

              // Pack info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.nameAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.sizeDisplay,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Action button
              _buildPackAction(pack),
            ],
          ),

          // Progress bar
          if (pack.isDownloading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: pack.progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 4),
            Text(
              '${pack.progressPercent}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],

          // Error message
          if (pack.status == PackDownloadStatus.failed &&
              pack.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              pack.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(PackDownloadStatus status) {
    switch (status) {
      case PackDownloadStatus.ready:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case PackDownloadStatus.downloading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PackDownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 24);
      case PackDownloadStatus.notDownloaded:
        return Icon(Icons.cloud_download, color: Colors.white.withOpacity(0.5), size: 24);
    }
  }

  Widget _buildPackAction(OfflinePackItem pack) {
    switch (pack.status) {
      case PackDownloadStatus.ready:
        return IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deletePack(pack.id),
        );
      case PackDownloadStatus.downloading:
        return const SizedBox.shrink();
      case PackDownloadStatus.failed:
      case PackDownloadStatus.notDownloaded:
        return TextButton(
          onPressed: () => _downloadPack(pack.id),
          child: const Text('تحميل'),
        );
    }
  }

  Widget _buildTtsCard(String name, String languageCode, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.warning_amber,
            color: isAvailable ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          if (!isAvailable)
            TextButton(
              onPressed: () => _showTtsInstructions(languageCode),
              child: const Text('كيفية التثبيت'),
            ),
        ],
      ),
    );
  }
}
