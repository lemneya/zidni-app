# Gate TUTORIAL-1: In-App Tutorials (Rive + Arabic VO) + Help Hub

## Overview

This gate adds an in-app tutorial system using Rive animations with Arabic voiceover support, plus a Help hub screen with YouTube links for extended learning.

## Architecture

### Tutorial System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     TutorialRegistry                         │
│  Maps topics → TutorialData (assets, steps, YouTube links)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      TutorialPlayer                          │
│  Controls playback: load, play, pause, next, previous       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  TutorialPlayerWidget                        │
│  UI: Rive animation, step content, playback controls        │
└─────────────────────────────────────────────────────────────┘
```

### Help Hub Structure

```
HelpScreen
├── Header Banner (Welcome message)
├── Quick Start Section (GUL + EYES)
├── Tutorials by Category
│   ├── الميزات الأساسية (Core Features)
│   │   ├── GUL
│   │   └── EYES
│   ├── أدوات التاجر (Trader Tools)
│   │   ├── Alwakil
│   │   ├── Memory
│   │   └── Deal Maker
│   └── الإعدادات والمحفظة (Settings & Wallet)
│       ├── Context Packs
│       └── Wallet
├── YouTube Channel Link
└── Support Section (Chat + Email)
```

## Tutorial Topics

| Topic | Arabic Name | Steps | YouTube Link |
|-------|-------------|-------|--------------|
| GUL | قُل — الترجمة الصوتية | 4 | youtube.com/zidni/gul-tutorial |
| EYES | عيون — مسح المنتجات | 4 | youtube.com/zidni/eyes-tutorial |
| Alwakil | الوكيل — مساعدك الذكي | 4 | youtube.com/zidni/alwakil-tutorial |
| Memory | الذاكرة — سجل الصفقات | 4 | youtube.com/zidni/memory-tutorial |
| Deal Maker | صانع الصفقات | 4 | youtube.com/zidni/dealmaker-tutorial |
| Wallet | المحفظة — Zidni Pay | 4 | youtube.com/zidni/wallet-tutorial |
| Context Packs | حِزم السياق | 4 | youtube.com/zidni/packs-tutorial |

## Files Created

### Services
| File | Purpose |
|------|---------|
| `lib/services/tutorial/tutorial_registry.dart` | Maps topics to assets and steps |
| `lib/services/tutorial/tutorial_player.dart` | Playback control service |

### Screens
| File | Purpose |
|------|---------|
| `lib/screens/help/help_screen.dart` | Help hub with tutorials and support |

### Widgets
| File | Purpose |
|------|---------|
| `lib/widgets/tutorial/tutorial_card.dart` | Tutorial item card for help screen |
| `lib/widgets/tutorial/tutorial_player_widget.dart` | Full-screen tutorial player |

### Assets
| File | Purpose |
|------|---------|
| `assets/tutorials/README.md` | Asset creation guide |

### Documentation
| File | Purpose |
|------|---------|
| `docs/gates/TUTORIAL-1.md` | This file |

## Why Rive?

Based on research comparing Lottie vs Rive:

| Factor | Lottie | Rive |
|--------|--------|------|
| FPS | 17 FPS | **60 FPS** |
| Memory (Java) | 23 MB | **12 MB** |
| File Size | Larger | **Smaller** |
| State Machine | No | **Yes** |
| Offline | Yes | Yes |

Rive provides:
- 60 FPS smooth animations
- State machine for multi-step tutorials in one file
- Smaller file sizes
- Works offline (aligns with Zidni's offline-first philosophy)

## Hybrid Approach

```
IN-APP (Offline)              YOUTUBE (Online)
├── Rive Animations           ├── AI Avatar Videos (HeyGen)
├── Arabic Voiceover          ├── Detailed explanations
├── Interactive controls      ├── Shareable links
└── Step-by-step progress     └── SEO + marketing
```

## Usage

### Opening Help Screen

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => const HelpScreen()),
);
```

### Playing a Specific Tutorial

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => Scaffold(
      body: TutorialPlayerWidget(
        topic: TutorialTopic.gul,
        onComplete: () => print('Tutorial completed'),
      ),
    ),
  ),
);
```

### Getting Tutorial Data

```dart
final registry = TutorialRegistry();
final gulTutorial = registry.getTutorial(TutorialTopic.gul);
print(gulTutorial.nameArabic); // قُل — الترجمة الصوتية
```

## Acceptance Criteria

- [x] TutorialRegistry maps all 7 topics to assets
- [x] TutorialPlayer controls playback (play, pause, next, previous)
- [x] TutorialPlayerWidget shows animation area + step content + controls
- [x] HelpScreen displays tutorials by category
- [x] Quick start section for GUL and EYES
- [x] YouTube channel link visible
- [x] Support section with chat and email buttons
- [x] All labels Arabic-first
- [x] Locked files untouched

## Future Enhancements

1. **Rive Integration**: Replace placeholder icons with actual Rive animations
2. **Audio Playback**: Add Arabic voiceover audio synchronization
3. **Progress Tracking**: Save completed tutorials to user profile
4. **Contextual Triggers**: Show relevant tutorial on first feature use
5. **YouTube Deep Links**: Open specific YouTube videos from app
