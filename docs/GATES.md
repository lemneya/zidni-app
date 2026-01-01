_**This is an internal document and is subject to change.**_

# Gatekeeper Protocol

The Gatekeeper Protocol is a development methodology designed to ensure the quality, stability, and integrity of the Zidni codebase. It is a strict, PR-based workflow that requires visual proof for every feature and change. This protocol is essential for maintaining a high-quality, Arabic-first, offline-first super app.

## Core Principles

1.  **One Gate, One PR:** Each feature or significant change is a "gate." Each gate must be implemented in a separate branch and submitted as a single pull request (PR).
2.  **Visual Proof:** Every PR must include visual proof of the changes. This can be in the form of golden file tests, screenshots, or screen recordings.
3.  **Locked Files:** Core files are locked and cannot be modified without explicit approval. This is to protect the core architecture and prevent unintended side effects.
4.  **Clean Analysis:** The code must pass `flutter analyze` with no issues before a PR can be merged.
5.  **Sequential Merging:** PRs are merged in a specific order to ensure that dependencies are met and the main branch is always stable.

## Locked Files

The following files are locked and cannot be edited without a formal review and approval process:

| File | Rationale |
| :--- | :--- |
| `lib/widgets/gul_control.dart` | Core GUL voice control widget. Changes can impact the entire user experience. |
| `lib/services/stt_engine.dart` | Speech-to-text engine interface. Changes can break the voice input system. |
| `lib/services/stt_engine_speech_to_text.dart` | STT implementation. Changes can affect the accuracy and performance of speech recognition. |

## Proof Requirements

All PRs must include one or more of the following forms of visual proof:

-   **Golden File Tests:** For UI changes, golden file tests are mandatory. These tests capture a snapshot of the UI and compare it against a baseline image. Any visual changes will cause the test to fail, ensuring that UI regressions are caught early.
-   **Screenshots:** For changes that are difficult to test with golden files, such as animations or complex user interactions, screenshots are required. These should clearly demonstrate the before and after states of the UI.
-   **Screen Recordings:** For dynamic features or complex workflows, a short screen recording (GIF or MP4) is the best way to demonstrate the change. This is especially important for features that involve voice input or real-time updates.

## PR Template and Merge Order

All PRs must follow the standard PR template, which includes a title, a description of the changes, and a checklist of requirements. The PR title should follow the format `GATE <GATE_NAME>: <Description>`.

PRs are merged sequentially, following the order defined in the project plan. This ensures that dependencies are met and the main branch remains stable. Do not merge your own PRs; they will be reviewed and merged by the project lead.

## Examples from Completed Gates

-   **GATE QT2: Mic color preview:** This gate introduced a visual cue for the microphone state (Blue=me, Green=other). The PR included a golden file test to verify the color change.
-   **GATE EYES-1: OCR scan → Product card → Save:** This gate implemented the OCR scanning feature. The PR included a screen recording demonstrating the entire workflow, from scanning a product to saving it as a product card.
-   **GATE TEST-1: Golden baseline + OS smoke test:** This gate established the golden file testing infrastructure and created an end-to-end smoke test. The PR included the initial set of golden files and the test code.
