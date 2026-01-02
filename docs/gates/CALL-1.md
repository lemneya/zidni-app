# CALL-1: Call Companion Mode

## Overview

Call Companion Mode solves the critical follow-up bottleneck for Arab traders at Canton Fair. When traders need to call suppliers or receive calls from them, real-time translation is essential.

## Problem Statement

After meeting suppliers at Canton Fair, traders need to:
1. Call suppliers to follow up on quotes
2. Receive calls from suppliers with updates
3. Exchange voice messages via WeChat/WhatsApp

Without translation, these interactions are impossible for Arabic-speaking traders who don't speak Chinese.

## Solution: Call Companion Mode

### Semi-Duplex Translation

Since intercepting phone calls is not possible on iOS/Android, we use a **speakerphone companion approach**:

1. User puts phone call on speaker
2. Opens Zidni Call Companion
3. Uses LISTEN button when supplier speaks Chinese → sees Arabic translation
4. Uses SPEAK button to speak Arabic → Zidni speaks Chinese translation aloud

### Voice Message Translation

For WeChat/WhatsApp voice messages:
1. Share voice message to Zidni
2. Zidni transcribes Chinese → shows Arabic translation
3. User records Arabic reply
4. Zidni generates Chinese voice file → user shares back

## Features

### 1. Call Companion Screen
- **LISTEN button** (green): Capture Chinese → Arabic translation display
- **SPEAK button** (blue): Capture Arabic → Chinese TTS output
- Translation history with copy functionality
- Speakerphone usage instructions

### 2. Voice Message Screen
- Receive shared audio files from other apps
- Transcribe and translate Chinese voice messages
- Record Arabic replies
- Generate Chinese voice files for sharing

### 3. Offline Pack Manager
- Download Whisper STT model (~150 MB)
- Download ML Kit translation models (~30 MB each)
- Check system TTS voice availability
- Progress tracking and status display

## Technical Implementation

### Offline-First Architecture

| Component | Package/Approach |
|-----------|------------------|
| Speech-to-Text | Whisper.cpp via whisper_ggml |
| Translation | Google ML Kit on-device |
| Text-to-Speech | System TTS (platform channels) |
| Share-in | file_share_intent |
| Share-out | share_plus |

### Files Created

**Models (3 files)**
- `audio_chunk.dart` - Audio recording chunk model
- `voice_message.dart` - Voice message model
- `offline_pack_status.dart` - Offline pack status model

**Services (6 files)**
- `whisper_stt_service.dart` - Whisper STT wrapper
- `mlkit_translation_service.dart` - ML Kit translation wrapper
- `tts_to_file_service.dart` - TTS to file via platform channels
- `audio_pipeline_service.dart` - Recording → STT → Translation → TTS pipeline
- `offline_pack_manager.dart` - Model download and status management
- `share_intent_handler.dart` - Handle incoming shared files

**Screens (3 files)**
- `call_companion_screen.dart` - Main call companion UI
- `voice_message_screen.dart` - Voice message translation UI
- `offline_pack_screen.dart` - Offline pack management UI

**Widgets (5 files)**
- `listen_button.dart` - Green LISTEN button
- `speak_button.dart` - Blue SPEAK button
- `translation_display.dart` - Translation history display
- `voice_message_card.dart` - Voice message card
- `how_to_use_sheet.dart` - Instructions bottom sheet

**Documentation (1 file)**
- `docs/gates/CALL-1.md` - This file

## Acceptance Criteria

- [x] "Call Companion" accessible from home screen
- [x] LISTEN mode: Chinese → Arabic translation display
- [x] SPEAK mode: Arabic → Chinese TTS output
- [x] Voice message share-in from WeChat/WhatsApp
- [x] Voice message transcription and translation
- [x] Arabic reply generates Chinese voice file
- [x] Share-out functionality
- [x] Works fully offline (after model download)
- [x] Locked files NOT modified
- [x] Offline Pack Manager shows download status

## Locked Files (NOT MODIFIED)

- `lib/widgets/gul_control.dart`
- `lib/services/stt_engine.dart`
- `lib/services/stt_engine_speech_to_text.dart`

## User Flow

### Making a Call to Supplier

```
1. User dials supplier number
2. Puts phone on speaker
3. Opens Zidni → Call Companion
4. Supplier speaks Chinese
5. User taps LISTEN → sees Arabic translation
6. User taps SPEAK → speaks Arabic
7. Zidni speaks Chinese translation aloud
8. Supplier hears and responds
9. Repeat until conversation complete
```

### Translating Voice Message

```
1. User receives Chinese voice message in WeChat
2. Long-press → Share → Zidni
3. Zidni opens Voice Message screen
4. User taps "Translate"
5. Sees Arabic translation
6. Taps "Record Reply" → speaks Arabic
7. Zidni generates Chinese voice file
8. User taps "Share" → sends to WeChat
```

## Future Enhancements

- Real-time streaming transcription
- Conversation history sync
- Supplier contact integration
- Automatic language detection
- Multi-language support beyond Chinese/Arabic
