import 'dart:async';
import 'tutorial_registry.dart';

/// Tutorial playback state.
enum TutorialPlaybackState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Tutorial player service for controlling tutorial playback.
/// Manages Rive animation state and audio synchronization.
class TutorialPlayer {
  final TutorialRegistry _registry = TutorialRegistry();
  
  TutorialData? _currentTutorial;
  int _currentStepIndex = 0;
  TutorialPlaybackState _state = TutorialPlaybackState.idle;
  
  final StreamController<TutorialPlaybackState> _stateController =
      StreamController<TutorialPlaybackState>.broadcast();
  final StreamController<int> _stepController =
      StreamController<int>.broadcast();

  /// Current tutorial being played.
  TutorialData? get currentTutorial => _currentTutorial;

  /// Current step index (0-based).
  int get currentStepIndex => _currentStepIndex;

  /// Current step data.
  TutorialStep? get currentStep {
    if (_currentTutorial == null) return null;
    if (_currentStepIndex >= _currentTutorial!.steps.length) return null;
    return _currentTutorial!.steps[_currentStepIndex];
  }

  /// Total number of steps in current tutorial.
  int get totalSteps => _currentTutorial?.steps.length ?? 0;

  /// Current playback state.
  TutorialPlaybackState get state => _state;

  /// Stream of playback state changes.
  Stream<TutorialPlaybackState> get stateStream => _stateController.stream;

  /// Stream of step index changes.
  Stream<int> get stepStream => _stepController.stream;

  /// Whether the tutorial is currently playing.
  bool get isPlaying => _state == TutorialPlaybackState.playing;

  /// Whether the tutorial has completed.
  bool get isCompleted => _state == TutorialPlaybackState.completed;

  /// Loads a tutorial by topic.
  Future<void> loadTutorial(TutorialTopic topic) async {
    _setState(TutorialPlaybackState.loading);
    
    try {
      _currentTutorial = _registry.getTutorial(topic);
      _currentStepIndex = 0;
      _stepController.add(_currentStepIndex);
      _setState(TutorialPlaybackState.idle);
    } catch (e) {
      _setState(TutorialPlaybackState.error);
      rethrow;
    }
  }

  /// Starts or resumes playback.
  void play() {
    if (_currentTutorial == null) return;
    if (_state == TutorialPlaybackState.completed) {
      // Restart from beginning
      _currentStepIndex = 0;
      _stepController.add(_currentStepIndex);
    }
    _setState(TutorialPlaybackState.playing);
    _startStepTimer();
  }

  /// Pauses playback.
  void pause() {
    _cancelStepTimer();
    _setState(TutorialPlaybackState.paused);
  }

  /// Stops playback and resets to beginning.
  void stop() {
    _cancelStepTimer();
    _currentStepIndex = 0;
    _stepController.add(_currentStepIndex);
    _setState(TutorialPlaybackState.idle);
  }

  /// Advances to the next step.
  void nextStep() {
    if (_currentTutorial == null) return;
    if (_currentStepIndex < _currentTutorial!.steps.length - 1) {
      _currentStepIndex++;
      _stepController.add(_currentStepIndex);
      if (_state == TutorialPlaybackState.playing) {
        _startStepTimer();
      }
    } else {
      // Reached the end
      _setState(TutorialPlaybackState.completed);
    }
  }

  /// Goes back to the previous step.
  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _stepController.add(_currentStepIndex);
      if (_state == TutorialPlaybackState.playing) {
        _startStepTimer();
      }
    }
  }

  /// Jumps to a specific step.
  void goToStep(int index) {
    if (_currentTutorial == null) return;
    if (index < 0 || index >= _currentTutorial!.steps.length) return;
    _currentStepIndex = index;
    _stepController.add(_currentStepIndex);
    if (_state == TutorialPlaybackState.playing) {
      _startStepTimer();
    }
  }

  /// Returns the Rive state machine state name for the current step.
  String? get currentAnimationState => currentStep?.animationState;

  /// Returns the progress as a value between 0.0 and 1.0.
  double get progress {
    if (_currentTutorial == null || _currentTutorial!.steps.isEmpty) return 0.0;
    return (_currentStepIndex + 1) / _currentTutorial!.steps.length;
  }

  Timer? _stepTimer;

  void _startStepTimer() {
    _cancelStepTimer();
    final step = currentStep;
    if (step == null) return;
    
    _stepTimer = Timer(step.duration, () {
      nextStep();
    });
  }

  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _setState(TutorialPlaybackState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Disposes resources.
  void dispose() {
    _cancelStepTimer();
    _stateController.close();
    _stepController.close();
  }
}
