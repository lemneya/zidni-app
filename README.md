# Zidni

**The daily Arabic-first habit tool that empowers Arabs anywhere.**

## North Star

Zidni gives Arabs an edge of knowledge + technology anywhere they are AND protects them from exploitation.

## Zidni Blueprint (v4)

Zidni is the daily Arabic-first habit tool that empowers Arabs anywhere with:

1. **Edge (Knowledge + Technology):** act faster/smarter anywhere.
2. **Protection Layer:** reduce exploitation (prices, contracts, hidden fees, scams).
3. **Savings + Business Ease:** save money, reduce friction, close deals faster.
4. **Ethical Integrity:** Zidni will **not** participate in manipulation, lying, or stealing. Zidni promotes honest, fair dealings.

**Non-negotiables:** Arabic-first UI, visible consent for recording, no stealth behavior, one gate per PR with raw proof, locked files untouched.

## Subscription Model (Tiered)

Zidni is a **tiered subscription** product.

**Value-first rule:** Every user gets the **core daily habit + protection layer**.
Paid tiers unlock **more automation and higher certainty** (e.g., advanced summaries, deep checks), while respecting strict cost controls.

## Cost Discipline (Tokens + Infra)

- **Zero-token first:** Prefer on-device, templates, and rule-based logic.
- **Tier budgets:** Token-based features have hard monthly caps per tier.
- **Graceful fallback:** If budget is exceeded (or offline), Zidni must still produce a usable output using local logic.
- **Caching:** Reuse results to reduce cost and improve speed.

## Canton Fair Milestone

Zidni's first real-world test: Canton Fair 2025. Features are designed for:
- Voice capture in noisy booth environments
- Offline reliability when Wi-Fi fails
- Quick follow-up templates for WhatsApp/WeChat
- Bilingual conversation mode (AR ⇄ ZH/EN/TR/ES)

## Gate Discipline

- **One gate = one PR** with hard proofs
- **Locked files** never touched: `gul_control.dart`, `stt_engine.dart`, `stt_engine_speech_to_text.dart`
- **No new tabs/screens** without explicit approval
- **No scheduling/notifications** without explicit approval
- **flutter analyze** must pass with no issues

## Project Structure

```
zidni-app/
├── zidni_mobile/          # Flutter mobile app
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── screens/       # App screens
│   │   ├── services/      # Business logic
│   │   ├── widgets/       # Reusable widgets
│   │   └── packs/         # Context packs (phrases, templates)
│   └── pubspec.yaml
├── local_companion/       # Python server for offline STT/LLM
├── docs/                  # Documentation
│   └── GATEKEEPER_CHARTER.md
└── .github/
    └── pull_request_template.md
```

## Tags (Release History)

| Tag | Gate | Description |
|-----|------|-------------|
| v0.8 | Gate #8 | Post-capture Actions |
| v0.9 | Gate #9 | Pinned Folder Quick Save |
| v0.10 | Gate #10 | Offline Capture Queue |
| v0.11 | Gate #11 | Offline Queue Hardening |
| v0.12 | Gate #12 | Turn-taking Conversation Mode |
| v0.13 | Gate #13 | Multi-target Conversation (ZH+EN+TR+ES) |
| v0.14 | Gate #14 | Intro Message (TTS) |
| v0.15 | Gate #15 | Location Default + Handoff + Loud Mode |
| v0.16 | Gate #16 | Quick Phrases Packs |

## License

Proprietary. All rights reserved.
