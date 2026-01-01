# Zidni Service Definitions

**Version:** 1.0
**Last Updated:** 2026-01-01

This document provides a detailed breakdown of each service in the Zidni application, its purpose, API, dependencies, and test strategy. It serves as a contract for how services should be built and maintained.

---

## 1. Context Module (`lib/context`)

### `ContextService`

*   **Purpose:** Manages the user's active `ContextPack`, providing a context-aware experience.
*   **Public API:**
    *   `Future<ContextPack> getSelectedPack()`
    *   `Future<void> setSelectedPack(ContextPack pack)`
    *   `Future<bool> shouldShowSuggestion()`
    *   `Future<void> dismissSuggestion()`
*   **Inputs/Outputs:**
    *   Inputs: User selection from `ModePickerSheet`.
    *   Outputs: The currently active `ContextPack`.
*   **Persistence:** `SharedPreferences` (`context_selected_pack_id`, `context_suggestion_dismissed`).
*   **Dependencies:** None.
*   **Test Strategy:** Unit tests for selection persistence and suggestion logic.

---

## 2. Eyes Module (`lib/eyes`)

### `OcrService`

*   **Purpose:** Handles text recognition from camera images using Google ML Kit.
*   **Public API:**
    *   `Future<EyesScanResult> processImage(String imagePath)`
*   **Inputs/Outputs:**
    *   Inputs: Path to a camera image.
    *   Outputs: `EyesScanResult` with recognized text and detected language.
*   **Persistence:** None.
*   **Dependencies:** `google_mlkit_text_recognition`.
*   **Test Strategy:** Integration test with a sample image.

### `DealService`

*   **Purpose:** Creates and manages `DealRecord`s from the Eyes workflow.
*   **Public API:**
    *   `Future<DealRecord> createDeal(...)`
*   **Inputs/Outputs:**
    *   Inputs: `EyesScanResult`, `SearchQuery`.
    *   Outputs: A new `DealRecord`.
*   **Persistence:** `SharedPreferences` (via `HistoryService`).
*   **Dependencies:** `HistoryService`.
*   **Test Strategy:** Unit tests for deal creation logic.

---

## 3. Billing Module (`lib/billing`)

### `EntitlementService`

*   **Purpose:** Manages the user's current subscription tier.
*   **Public API:**
    *   `Future<Entitlement> getEntitlement()`
    *   `Future<void> setEntitlement(Entitlement entitlement)`
*   **Inputs/Outputs:**
    *   Inputs: New entitlement from a (future) purchase.
    *   Outputs: The current `Entitlement`.
*   **Persistence:** `SharedPreferences` (`billing_entitlement_tier`, `billing_expires_at`).
*   **Dependencies:** None.
*   **Test Strategy:** Unit tests for tier switching and persistence.

### `FeatureGate`

*   **Purpose:** Centralized logic for checking if a feature is enabled based on the user's entitlement and usage.
*   **Public API:**
    *   `Future<bool> isEnabled(Feature feature)`
*   **Inputs/Outputs:**
    *   Inputs: A `Feature` enum.
    *   Outputs: `true` if the feature is available, `false` otherwise.
*   **Persistence:** None.
*   **Dependencies:** `EntitlementService`, `UsageMeterService`.
*   **Test Strategy:** Unit tests for all gating logic (e.g., free can't export, business can).

---

## 4. Usage Module (`lib/usage`)

### `UsageMeterService`

*   **Purpose:** Tracks daily and monthly usage of key features.
*   **Public API:**
    *   `Future<void> increment(UsageType type)`
    *   `Future<int> getCount(UsageType type, {Period period = Period.daily})`
*   **Inputs/Outputs:**
    *   Inputs: A `UsageType` enum when a feature is used.
    *   Outputs: Usage counts for a given period.
*   **Persistence:** `SharedPreferences` (e.g., `usage_eyes_scans_daily_2026-01-01`).
*   **Dependencies:** None.
*   **Test Strategy:** Unit tests for incrementing and retrieving counts, including period rollovers.

---

## 5. Kits Module (`lib/kits`)

### `KitService`

*   **Purpose:** Manages the inventory of installed and active `OfflineKit`s.
*   **Public API:**
    *   `Future<List<OfflineKit>> getAllKits()`
    *   `Future<OfflineKit> getActiveKit()`
    *   `Future<void> activateKit(OfflineKit kit)`
*   **Inputs/Outputs:**
    *   Inputs: User selection from `KitsScreen`.
    *   Outputs: The currently active `OfflineKit`.
*   **Persistence:** `SharedPreferences` (`kits_active_kit_id`, `kits_installed_ids`).
*   **Dependencies:** `ContextService`.
*   **Test Strategy:** Unit tests for kit activation and persistence.

### `KitUpdateService`

*   **Purpose:** Safely checks for and downloads optional remote updates for kits.
*   **Public API:**
    *   `Future<UpdateResult> checkForUpdates()`
    *   `Future<bool> isUpdateAvailable()`
*   **Inputs/Outputs:**
    *   Inputs: A remote JSON file.
    *   Outputs: An `UpdateResult` indicating success or failure.
*   **Persistence:** `SharedPreferences` (`kits_update_last_checked`, `kits_update_available`).
*   **Dependencies:** `http`, `KitService`.
*   **Test Strategy:** Unit tests for JSON parsing, validation, and safe fallback on error.
