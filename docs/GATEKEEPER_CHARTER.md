# Gatekeeper Charter (Blueprint v4)

This document defines the rules and criteria for approving or rejecting gates (features) in the Zidni project.

## Gatekeeper Question (Blueprint v4)

Does this gate deliver **Edge**, **Protection**, or **Savings/Business Ease** — **while staying ethically clean** — in under 10 seconds and supporting a daily/weekly habit?

## The Four Pillars

1. **Edge (Knowledge + Technology):** User gains practical advantage (faster, smarter action)
2. **Protection Layer:** Reduces exploitation risk (prices, contracts, hidden fees, scams)
3. **Savings + Business Ease:** Saves money, reduces friction, closes deals faster
4. **Ethical Integrity:** NO manipulation, lying, or stealing; promotes honest, fair dealings

## Ethical Integrity (Hard NO-GO)

Any gate is **NO-GO** if it enables or encourages:
- Deception, impersonation, or fraud (fake invoices/receipts/IDs, fabricated proof)
- Scams or exploitation (how to trick people, pressure tactics, hiding key terms)
- Stealth recording or unclear consent cues
- Instructions for stealing, hacking, bypassing systems, or illegal evasion

**Allowed:** fair negotiation, clarity prompts, documentation, verification, and safety-oriented protection.

**Principle:** Protection is allowed. Exploitation is not.

---

## Gatekeeper Rules

### Rule: Protection + Ethics are mandatory
Every new gate must:
- Reduce a real risk (misunderstanding, cheating, hidden fees, bad paperwork), AND
- Pass Ethical Integrity (no manipulation/lying/stealing).

### Rule: One gate = one PR
Each gate ships as a single pull request with:
- Clear scope (what's included)
- Clear out-of-scope (what's NOT included)
- Raw proofs (flutter analyze, locked files diff, screenshots/logs)

### Rule: Locked files are sacred
These files are NEVER modified:
- `lib/widgets/gul_control.dart`
- `lib/services/stt_engine.dart`
- `lib/services/stt_engine_speech_to_text.dart`

Any PR touching these files is automatic NO-GO.

### Rule: No new tabs/screens without approval
The super-app shell (5-tab layout) is fixed. New screens require explicit Gatekeeper approval.

### Rule: No scheduling/notifications without approval
Background processes and notifications require explicit Gatekeeper approval.

### Rule: Arabic-first UI
All user-facing text defaults to Arabic. RTL layout is mandatory.

### Rule: Visible consent for recording
Recording state must always be visible (red indicator). No stealth recording.

### Rule: 10-second value
User must get usable output in 1-2 taps, under 10 seconds.

### Rule: Habit fit
Feature must support a daily or weekly use scenario.

### Rule: flutter analyze clean
No issues allowed. Warnings must be resolved before merge.

---

## Pillars Checklist (must justify in every PR)

- [ ] Edge (knowledge/tech advantage)
- [ ] Protection (reduces exploitation risk)
- [ ] Savings + Business Ease (reduces friction/cost or increases close-rate)
- [ ] Ethical Integrity (no manipulation/lying/stealing; honest + fair)
- [ ] Habit fit (daily/weekly scenario)
- [ ] 10-second value (1–2 taps to usable output)

---

## GO / NO-GO Criteria

### GO if ALL pass:
1. At least 2 pillars checked (Edge, Protection, or Savings/Business Ease)
2. Ethical Integrity always checked
3. flutter analyze clean
4. Locked files unchanged
5. No new tabs/screens (unless approved)
6. No scheduling/notifications (unless approved)
7. Proofs provided (screenshots, logs, diffs)

### NO-GO if ANY fail:
- Ethical Integrity violation
- Locked files modified
- flutter analyze has issues
- Missing proofs
- Scope creep (features not in spec)

---

## Cost Discipline (Mandatory)

Zidni must remain high-value and affordable. Therefore:

1. **Zero-token baseline:** Every gate must ship with a **zero-token** path (on-device/templates/rules) unless explicitly approved otherwise.
2. **Tiered upgrades:** Token-based enhancements are allowed only as **opt-in upgrades** tied to subscription tiers.
3. **Hard budgets:** Each tier has a monthly token budget; if exceeded, features must **degrade gracefully**.
4. **Caching required:** Token outputs must be cacheable whenever possible.
5. **No "paywalling protection":** Core protection and dignity features are not restricted behind high tiers.

Gatekeeper must reject any gate that introduces uncontrolled token spend.

---

## Core vs Pack

**Core** = app behavior, screens, services (requires full gate process)
**Pack** = content updates (phrases, templates, translations) — lighter review, still needs proofs

---
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
| v4.1 | 2025-12-27 | Added Cost Discipline section, tiered subscription model |
| v4 | 2025-12-27 | Added Ethical Integrity pillar, Ethics NO-GO section |
| v3 | 2025-12-27 | Added Edge/Protection/Habit pillars |
| v2 | 2025-12-27 | Initial charter |
| v2 | 2024-12-27 | Added Edge/Protection/Habit pillars, Core vs Pack concept |
| v1 | 2024-12-26 | Initial 10 rules |
