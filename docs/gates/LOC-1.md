# LOC-1 — Location Detection + Mode Switching

## Gate ID
LOC-1

## Objective
Automatically detect the user's country (GPS-based when permitted) and suggest the best Zidni mode:
- China → Canton Fair Mode
- USA → Immigration Mode
- MENA → Home Mode
- All others → Travel Mode

Must be non-blocking, privacy-safe, and voice-first (simple confirm/deny).

## Branch + PR
- **Branch:** `feature/loc-1-location-mode-switching`
- **PR Title:** LOC-1: Location detection + mode suggestion + persistent override

## Scope (IN)

### 1. Permission + Privacy Flow
- Ask for location permission with a clear Arabic-first explanation
- If denied → no crash, no looping prompts; fall back gracefully

### 2. Country Detection
- Use last-known GPS when available (fast path)
- Refresh in background with low-power settings
- Derive countryCode (ISO-3166) and store lastCountryCode

### 3. Mode Inference Rules
| Country | Mode |
|---------|------|
| US | Immigration |
| CN | Canton Fair |
| MENA countries | Home |
| All others | Travel |

### 4. Mode Suggestion UI
- A small banner / bottom sheet (GUL-safe UI) that says:
  - "We detected you're in X. Switch to Y mode?"
  - Choices: Switch / Not now / Don't ask again
- Voice-friendly action labels

### 5. Manual Override (Persistent)
- A "Mode" selector screen in Settings
- Setting: autoModeEnabled on/off
- If user manually chooses a mode, don't auto-switch until country changes and autoModeEnabled=true

### 6. Telemetry (Local Logs Only)
- Log: permission status, detected country, suggested mode, user action
- No precise coordinates stored

## Out of Scope (OUT)
- City-level Canton Fair detection by venue radius
- Canton Fair schedule/date logic
- Any STT/TTS engine changes (locked)
- Server-side analytics

## Files Created

### Models
| File | Purpose |
|------|---------|
| `lib/models/app_mode.dart` | AppMode enum with 4 modes |
| `lib/models/location_context.dart` | Location context with country code |

### Services
| File | Purpose |
|------|---------|
| `lib/services/location/location_service.dart` | GPS permission and country detection |
| `lib/services/mode/mode_rules.dart` | Country → Mode mapping rules |
| `lib/services/mode/mode_state_store.dart` | Persistent mode settings |
| `lib/services/mode/mode_coordinator.dart` | Orchestrates mode suggestion flow |

### UI
| File | Purpose |
|------|---------|
| `lib/widgets/mode/mode_suggestion_banner.dart` | Suggestion banner widget |
| `lib/screens/settings/mode_settings_screen.dart` | Manual mode selection screen |

### Tests
| File | Purpose |
|------|---------|
| `test/mode/mode_rules_test.dart` | Rule mapping tests |
| `test/mode/mode_state_store_test.dart` | Persistence tests |
| `test/mode/mode_coordinator_test.dart` | Integration tests |

## Acceptance Criteria

1. ✅ No locked files changed (diff shows none)
2. ✅ First run: mode suggestion appears within 5 seconds if permission granted
3. ✅ If denied: no crashes, uses fallback rule (Travel), no repeated prompts
4. ✅ Country changes trigger new suggestion (respects cooldown)
5. ✅ Manual override persists across restarts
6. ✅ Tests cover: US, CN, 5+ MENA codes, non-MENA → Travel
7. ✅ All code is Arabic-first with English fallback

## Locked Files (MUST NOT CHANGE)
- `gul_control.dart`
- `stt_engine.dart`
- `stt_engine_speech_to_text.dart`

## Usage

### Initialize on App Startup
```dart
await ModeCoordinator.instance.init();
await ModeCoordinator.instance.maybeSuggestMode();
```

### Listen for Mode Changes
```dart
ModeCoordinator.instance.modeChangeStream.listen((mode) {
  // Update UI based on new mode
});
```

### Add Suggestion Banner to UI
```dart
ModeSuggestionBanner(
  onModeChanged: () {
    // Handle mode change
  },
)
```

### Navigate to Mode Settings
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ModeSettingsScreen()),
);
```
