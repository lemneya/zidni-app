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
