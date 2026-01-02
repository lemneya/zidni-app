/// Call Companion Screen for Call Companion Mode
/// Main UI for real-time phone call translation
///
/// Features:
/// - LISTEN button: Capture source language → Show Arabic translation
/// - SPEAK button: Capture Arabic → Speak source language translation
/// - Language selector: Chinese, English, Turkish
/// - Speakerphone hint and instructions
/// - Translation history display

import 'package:flutter/material.dart';

import '../../models/call_companion/audio_chunk.dart';
import '../../models/call_companion/supported_language.dart';
import '../../services/call_companion/audio_pipeline_service.dart';
import '../../services/call_companion/offline_pack_manager.dart';
import '../../widgets/call_companion/listen_button.dart';
import '../../widgets/call_companion/speak_button.dart';
import '../../widgets/call_companion/translation_display.dart';
import '../../widgets/call_companion/how_to_use_sheet.dart';
import '../../widgets/call_companion/language_selector.dart';
import 'offline_pack_screen.dart';

/// Main screen for Call Companion Mode
class CallCompanionScreen extends StatefulWidget {
  const CallCompanionScreen({super.key});

  @override
  State<CallCompanionScreen> createState() => _CallCompanionScreenState();
}

class _CallCompanionScreenState extends State<CallCompanionScreen> {
  final _pipelineService = AudioPipelineService.instance;
  final _packManager = OfflinePackManager.instance;

  /// List of processed translations
  final List<TranslationEntry> _translations = [];

  /// Current pipeline state
  PipelineState _pipelineState = PipelineState.idle;

  /// Current mode (listen or speak)
  PipelineMode? _currentMode;

  /// Whether offline packs are ready
  bool _isOfflineReady = false;

  /// Currently selected language pair
  LanguagePair _selectedPair = LanguagePair.chineseArabic;

  /// Available language pairs (with downloaded models)
  List<LanguagePair> _availablePairs = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Check offline pack status
    final status = await _packManager.initialize();
    setState(() {
      _isOfflineReady = status.isFullyReady;
      _availablePairs = _packManager.getAvailableLanguagePairs();
      
      // If current pair is not available, switch to first available
      if (_availablePairs.isNotEmpty && !_availablePairs.contains(_selectedPair)) {
        _selectedPair = _availablePairs.first;
      }
    });

    // Initialize pipeline with selected language pair
    await _pipelineService.initialize();
    _pipelineService.setLanguagePair(_selectedPair);

    // Set up callbacks
    _pipelineService.onStateChanged = (state) {
      setState(() {
        _pipelineState = state;
      });
    };

    _pipelineService.onResult = (result) {
      setState(() {
        _translations.insert(
          0,
          TranslationEntry(
            sourceText: result.transcribedText,
            translatedText: result.translatedText,
            sourceLanguage: result.sourceLanguage,
            targetLanguage: result.targetLanguage,
            timestamp: DateTime.now(),
          ),
        );
      });
    };

    _pipelineService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  @override
  void dispose() {
    _pipelineService.dispose();
    super.dispose();
  }

  /// Handle language pair change
  void _onLanguageChanged(LanguagePair pair) {
    setState(() {
      _selectedPair = pair;
    });
    _pipelineService.setLanguagePair(pair);
  }

  /// Handle LISTEN button press
  void _onListenPressed() async {
    if (_pipelineState == PipelineState.idle) {
      setState(() {
        _currentMode = PipelineMode.listen;
      });
      await _pipelineService.startListening();
    } else if (_pipelineState == PipelineState.recording &&
        _currentMode == PipelineMode.listen) {
      await _pipelineService.stopAndProcess();
      setState(() {
        _currentMode = null;
      });
    }
  }

  /// Handle SPEAK button press
  void _onSpeakPressed() async {
    if (_pipelineState == PipelineState.idle) {
      setState(() {
        _currentMode = PipelineMode.speak;
      });
      await _pipelineService.startSpeaking();
    } else if (_pipelineState == PipelineState.recording &&
        _currentMode == PipelineMode.speak) {
      await _pipelineService.stopAndProcess();
      setState(() {
        _currentMode = null;
      });
    }
  }

  /// Show how to use sheet
  void _showHowToUse() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HowToUseSheet(),
    );
  }

  /// Navigate to offline pack manager
  void _openOfflinePacks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OfflinePackScreen()),
    ).then((_) async {
      // Refresh status when returning
      final status = await _packManager.initialize();
      setState(() {
        _isOfflineReady = status.isFullyReady;
        _availablePairs = _packManager.getAvailableLanguagePairs();
      });
    });
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
            'رفيق المكالمات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: _showHowToUse,
            ),
            IconButton(
              icon: Icon(
                Icons.cloud_download,
                color: _isOfflineReady ? Colors.green : Colors.orange,
              ),
              onPressed: _openOfflinePacks,
            ),
          ],
        ),
        body: Column(
          children: [
            // Language selector
            _buildLanguageSelector(),

            // Speakerphone hint
            _buildSpeakerphoneHint(),

            // Offline status warning
            if (!_isOfflineReady) _buildOfflineWarning(),

            // Translation display area
            Expanded(
              child: TranslationDisplay(
                translations: _translations,
                isProcessing: _pipelineState != PipelineState.idle,
                processingState: _pipelineState,
              ),
            ),

            // Control buttons
            _buildControlButtons(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LanguageSelector(
            selectedPair: _selectedPair,
            availablePairs: _availablePairs,
            onChanged: _onLanguageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerphoneHint() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مطلوب مكبر الصوت',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'ضع المكالمة على مكبر الصوت ليتمكن زدني من سماع المحادثة',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showHowToUse,
            child: const Text(
              'كيفية الاستخدام',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineWarning() {
    return GestureDetector(
      onTap: _openOfflinePacks,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'يجب تحميل النماذج للعمل بدون إنترنت',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    final isRecordingListen =
        _pipelineState == PipelineState.recording && _currentMode == PipelineMode.listen;
    final isRecordingSpeak =
        _pipelineState == PipelineState.recording && _currentMode == PipelineMode.speak;
    final isProcessing = _pipelineState != PipelineState.idle &&
        _pipelineState != PipelineState.recording;

    // Dynamic labels based on selected language
    final listenLabel = '${_selectedPair.source.nameAr} ← عربي';
    final speakLabel = 'عربي ← ${_selectedPair.source.nameAr}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Language indicator
          Text(
            '${_selectedPair.source.flag} ${_selectedPair.source.nameAr} ↔ ${_selectedPair.target.flag} ${_selectedPair.target.nameAr}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LISTEN button (Source → Arabic)
              ListenButton(
                isActive: isRecordingListen,
                isDisabled: isProcessing || isRecordingSpeak,
                onPressed: _onListenPressed,
              ),

              // SPEAK button (Arabic → Source)
              SpeakButton(
                isActive: isRecordingSpeak,
                isDisabled: isProcessing || isRecordingListen,
                onPressed: _onSpeakPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Entry in the translation history
class TranslationEntry {
  final String sourceText;
  final String translatedText;
  final SupportedLanguage sourceLanguage;
  final SupportedLanguage targetLanguage;
  final DateTime timestamp;

  TranslationEntry({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  /// Whether the source is not Arabic (for display purposes)
  bool get isChineseSource => sourceLanguage != SupportedLanguage.arabic;
}
