# Gatekeeper Charter v2

> Every gate must deliver **Edge + Protection + Habit** or it does not ship.

## The Three Pillars

| Pillar | Question | Example |
|--------|----------|---------|
| **Edge** | Does the user gain a practical advantage? | Faster capture, smarter translation, one-tap actions |
| **Protection** | Does it reduce exploitation risk? | Agreement summaries, hidden fee alerts, proof copies |
| **Habit** | Will they use it weekly/daily? | Voice capture, conversation mode, quick save |

A gate can emphasize one pillar more than others, but must not actively harm any pillar.

## The 10 Gatekeeper Rules

### Scope Control

1. **One gate = one PR**. No bundling unrelated features.
2. **No new tabs** without explicit Gatekeeper approval.
3. **No scheduling/notifications**. These are scope creep magnets.
4. **No new Firestore collections** without data model review.

### Code Integrity

5. **Locked files are sacred**. Never modify:
   - `gul_control.dart`
   - `stt_engine.dart`
   - `stt_engine_speech_to_text.dart`

6. **flutter analyze must be clean**. Zero warnings, zero errors.

7. **No repo pollution**. No build artifacts, no IDE configs, no lock files in commits.

### UX Consistency

8. **Arabic-first UI**. RTL everywhere. Arabic labels primary.

9. **GUL is global**. The voice button works on every screen.

10. **Super-app shell is frozen**. AppBar + BottomNav + center GUL placement do not change.

## GO/NO-GO Criteria

### Automatic GO

- All 10 rules pass
- Edge/Protection/Habit justified in PR description
- Proofs provided (analyze output, locked file diffs)

### Automatic NO-GO

- Any locked file modified
- flutter analyze has errors
- New tab added without approval
- Missing Edge/Protection/Habit justification

### Conditional GO (requires discussion)

- flutter analyze has warnings (must explain why acceptable)
- New dependency added (must justify necessity)
- Large file changes (>500 lines in single file)

## Core vs Pack

### Core Features

Permanent parts of the app shell. Require full Gatekeeper review.

Examples:
- GUL voice capture
- Conversation mode
- Offline queue
- Deal folders

### Packs

Swappable content modules that don't change app behavior. Lighter review.

Examples:
- Country packs (Turkey, China, Spain)
- Role packs (taxi, supplier, customs)
- Template packs (follow-up messages)

Packs can be added/updated without full gate process if they:
- Don't modify core files
- Don't add new screens
- Only add data/templates

## Proof Checklist

Every PR must include:

```
## Proofs

### flutter analyze
[ ] No issues found

### Locked files (must be empty)
[ ] git diff origin/main...HEAD -- zidni_mobile/lib/widgets/gul_control.dart
[ ] git diff origin/main...HEAD -- zidni_mobile/lib/services/stt_engine.dart
[ ] git diff origin/main...HEAD -- zidni_mobile/lib/services/stt_engine_speech_to_text.dart

### Repo pollution
[ ] git status --porcelain (empty or only expected files)

### Edge/Protection/Habit
[ ] Edge: [describe advantage]
[ ] Protection: [describe safety benefit]
[ ] Habit: [describe daily/weekly use case]
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v2 | 2024-12-27 | Added Edge/Protection/Habit pillars, Core vs Pack concept |
| v1 | 2024-12-26 | Initial 10 rules |
