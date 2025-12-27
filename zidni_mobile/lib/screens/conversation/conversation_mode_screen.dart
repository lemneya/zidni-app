import 'package:flutter/material.dart';
import 'package:zidni_mobile/services/stt_engine.dart';
import 'package:zidni_mobile/services/translation_service.dart';
import 'package:zidni_mobile/services/tts_service.dart';
import 'package:zidni_mobile/services/intro_message_service.dart';

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
}

/// A single turn in the conversation
class TurnItem {
  final TurnLang from;
  final TargetLang target; // The target language for this turn
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
/// 
/// Entry point: ZidniAppBar → Ravigh icon
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
  TurnLang? _recordingLang; // null when not recording
  TurnLang _nextTurn = TurnLang.ar; // default start
  TargetLang _selectedTarget = TargetLang.zh; // default target language
  final List<TurnItem> _turns = []; // latest first
  
  // Services
  final TranslationService _translationService = StubTranslationService();
  final TtsService _ttsService = TtsService();
  late final IntroMessageService _introService;
  
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
    
    final from = _recordingLang!;
    final to = from == TurnLang.ar ? TurnLang.target : TurnLang.ar;
    
    // Stop listening
    await widget.sttEngine.stopListening();
    
    // Determine translation codes
    final fromCode = from == TurnLang.ar ? 'ar' : _selectedTarget.code;
    final toCode = to == TurnLang.ar ? 'ar' : _selectedTarget.code;
    
    // Translate
    final translation = await _translationService.translate(
      text: transcript,
      fromLang: fromCode,
      toLang: toCode,
    );
    
    // Create turn item with current target language
    final turnItem = TurnItem(
      from: from,
      target: _selectedTarget, // Save the target language with the turn
      transcript: transcript,
      translation: translation,
      at: DateTime.now(),
    );
    
    setState(() {
      _turns.insert(0, turnItem);
      _nextTurn = to; // opposite of from
      _recordingLang = null; // done recording
    });
  }
  
  /// Start recording for a specific language
  Future<void> _startRecording(TurnLang lang) async {
    if (_recordingLang != null) return; // already recording
    
    setState(() {
      _recordingLang = lang;
    });
    
    // Initialize and start STT
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
  
  /// Stop recording manually
  Future<void> _stopRecording() async {
    if (_recordingLang == null) return;
    await widget.sttEngine.stopListening();
  }
  
  /// Speak Arabic text for a turn
  Future<void> _speakAr(TurnItem turn) async {
    await _ttsService.stop();
    // Speak Arabic: if turn is from AR, speak transcript; else speak translation
    final text = turn.from == TurnLang.ar ? turn.transcript : turn.translation;
    await _ttsService.speak(text, 'ar');
  }
  
  /// Speak target language text for a turn
  Future<void> _speakTarget(TurnItem turn) async {
    await _ttsService.stop();
    // Speak target: if turn is from target, speak transcript; else speak translation
    final text = turn.from == TurnLang.target ? turn.transcript : turn.translation;
    await _ttsService.speak(text, turn.target.ttsLocale);
  }
  
  @override
  Widget build(BuildContext context) {
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
        ),
        body: SafeArea(
          child: Column(
            children: [
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
              
              // Intro message buttons row
              _buildIntroButtonsRow(),
              
              // Two big buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Arabic button
                    Expanded(
                      child: _buildTurnButton(
                        lang: TurnLang.ar,
                        label: 'أنا أتحدث',
                        flag: '🇸🇦',
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Target button
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
                          ? () => setState(() => _selectedTarget = lang)
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
    
    // Determine button state
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
      borderColor = Colors.grey.withOpacity(0.5);
    }
    
    Widget buttonContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(flag, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.grey : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Recording indicator
        if (isRecording) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 12 * _pulseAnimation.value,
                    height: 12 * _pulseAnimation.value,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'يسجل الآن',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        // Next turn indicator
        if (isNextTurn && !isRecording) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'دورك الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
    
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _startRecording(lang),
      onTapUp: isRecording ? (_) => _stopRecording() : null,
      onTapCancel: isRecording ? _stopRecording : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: buttonContent,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'اضغط مع الاستمرار للتحدث',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTurnCard(TurnItem turn) {
    final isArabicToTarget = turn.from == TurnLang.ar;
    final headerText = isArabicToTarget 
        ? 'AR → ${turn.target.code.toUpperCase()}' 
        : '${turn.target.code.toUpperCase()} → AR';
    final headerColor = isArabicToTarget ? Colors.blue : Colors.orange;
    
    return Card(
      color: const Color(0xFF2A2A4E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with language indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    headerText,
                    style: TextStyle(
                      color: headerColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  turn.target.flag,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Transcript section
            const Text(
              'النص:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              turn.transcript,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            
            // Translation section
            const Text(
              'الترجمة:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              turn.translation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            // TTS buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _speakAr(turn),
                    icon: const Text('🔊'),
                    label: const Text('Speak Arabic'),
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
  
  /// Build the intro message buttons row
  Widget _buildIntroButtonsRow() {
    final isDisabled = _recordingLang != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Speak intro button
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
              // Copy intro button
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
}
