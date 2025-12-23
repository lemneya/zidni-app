/// Represents the payload returned upon a speech-to-text recognition.
/// Minimal for MVP; expand later only if approved.
class SttPayload {
  final String transcript;
  const SttPayload({required this.transcript});
}

/// Defines the possible states of the Speech-to-Text engine.
enum SttStatus {
  idle,
  listening,
  processing,
  /// Service unavailable OR permission missing.
  /// Terminal for the current interaction (no auto-retry / no auto-recovery).
  blocked,
}

/// Abstract interface for a Speech-to-Text (STT) engine.
/// UI (GUL) must remain decoupled from implementation details.
abstract class SttEngine {
  /// Broadcasts current engine status for visuals only.
  Stream<SttStatus> get status;

  /// Final result handoff only. No side effects required/assumed by the engine.
  void Function(SttPayload payload)? onResult;

  /// Performs a silent capability check (no permission prompts, no UI).
  /// Must be safe to call multiple times.
  Future<bool> initialize();

  /// Starts recognition. Should only succeed from idle.
  /// Must not auto-start outside explicit user press.
  Future<void> startListening();

  /// Stops recognition and finalizes result.
  Future<void> stopListening();

  /// Cancels recognition with no transcript.
  Future<void> cancelListening();

  void dispose();
}