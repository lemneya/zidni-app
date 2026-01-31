# ARCH-0: One Brain, Two Faces

> **Single Source of Truth (SSOT)** for the Zidni architecture boundary model.

## Overview

Zidni operates as **"One Brain, Two Faces"** — a unified intelligence layer serving two distinct surface experiences:

```
┌─────────────────────────────────────────────────────────────────┐
│                         SHARED BRAIN                            │
│  ┌─────────────────┐    ┌─────────────────────────────────────┐ │
│  │ Orchestrator API │◄──►│          Global Vault              │ │
│  │  (tool routing)  │    │  (single datastore for all modes)  │ │
│  └────────┬─────────┘    └─────────────────────────────────────┘ │
│           │                                                      │
│     ┌─────┴─────┐                                               │
│     ▼           ▼                                               │
│ ┌───────┐   ┌───────┐                                          │
│ │ Face 1│   │ Face 2│                                          │
│ └───────┘   └───────┘                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Two Faces

### Face 1: Zidni Home (Consumer)

- **Platform:** Flutter mobile app (`zidni_mobile/`)
- **Audience:** End users (consumers, travelers, traders)
- **Channels:** Mobile app, WhatsApp integration
- **Capabilities:**
  - Offline-first operation
  - Voice interaction (STT/TTS)
  - Camera capture (OCR, product scanning)
  - Mode-aware assistance
- **Tool Access:** SAFE tools only (see Orchestrator API)

### Face 2: Zidni Studio (Operator Console)

- **Platform:** Web application (`zidni_web/`)
- **Audience:** Operators, power users, administrators
- **Channels:** Web browser only (authenticated)
- **Capabilities:**
  - Full tool administration
  - Batch operations
  - Analytics and monitoring
  - Prompt/workflow editing
- **Tool Access:** Full operator-level tools

---

## Modes (Views, Not Apps)

Modes are **user context switches**, not separate applications. All modes share the same brain and vault.

| Mode         | Description                          | Primary Use Case              |
|--------------|--------------------------------------|-------------------------------|
| REGULAR      | General assistance                   | Default conversational mode   |
| TRADER       | China trade workflow                 | Supplier research, PO drafts  |
| TRAVELER     | Travel assistance                    | Translation, navigation       |
| IMMIGRATION  | Document/visa assistance             | Form help, requirement lookup |

**Key principle:** Mode determines which prompts and UI affordances are shown, but the underlying tool set remains unified through the Orchestrator API.

---

## Shared Brain Components

### 1. Orchestrator API

The central coordination layer that:
- Routes tool invocations from any client
- Enforces permission boundaries per client role
- Maintains mode state
- Provides unified vault access

**Contract location:** `orchestrator_api/ORCHESTRATOR_API.md`

### 2. Global Vault

Single datastore for all user data across modes:
- Saved products (China list)
- Evidence/receipts
- Travel documents
- Conversation history
- User preferences

**Principle:** One user = one vault, regardless of mode or face.

---

## Safety Boundary

### Critical Rule

> **Studio tools are NEVER exposed to consumer channels.**

This means:
- WhatsApp users cannot access operator-level tools
- Mobile app cannot invoke batch/admin operations
- Only authenticated Studio sessions get full tool access

### Enforcement

1. **Permission Matrix:** `orchestrator_api/policy/permissions.json` defines allowed tools per client role
2. **API Validation:** Orchestrator rejects unauthorized tool calls at the API boundary
3. **No Client-Side Trust:** Tool allowlists are enforced server-side only

---

## Client Roles

| Role               | Face    | Tool Access Level |
|--------------------|---------|-------------------|
| `consumer_app`     | Home    | SAFE tools only   |
| `consumer_whatsapp`| Home    | SAFE tools only   |
| `studio_operator`  | Studio  | Full tools        |

---

## Architecture Invariants

1. **Single Brain:** All intelligence flows through Orchestrator API
2. **Single Vault:** No mode-specific data silos
3. **Role-Based Access:** Tools gated by client role, not user intent
4. **Offline-First Home:** Mobile app must function without network
5. **Studio = Web Only:** No operator tools in mobile/WhatsApp

---

## Related Documents

- `orchestrator_api/ORCHESTRATOR_API.md` — API contract
- `orchestrator_api/policy/permissions.json` — Permission matrix
- `THIRD_PARTY_NOTICES.md` — License compliance for zidni_web import

---

*ARCH-0 Gate | Created 2026-01-31*
