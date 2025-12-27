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

## Core vs Pack

**Core** = app behavior, screens, services (requires full gate process)
**Pack** = content updates (phrases, templates, translations) — lighter review, still needs proofs

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v4 | 2025-12-27 | Added Ethical Integrity pillar, Ethics NO-GO section |
| v3 | 2025-12-27 | Added Edge/Protection/Habit pillars |
| v2 | 2025-12-27 | Initial charter |
