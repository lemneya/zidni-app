import 'package:flutter/material.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
import 'package:zidni_mobile/eyes/eyes.dart';
import 'package:zidni_mobile/os/os.dart';
import 'package:zidni_mobile/context/context.dart';
import 'package:zidni_mobile/services/translation_service.dart';
import 'package:zidni_mobile/services/tts_service.dart';
import 'package:zidni_mobile/services/intro_message_service.dart';
import 'package:zidni_mobile/services/conversation_prefs_service.dart';
import 'package:zidni_mobile/services/location_country_service.dart';
import 'package:zidni_mobile/services/quick_phrase_pack_service.dart';
import 'package:zidni_mobile/widgets/quick_phrases_bar.dart';

/// Turn language enum (Arabic or Target)
enum TurnLang { ar, target }

/// Target language options
enum TargetLang { zh, en, tr, es }

/// Extension for TargetLang to get display info
extension TargetLangExtension on TargetLang {
  String get code {
    switch (this) {
      case TargetLang.zh: return 'zh';
      case TargetLang.en: return 'en';
      case TargetLang.tr: return 'tr';
      case TargetLang.es: return 'es';
    }
  }
  
  String get ttsLocale {
    switch (this) {
      case TargetLang.zh: return 'zh-CN';
      case TargetLang.en: return 'en-US';
      case TargetLang.tr: return 'tr-TR';
      case TargetLang.es: return 'es-ES';
    }
  }
  
  String get flag {
    switch (this) {
      case TargetLang.zh: return '🇨🇳';
      case TargetLang.en: return '🇺🇸';
      case TargetLang.tr: return '🇹🇷';
      case TargetLang.es: return '🇪🇸';
    }
  }
  
  String get arabicName {
    switch (this) {
      case TargetLang.zh: return 'الصينية';
      case TargetLang.en: return 'الإنجليزية';
      case TargetLang.tr: return 'التركية';
      case TargetLang.es: return 'الإسبانية';
    }
  }
  
  String get nativeName {
    switch (this) {
      case TargetLang.zh: return '中文';
      case TargetLang.en: return 'English';
      case TargetLang.tr: return 'Türkçe';
      case TargetLang.es: return 'Español';
    }
  }
  
  /// Hand-the-phone instruction text
  String get handoffInstruction {
    switch (this) {
      case TargetLang.zh: return '请现在说话。句子短一点。';
      case TargetLang.en: return 'Please speak now. Keep it short.';
      case TargetLang.tr: return 'Lütfen şimdi konuşun. Kısa cümlelerle.';
      case TargetLang.es: return 'Habla ahora, por favor. Frases cortas.';
    }
  }
}

/// A single turn in the conversation
class TurnItem {
  final TurnLang from;
  final TargetLang target;
  final String transcript;
  final String translation;
  final DateTime at;
  
  TurnItem({
    required this.from,
    required this.target,
    required this.transcript,
    required this.translation,
    required this.at,
  });
}

/// Conversation Mode Screen for AR ⇄ Multi-target turn-taking
class ConversationModeScreen extends StatefulWidget {
  final SttEngine sttEngine;
  
  const ConversationModeScreen({
    super.key,
    required this.sttEngine,
  });

  @override
  State<ConversationModeScreen> createState() => _ConversationModeScreenState();
}

class _ConversationModeScreenState extends State<ConversationModeScreen>
    with SingleTickerProviderStateMixin {
  
  // State machine variables
  TurnLang? _recordingLang;
  TurnLang _nextTurn = TurnLang.ar;
  TargetLang _selectedTarget = TargetLang.zh;
  final List<TurnItem> _turns = [];
  
  // Gate #15: New state variables
  bool _handoffMode = false;
  bool _useLocationDefault = false;
  bool _loudMode = false;
  String? _detectedCountryCode;
  bool _locationAutoApplied = false;
  
  // Services
  final TranslationService _translationService = StubTranslationService();
  final TtsService _ttsService = TtsService();
  late final IntroMessageService _introService;
  final ConversationPrefsService _prefsService = ConversationPrefsService();
  final LocationCountryService _locationService = LocationCountryService();
  
  // Pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize TTS and intro service
    _ttsService.init();
    _introService = IntroMessageService(_ttsService);
    
    // Set up STT callback
    widget.sttEngine.onResult = _onSttPayload;
    
    // Pulse animation for recording indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    
    // Load preferences
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    await _prefsService.init();
    setState(() {
      _useLocationDefault = _prefsService.useLocationDefault;
      _loudMode = _prefsService.loudMode;
      _selectedTarget = _prefsService.lastSelectedTarget;
      _ttsService.setLoudMode(_loudMode);
    });
    
    // Apply location-based default if enabled
    if (_useLocationDefault) {
      await _applyLocationDefault();
    }
    
    // Gate LOC-1: Show context suggestion modal if needed
    if (mounted) {
      ContextSuggestionModal.showIfNeeded(
        context,
        onPackSelected: () {
          // Refresh to apply pack settings
          _applyContextPackSettings();
        },
      );
    }
  }
  
  Future<void> _applyLocationDefault() async {
    final countryCode = await _locationService.getCountryCode();
    if (countryCode == null) return;
    
    // Only apply if country changed or first open
    final lastCountry = _prefsService.lastCountryApplied;
    if (countryCode != lastCountry) {
      final target = _locationService.getTargetForCountry(countryCode);
      setState(() {
        _detectedCountryCode = countryCode;
        _selectedTarget = target;
        _locationAutoApplied = true;
      });
      await _prefsService.setLastCountryApplied(countryCode);
      await _prefsService.setLastSelectedTarget(target);
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _ttsService.dispose();
    super.dispose();
  }
  
  /// Handle STT final result
  void _onSttPayload(SttPayload payload) async {
    final transcript = payload.transcript;
    if (transcript.isEmpty || _recordingLang == null) return;
    
    // Gate OS-1: Check for voice commands before processing translation
    final voiceCommand = VoiceCommandRouter.detectCommand(transcript);
    if (voiceCommand.isCommand && VoiceCommandRouter.isPureCommand(transcript)) {
      await widget.sttEngine.stopListening();
      setState(() {
        _recordingLang = null;
      });
      _handleVoiceCommand(voiceCommand);
      return;
    }
    
    final from = _recordingLang!;
    final to = from == TurnLang.ar ? TurnLang.target : TurnLang.ar;
    
    await widget.sttEngine.stopListening();
    
    final fromCode = from == TurnLang.ar ? 'ar' : _selectedTarget.code;
    final toCode = to == TurnLang.ar ? 'ar' : _selectedTarget.code;
    
    final translation = await _translationService.translate(
      text: transcript,
      fromLang: fromCode,
      toLang: toCode,
    );
    
    final turnItem = TurnItem(
      from: from,
      target: _selectedTarget,
      transcript: transcript,
      translation: translation,
      at: DateTime.now(),
    );
    
    setState(() {
      _turns.insert(0, turnItem);
      _nextTurn = to;
      _recordingLang = null;
      // Exit handoff mode after recording
      if (_handoffMode) {
        _handoffMode = false;
      }
    });
  }
  
  Future<void> _startRecording(TurnLang lang) async {
    if (_recordingLang != null) return;
    
    setState(() {
      _recordingLang = lang;
    });
    
    final initialized = await widget.sttEngine.initialize();
    if (!initialized) {
      setState(() {
        _recordingLang = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تهيئة التعرف على الصوت')),
        );
      }
      return;
    }
    
    await widget.sttEngine.startListening();
  }
  
  Future<void> _stopRecording() async {
    if (_recordingLang == null) return;
    await widget.sttEngine.stopListening();
  }
  
  Future<void> _speakAr(TurnItem turn) async {
    await _ttsService.stop();
    final text = turn.from == TurnLang.ar ? turn.transcript : turn.translation;
    await _ttsService.speak(text, 'ar');
  }
  
  Future<void> _speakTarget(TurnItem turn) async {
    await _ttsService.stop();
    final text = turn.from == TurnLang.target ? turn.transcript : turn.translation;
    await _ttsService.speak(text, turn.target.ttsLocale);
  }
  
  Future<void> _toggleLocationDefault(bool value) async {
    if (value && !await _locationService.hasPermission()) {
      final granted = await _locationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم منح إذن الموقع')),
          );
        }
        return;
      }
    }
    
    setState(() {
      _useLocationDefault = value;
      if (!value) {
        _locationAutoApplied = false;
        _detectedCountryCode = null;
      }
    });
    await _prefsService.setUseLocationDefault(value);
    
    if (value) {
      await _applyLocationDefault();
    }
  }
  
  Future<void> _toggleLoudMode(bool value) async {
    setState(() {
      _loudMode = value;
      _ttsService.setLoudMode(value);
    });
    await _prefsService.setLoudMode(value);
  }
  
  // Gate LOC-1: Context Pack handlers
  void _onContextPackChanged(ContextPack pack) {
    _applyContextPackSettings();
  }
  
  Future<void> _applyContextPackSettings() async {
    final pack = await ContextService.getSelectedPack();
    
    // Apply default language pair
    final langPair = pack.defaultLangPair;
    TargetLang newTarget;
    switch (langPair.targetCode) {
      case 'zh':
        newTarget = TargetLang.zh;
        break;
      case 'en':
        newTarget = TargetLang.en;
        break;
      case 'es':
        newTarget = TargetLang.es;
        break;
      default:
        newTarget = TargetLang.en;
    }
    
    // Apply loud mode default
    final shouldEnableLoud = pack.loudModeDefault;
    
    setState(() {
      _selectedTarget = newTarget;
      if (shouldEnableLoud && !_loudMode) {
        _loudMode = true;
        _ttsService.setLoudMode(true);
      }
    });
    
    // Save preferences
    await _prefsService.setLastSelectedTarget(newTarget);
    if (shouldEnableLoud) {
      await _prefsService.setLoudMode(true);
    }
  }
  
  void _enterHandoffMode() {
    if (_recordingLang != null) return;
    setState(() {
      _handoffMode = true;
    });
  }
  
  void _exitHandoffMode() {
    if (_recordingLang != null) return;
    setState(() {
      _handoffMode = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Show handoff mode if active
    if (_handoffMode) {
      return _buildHandoffScreen();
    }
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          title: const Text(
            'وضع المحادثة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // History button (Gate OS-1)
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: _openHistory,
              tooltip: 'السجل',
            ),
            // Eyes scan button (Gate EYES-1)
            const EyesScanButton(size: 24, color: Colors.white),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Settings row (location + loud mode)
              _buildSettingsRow(),
              
              // Context Pack Mode Selector (Gate LOC-1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ModeSelectorChip(
                  onPackChanged: _onContextPackChanged,
                ),
              ),
              
              // Location auto-selection chip
              if (_locationAutoApplied && _detectedCountryCode != null)
                _buildLocationChip(),
              
              // Language selector
              _buildLanguageSelector(),
              
              // Helper text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'اضغط الزر المناسب لكل طرف',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Quick phrases bar (Gate #16)
              _buildQuickPhrasesBar(),
              
              // Intro message buttons row
              _buildIntroButtonsRow(),
              
              // Hand-the-phone button
              _buildHandoffButton(),
              
              // Two big buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTurnButton(
                        lang: TurnLang.ar,
                        label: 'أنا أتحدث',
                        flag: '🇸🇦',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTurnButton(
                        lang: TurnLang.target,
                        label: 'هو يتحدث',
                        flag: _selectedTarget.flag,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Results list
              Expanded(
                child: _turns.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _turns.length,
                        itemBuilder: (context, index) {
                          return _buildTurnCard(_turns[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Location toggle
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'موقع',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Switch(
                  value: _useLocationDefault,
                  onChanged: _recordingLang == null ? _toggleLocationDefault : null,
                  activeColor: Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          // Loud mode toggle
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.volume_up, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'صوت عالي',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Switch(
                  value: _loudMode,
                  onChanged: _recordingLang == null ? _toggleLoudMode : null,
                  activeColor: Colors.orange,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationChip() {
    final countryName = _locationService.getCountryName(_detectedCountryCode);
    final targetName = _selectedTarget.arabicName;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'تم اختيار $targetName لأنك في $countryName',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Focus on language selector (scroll to it or highlight)
                setState(() {
                  _locationAutoApplied = false;
                });
              },
              child: const Text(
                'تغيير',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await _toggleLocationDefault(false);
              },
              child: const Text(
                'إيقاف',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHandoffButton() {
    final isDisabled = _recordingLang != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : _enterHandoffMode,
        icon: const Text('📱', style: TextStyle(fontSize: 16)),
        label: const Text('أعطِ الهاتف للطرف الآخر'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.withOpacity(0.3)
              : Colors.purple.withOpacity(0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),
    );
  }
  
  Widget _buildHandoffScreen() {
    return Directionality(
      textDirection: TextDirection.ltr, // LTR for target language user
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Target language flag
              Text(
                _selectedTarget.flag,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              
              // Instruction text in target language
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _selectedTarget.handoffInstruction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              
              // Big start button
              GestureDetector(
                onTapDown: (_) => _startRecording(TurnLang.target),
                onTapUp: (_) => _stopRecording(),
                onTapCancel: _stopRecording,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = _recordingLang == TurnLang.target
                        ? _pulseAnimation.value
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _recordingLang == TurnLang.target
                              ? Colors.red
                              : Colors.green,
                          boxShadow: [
                            BoxShadow(
                              color: (_recordingLang == TurnLang.target
                                      ? Colors.red
                                      : Colors.green)
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _recordingLang == TurnLang.target ? '🎤' : 'ابدأ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Recording indicator
              if (_recordingLang == TurnLang.target)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTarget == TargetLang.zh
                          ? '正在录音...'
                          : _selectedTarget == TargetLang.tr
                              ? 'Kaydediliyor...'
                              : _selectedTarget == TargetLang.es
                                  ? 'Grabando...'
                                  : 'Recording...',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              
              const Spacer(),
              
              // Back button (Arabic)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton.icon(
                    onPressed: _recordingLang == null ? _exitHandoffMode : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('رجوع'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
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
  
  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'اللغة:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TargetLang.values.map((lang) {
                  final isSelected = _selectedTarget == lang;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: _recordingLang == null
                          ? () async {
                              setState(() => _selectedTarget = lang);
                              await _prefsService.setLastSelectedTarget(lang);
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lang.flag, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              lang.arabicName,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTurnButton({
    required TurnLang lang,
    required String label,
    required String flag,
  }) {
    final isRecording = _recordingLang == lang;
    final isOtherRecording = _recordingLang != null && _recordingLang != lang;
    final isNextTurn = _recordingLang == null && _nextTurn == lang;
    
    Color bgColor;
    Color borderColor;
    bool isDisabled = isOtherRecording;
    
    if (isRecording) {
      bgColor = Colors.red.withOpacity(0.3);
      borderColor = Colors.red;
    } else if (isNextTurn) {
      bgColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
    } else {
      bgColor = Colors.grey.withOpacity(0.1);
      borderColor = Colors.grey.withOpacity(0.3);
    }
    
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _startRecording(lang),
      onTapUp: isDisabled ? null : (_) => _stopRecording(),
      onTapCancel: isDisabled ? null : _stopRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = isRecording ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRecording) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'يسجل الآن',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  if (isNextTurn && !isRecording) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'دورك الآن',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text(
            'ابدأ المحادثة',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'اضغط مع الاستمرار على الزر للتحدث',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTurnCard(TurnItem turn) {
    final isFromAr = turn.from == TurnLang.ar;
    final header = isFromAr
        ? 'AR → ${turn.target.code.toUpperCase()}'
        : '${turn.target.code.toUpperCase()} → AR';
    
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFromAr
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    header,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${turn.at.hour}:${turn.at.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'النص:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            Text(
              turn.transcript,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'الترجمة:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            Text(
              turn.translation,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _speakAr(turn),
                    icon: const Text('🔊'),
                    label: const Text('نطق عربي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _speakTarget(turn),
                    icon: const Text('🔊'),
                    label: Text('Speak ${turn.target.nativeName}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIntroButtonsRow() {
    final isDisabled = _recordingLang != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDisabled
                      ? null
                      : () async {
                          await _introService.speak(_selectedTarget);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تشغيل الرسالة'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                  icon: const Text('🗣️'),
                  label: const Text('رسالة افتتاحية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDisabled
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.teal.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDisabled
                      ? null
                      : () async {
                          await _introService.copyToClipboard(_selectedTarget);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ الرسالة'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                  icon: const Text('📋'),
                  label: const Text('نسخ الرسالة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDisabled
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'اضغطها مرة واحدة قبل البدء',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build quick phrases bar (Gate #16)
  Widget _buildQuickPhrasesBar() {
    // Get phrases based on country (if location enabled) or default pack
    final countryCode = _useLocationDefault ? _detectedCountryCode : null;
    final phrases = QuickPhrasePackService.getPhrasesForCountry(countryCode);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: QuickPhrasesBar(
        phrases: phrases,
        targetLang: _selectedTarget,
        ttsService: _ttsService,
        isDisabled: _recordingLang != null,
      ),
    );
  }
  
  /// Gate OS-1: Handle voice commands detected from STT
  void _handleVoiceCommand(VoiceCommandResult command) {
    switch (command.type) {
      case VoiceCommandType.openEyes:
        _openEyesScan();
        break;
      case VoiceCommandType.none:
        // Should not reach here, but handle gracefully
        break;
    }
  }
  
  /// Gate OS-1: Open Eyes scan screen
  void _openEyesScan() {
    // Show feedback that command was recognized
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري فتح المسح...'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 1),
      ),
    );
    
    // Navigate to Eyes scan screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EyesScanScreen(),
      ),
    );
  }
  
  /// Gate OS-1: Open unified history screen
  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UnifiedHistoryScreen(),
      ),
    );
  }
}
