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

## GUL-first OS

Zidni is built on a **GUL-first (Voice-first) Operating System**. This means voice is the primary input, and all user interactions are routed through the GUL (Global Understanding Layer). The GUL is responsible for understanding user intent, translating speech, and orchestrating the various services within the app. This architecture ensures a seamless, hands-free experience for the user, which is critical in the fast-paced environment of the Canton Fair.

## Quick Start

To get started with Zidni, run the following commands:

```bash
# Run the app
flutter run

# Run tests
flutter test
```

## Repository Map

The repository is organized as follows:

- `docs/`
  - `ONBOARDING.md`: A guide for new developers to get started with the project.
  - `GATES.md`: Documents the gatekeeper protocol for feature development.
  - `OFFLINE_FIRST.md`: Defines the offline-first architecture and principles.
  - `ARCHITECTURE.md`: System overview and service boundaries.
- `lib/`
  - `core/`: Core components and services.
  - `models/`: Data models.
  - `services/`: Business logic and services.
  - `widgets/`: Reusable UI components.
- `test/`
  - `golden_baseline/`: Golden file tests for UI regression testing.
- `.github/`: GitHub-specific files, including workflows and PR templates.

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

## License

Proprietary. All rights reserved.
