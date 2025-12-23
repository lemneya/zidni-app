# Project ZIDNI: The "Context-First" Super App (Canton Fair MVP)

## 1. Overview & Core Philosophy

**Project Goal:** Build the "Operating System for the Arab Economy" with a voice-first, context-aware Super App.

*   **Target Market:** MENA Region (Middle East & North Africa)
*   **Core Philosophy:** "Zero UI" (Voice/Location First) + "Zero Commission" (SaaS Model)
*   **Language:** Arabic-first (RTL) is a non-negotiable.
*   **Voice Authority:** "GUL" is the single, authoritative voice module for the entire application.

### Non-Negotiables (Locked Architecture)
*   **Silence is a Feature:** The application will not have auto-speech, retries, apologies, or auto-prompts. User interaction is deliberate.
*   **STT Listen-Only:** The initial phase will have no Text-to-Speech (TTS). The speaking state is unreachable (feature-flagged OFF).
*   **Authoritative Input:** Pointer-based press/release is the definitive trigger for Speech-to-Text (STT).
*   **Terminal Errors:** If a required permission (like microphone) or a service (like STT) fails, the UI will enter a "blocked" state for that interaction. It will only recover upon pointer release. No retries or error dialogs.

## 2. UI Shell (Locked)

The application's UI shell is fixed and will be implemented with a Right-to-Left (RTL) layout.

*   **Bottom Navigation:**
    *   Home
    *   Alwakeel
    *   **GUL (Center FAB - Floating Action Button)**
    *   Pay (Placeholder)
    *   Me
*   **Top Header (RTL):**
    *   Search, Map (Icons)
    *   Eyes OCR (Icon)
    *   Ravigh, Apps (Icons)
*   **Omnipresence:** The GUL FAB is omnipresent and center-docked. There is no dedicated "GUL screen."

## 3. Build Plan: Phased Gates (Canton Fair MVP)

Development will follow a strict, phased approach. Each gate's deliverables and acceptance criteria must be met before proceeding to the next.

---

### **Gate #1: GUL STT Listen-Only (No Firebase Dependency)**
*   **Priority:** HIGHEST. Do not start Firebase work until this is implemented and passes all acceptance tests.
*   **Goal:** Implement a functional, offline-first GUL STT control based on press/release actions.
*   **Deliverables:**
    *   `lib/widgets/gul_control.dart`
    *   `lib/services/stt_engine.dart`
    *   `lib/services/stt_engine_speech_to_text.dart`
*   **Acceptance Tests:**
    *   ✅ Pointer down → `listening` state.
    *   ✅ Pointer up → `processing` state → `idle` state.
    *   ✅ Speaking state is unreachable (TTS feature flag OFF).
    *   ✅ Permission/STT unavailable → `blocked` state (terminal per interaction) → resets only on release/cancel.
    *   ✅ No retries, no snackbars, no apologies, no auto-actions.
    *   ✅ No other module can access the microphone or speech services.

---

### **Gate #2: Firebase Project Setup**
*   **Pre-requisite:** Gate #1 approved.
*   **Goal:** Enable user identity and prepare for data storage without altering existing app behavior.
*   **Packages to Add:**
    *   `firebase_core`
    *   `firebase_auth`
    *   `cloud_firestore`
*   **Checklist:**
    *   ✅ Initialize Firebase in `main.dart`.
    *   ✅ Use Firebase Emulator Suite for local development.

---

### **Gate #3: Firestore Schema & Security Rules**
*   **Goal:** Implement the minimal Firestore schema for user profiles with owner-only security.
*   **Firestore Schema:**
    *   **users/{uid}**
        *   `createdAt`: Server Timestamp
        *   `activeProfileId`: String
        *   `discoveryEnabled`: Boolean (default: `false`)
        *   `appRole`: String (optional, e.g., "trader")
    *   **users/{uid}/profiles/{profileId}**
        *   `type`: "personal" | "business"
        *   `displayName`: String
        *   `createdAt`: Server Timestamp
        *   `visibility`: "private" | "public" (default: `private`)
        *   *Future-ready optional fields (UI OFF for MVP):* `jobTitle`, `serviceCategories`, `city`, `country`, `languages`.
*   **Security Rules (Baseline):**
    ```
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId}/{document=**} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    ```
*   **Key Constraint:** Keep UI friction near zero. Do not prompt for optional profile fields during signup in the MVP.

---

### **Phase 2 (Post-MVP)**

*   **Matchmaking/Directory Feature:** This will be implemented only after the MVP is complete. It will require explicit user opt-in (`discoveryEnabled`, `visibility`) and verification for sensitive roles.

## 4. Build Discipline (No-Loss)

*   **System of Record:** The Git repo is the single source of truth.
*   **Commits & Tags:** Each completed Gate will be a dedicated commit with a corresponding tag (e.g., `v0.1-gate1-gul-stt`).
*   **Code Delivery:** All code changes will be provided as full, exact file contents and paths, or as patches/diffs.
*   **No Architectural Changes:** I will not make architectural decisions and will adhere strictly to this blueprint.
