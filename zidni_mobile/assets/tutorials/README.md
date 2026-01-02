# Tutorial Assets

This directory contains Rive animation files and Arabic voiceover audio for in-app tutorials.

## Expected Files

### Rive Animations (.riv)
- `gul_tutorial.riv` — GUL voice translation tutorial
- `eyes_tutorial.riv` — EYES product scanning tutorial
- `alwakil_tutorial.riv` — Alwakil trading agent tutorial
- `memory_tutorial.riv` — Memory deal history tutorial
- `dealmaker_tutorial.riv` — Deal Maker tutorial
- `wallet_tutorial.riv` — Zidni Pay wallet tutorial
- `packs_tutorial.riv` — Context Packs tutorial

### Arabic Voiceover Audio (.mp3)
- `gul_tutorial_ar.mp3` — GUL tutorial voiceover
- `eyes_tutorial_ar.mp3` — EYES tutorial voiceover
- `alwakil_tutorial_ar.mp3` — Alwakil tutorial voiceover
- `memory_tutorial_ar.mp3` — Memory tutorial voiceover
- `dealmaker_tutorial_ar.mp3` — Deal Maker tutorial voiceover
- `wallet_tutorial_ar.mp3` — Wallet tutorial voiceover
- `packs_tutorial_ar.mp3` — Context Packs tutorial voiceover

## Creating Rive Animations

1. Go to [rive.app](https://rive.app) and create a new file
2. Design animations for each tutorial step
3. Use State Machine to create states matching `animationState` values in `tutorial_registry.dart`:
   - `intro` — Introduction animation
   - Step-specific states (e.g., `blue_mic`, `green_mic`, `scanning`, etc.)
4. Export as `.riv` file
5. Place in this directory

## Creating Arabic Voiceover

1. Record or generate Arabic voiceover for each tutorial
2. Ensure timing matches step durations in `tutorial_registry.dart`
3. Export as `.mp3` format
4. Place in this directory

## Integration

The `TutorialRegistry` service maps topics to asset paths. The `TutorialPlayer` service handles playback synchronization between Rive animations and audio.

## Notes

- Rive files should be optimized for mobile (< 500KB each)
- Audio files should be compressed (128kbps MP3)
- Total assets should not exceed 10MB for initial release
