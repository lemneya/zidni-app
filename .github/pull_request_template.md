## Gate

- **Gate #:** 
- **Scope (what is included):**
- **Out of scope (what is NOT included):**

## Summary

<!-- Brief description of what this PR does -->

## Blueprint v4 Checklist (required)

**Pillars (must check at least 2 + Ethics always):**
- [ ] Edge (knowledge/tech advantage)
- [ ] Protection (reduces exploitation risk)
- [ ] Savings + Business Ease (reduces friction/cost or increases close-rate)
- [ ] Ethical Integrity (required): feature does NOT enable manipulation, lying, stealing, impersonation, fraud, or stealth recording

**Ethics Hard NO-GO (confirm all):**
- [ ] No deception/impersonation/fake proof
- [ ] No scam/exploitation guidance
- [ ] No stealth recording / unclear consent cues
- [ ] No illegal instructions or bypassing systems

## Tiered Subscription + Cost Checklist (required)

- [ ] This feature supports Zidni's **tiered subscription** model (not one-off pricing).
- [ ] **Zero-token fallback exists** (templates/rules/on-device) and is described below.
- [ ] If tokens are used:
  - [ ] Token use is **opt-in** (not automatic).
  - [ ] Feature is **budgeted by tier** (caps defined).
  - [ ] **Caching strategy** is described.
  - [ ] Graceful degradation when over budget/offline is implemented.
- [ ] Core protection/dignity is not paywalled.

### Zero-token fallback description
<!-- Explain the no-token behavior here -->

### Token path description (if any)
<!-- Model, approximate tokens, monthly caps per tier, caching plan -->

## Proof (required)

- [ ] `flutter analyze` clean (paste output)
- [ ] Locked files unchanged (paste `git diff` for: gul_control.dart, stt_engine.dart, stt_engine_speech_to_text.dart)
- [ ] Evidence: screenshots / short recording / logs proving behavior
- [ ] Offline/permission-denied behavior verified (if relevant)

## Files Changed

<!-- List new and modified files -->

## Testing Notes

<!-- How to test this feature -->
## Gate #[NUMBER]: [TITLE]

### Scope
<!-- One sentence describing what this gate adds -->


### Files Changed
<!-- List new and modified files -->
- **NEW**: 
- **MODIFIED**: 

---

## Edge / Protection / Habit

<!-- Check all that apply and explain -->

- [ ] **Edge**: User gains practical advantage
  <!-- How does this make the user faster/smarter? -->
  

- [ ] **Protection**: Reduces exploitation risk
  <!-- How does this protect from cheating/misunderstanding/hidden fees? -->
  

- [ ] **Habit**: Designed for daily/weekly use
  <!-- Why will users come back to this feature? -->
  

---

## Proofs

### flutter analyze
- [ ] No issues found

```
<!-- Paste output here -->
```

### Locked files (must be empty diffs)
- [ ] `gul_control.dart` unchanged
- [ ] `stt_engine.dart` unchanged
- [ ] `stt_engine_speech_to_text.dart` unchanged

```
<!-- Paste diff output here -->
```

### Repo pollution
- [ ] `git status --porcelain` clean

---

## Gatekeeper Rules Checklist

- [ ] One gate = one PR (no bundled features)
- [ ] No new tabs added
- [ ] No scheduling/notifications
- [ ] No new Firestore collections
- [ ] Arabic-first UI (RTL)
- [ ] GUL remains global
- [ ] Shell layout unchanged

---

## Testing Notes
<!-- How to test this gate -->


---

## Screenshots (if UI changes)
<!-- Add before/after screenshots -->

