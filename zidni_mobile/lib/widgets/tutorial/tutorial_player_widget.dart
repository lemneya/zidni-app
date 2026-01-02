import 'package:flutter/material.dart';
import '../../services/tutorial/tutorial_registry.dart';
import '../../services/tutorial/tutorial_player.dart';

/// Tutorial player widget for displaying and controlling tutorial playback.
/// Shows Rive animation placeholder, step content, and playback controls.
class TutorialPlayerWidget extends StatefulWidget {
  final TutorialTopic topic;
  final VoidCallback? onComplete;
  final VoidCallback? onClose;

  const TutorialPlayerWidget({
    super.key,
    required this.topic,
    this.onComplete,
    this.onClose,
  });

  @override
  State<TutorialPlayerWidget> createState() => _TutorialPlayerWidgetState();
}

class _TutorialPlayerWidgetState extends State<TutorialPlayerWidget> {
  final TutorialPlayer _player = TutorialPlayer();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutorial();
    
    // Listen to state changes
    _player.stateStream.listen((state) {
      if (mounted) setState(() {});
      if (state == TutorialPlaybackState.completed) {
        widget.onComplete?.call();
      }
    });
    
    // Listen to step changes
    _player.stepStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadTutorial() async {
    await _player.loadTutorial(widget.topic);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              _buildHeader(),
              
              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _buildContent(),
              ),
              
              // Controls
              if (!_isLoading) _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tutorial name
          Expanded(
            child: Text(
              _player.currentTutorial?.nameArabic ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _player.stop();
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final step = _player.currentStep;
    if (step == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Animation area (placeholder for Rive)
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder icon based on topic
                  Icon(
                    _getTopicIcon(),
                    size: 80,
                    color: _getTopicColor().withOpacity(0.8),
                  ),
                  const SizedBox(height: 16),
                  // Animation state indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getTopicColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      step.animationState ?? 'intro',
                      style: TextStyle(
                        color: _getTopicColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rive Animation',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Step content
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  children: [
                    Text(
                      'الخطوة ${_player.currentStepIndex + 1} من ${_player.totalSteps}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // Progress indicator
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: _player.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTopicColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Step title
                Text(
                  step.titleArabic,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Step description
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      step.descriptionArabic,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 32),
            color: _player.currentStepIndex > 0
                ? _getTopicColor()
                : Colors.grey[300],
            onPressed: _player.currentStepIndex > 0
                ? () => _player.previousStep()
                : null,
          ),

          // Play/Pause button
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _getTopicColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getTopicColor().withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _player.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
              ),
              color: Colors.white,
              onPressed: () {
                if (_player.isPlaying) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.skip_next, size: 32),
            color: _player.currentStepIndex < _player.totalSteps - 1
                ? _getTopicColor()
                : Colors.grey[300],
            onPressed: _player.currentStepIndex < _player.totalSteps - 1
                ? () => _player.nextStep()
                : null,
          ),
        ],
      ),
    );
  }

  IconData _getTopicIcon() {
    switch (widget.topic) {
      case TutorialTopic.gul:
        return Icons.mic;
      case TutorialTopic.eyes:
        return Icons.camera_alt;
      case TutorialTopic.alwakil:
        return Icons.support_agent;
      case TutorialTopic.memory:
        return Icons.history;
      case TutorialTopic.dealMaker:
        return Icons.handshake;
      case TutorialTopic.wallet:
        return Icons.account_balance_wallet;
      case TutorialTopic.contextPacks:
        return Icons.inventory_2;
    }
  }

  Color _getTopicColor() {
    switch (widget.topic) {
      case TutorialTopic.gul:
        return const Color(0xFF2196F3);
      case TutorialTopic.eyes:
        return const Color(0xFF4CAF50);
      case TutorialTopic.alwakil:
        return const Color(0xFF9C27B0);
      case TutorialTopic.memory:
        return const Color(0xFFFF9800);
      case TutorialTopic.dealMaker:
        return const Color(0xFFE91E63);
      case TutorialTopic.wallet:
        return const Color(0xFF1565C0);
      case TutorialTopic.contextPacks:
        return const Color(0xFF00BCD4);
    }
  }
}
