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
| v0.16 | Gate #16 | Quick Phrases Packs |
# Zidni زِدني

> **North Star**: Zidni is the daily Arabic-first habit tool that gives Arabs an edge of knowledge + technology anywhere they are AND protects them from exploitation.

## Vision

Zidni empowers Arabic speakers with practical tools for real-world situations—trade fairs, negotiations, travel, and daily transactions. Every feature must deliver:

| Pillar | Description |
|--------|-------------|
| **Edge** | User gains practical advantage (faster, smarter action) |
| **Protection** | Reduces cheating, misunderstanding, hidden fees, bad paperwork |
| **Habit** | Designed for weekly/daily use |

## Canton Fair Milestone (v0.15)

Zidni is battle-tested for the Canton Fair—the world's largest trade show. Current capabilities:

- **GUL Voice Capture**: Press-hold-release voice notes in Arabic
- **Conversation Mode**: AR ⇄ ZH/EN/TR/ES turn-taking with TTS
- **Hand-the-phone Mode**: Clean UI for the other party to speak
- **Offline Queue**: Captures saved locally when network fails
- **Quick Save**: One-tap save to last-used folder
- **Post-capture Actions**: Copy proof blocks and follow-up templates
- **Location-aware**: Auto-selects target language based on country

## Protection Layer

Future gates will emphasize **Protection Outputs**:

- Copy packs (proof of conversation, agreement summaries)
- Risk prompts (hidden fees, unusual terms)
- Country/role packs (taxi, supplier, customs)
- Agreement summaries with red flags

## Gate Discipline

Development follows strict gate discipline:

1. **One gate = one PR** with clear scope
2. **Arabic-first UI** (RTL everywhere)
3. **No new tabs** without explicit approval
4. **No scheduling/notifications** (scope creep)
5. **Locked files untouched** (gul_control, stt_engine, stt_engine_speech_to_text)
6. **Proofs required**: flutter analyze clean + locked files empty diff

See [GATEKEEPER_CHARTER.md](docs/GATEKEEPER_CHARTER.md) for full rules.

## Project Structure

```
zidni-app/
├── zidni_mobile/          # Flutter mobile app
│   ├── lib/
│   │   ├── screens/       # App screens
│   │   ├── widgets/       # Reusable widgets
│   │   ├── services/      # Business logic
│   │   └── models/        # Data models
│   └── pubspec.yaml
├── local_companion/       # Offline STT/LLM server
└── docs/                  # Documentation
```

## Tags

| Tag | Gate | Description |
|-----|------|-------------|
| v0.15 | #15 | Location default + handoff mode + loud mode |
| v0.14 | #14 | Intro message (TTS) + copy intro |
| v0.13 | #13 | Multi-target conversation (ZH+EN+TR+ES) |
| v0.12 | #12 | Conversation mode turn-taking |
| v0.11 | #11 | Offline queue hardening |
| v0.10 | #10 | Offline-safe capture queue |
| v0.9 | #9 | Pinned folder quick save |
| v0.8 | #8 | Post-capture actions |

## License

Proprietary. All rights reserved.
