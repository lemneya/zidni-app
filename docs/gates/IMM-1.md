# IMM-1 — Immigration Mode for USA Arabs

## Gate ID
IMM-1

## Objective
Provide a comprehensive Immigration Mode for Arab immigrants in the USA, repurposing existing Zidni features (GUL, EYES, Wallet) for immigration-specific use cases.

## Branch + PR
- **Branch:** `feature/imm-1-immigration-mode`
- **PR Title:** Gate IMM-1: Immigration Mode for USA Arabs

## Features Implemented

### 1. Document Scanner (OCR Integration)
Scan and parse immigration documents:
- I-94 (Arrival/Departure Record)
- Visa stamps and pages
- Green Card (Permanent Resident Card)
- SSN card
- EAD (Employment Authorization Document)

### 2. Immigration Timeline
Auto-generate milestones from scanned documents:
- Visa expiration reminders
- I-94 admit until date
- Green card renewal eligibility (6 months before)
- Citizenship eligibility (5 years / 3 years for spouse)
- EAD expiration

### 3. Remittance UI Shell
Money transfer placeholder (Coming Soon):
- Send money home feature preview
- Low fees, fast transfers messaging
- MENA coverage (Egypt, Morocco, Algeria, etc.)

### 4. Legal Phrase Templates
Pre-built phrases for common scenarios:
- Immigration Officer (at airport/border)
- Immigration Lawyer
- DMV visits
- Social Security Administration
- USCIS appointments

### 5. USCIS Case Tracker
Track immigration applications:
- Add cases by receipt number
- View case status
- Status history tracking
- Service center detection

### 6. Immigration Alwakil
AI assistant for immigration questions:
- FAQ database
- Topic-based knowledge pack
- Arabic and English support
- Quick tips

## Files Created

### Models (3 files)
| File | Purpose |
|------|---------|
| `lib/models/immigration/immigration_document.dart` | Document types and parsed data |
| `lib/models/immigration/immigration_timeline.dart` | Timeline milestones |
| `lib/models/immigration/uscis_case.dart` | USCIS case tracking |

### Services (6 files)
| File | Purpose |
|------|---------|
| `lib/services/immigration/doc_scanner_service.dart` | OCR integration |
| `lib/services/immigration/doc_parsers.dart` | Document parsing logic |
| `lib/services/immigration/timeline_service.dart` | Timeline calculations |
| `lib/services/immigration/templates_service.dart` | Phrase templates |
| `lib/services/immigration/case_store.dart` | Case tracking storage |
| `lib/services/immigration/immigration_alwakil.dart` | AI assistant |

### Screens (7 files)
| File | Purpose |
|------|---------|
| `lib/screens/immigration/immigration_dashboard_screen.dart` | Main dashboard |
| `lib/screens/immigration/doc_scanner_screen.dart` | Document scanner |
| `lib/screens/immigration/timeline_screen.dart` | Timeline view |
| `lib/screens/immigration/case_tracker_screen.dart` | Case tracker |
| `lib/screens/immigration/templates_screen.dart` | Phrase templates |
| `lib/screens/immigration/alwakil_screen.dart` | AI assistant |
| `lib/screens/immigration/remittance_screen.dart` | Money transfer UI |

### Widgets (2 files)
| File | Purpose |
|------|---------|
| `lib/widgets/immigration/timeline_card.dart` | Timeline milestone card |
| `lib/widgets/immigration/quick_action_grid.dart` | Quick action grid |

## Acceptance Criteria

1. ✅ No locked files changed
2. ✅ Document scanner recognizes I-94, Visa, Green Card, SSN, EAD
3. ✅ Timeline auto-generates milestones from scanned documents
4. ✅ Case tracker validates receipt number format
5. ✅ Templates cover 5 categories with 15+ phrases
6. ✅ Alwakil responds to common immigration questions
7. ✅ Remittance shows "Coming Soon" UI
8. ✅ All screens are Arabic-first with English fallback
9. ✅ Dashboard provides quick access to all features

## Locked Files (MUST NOT CHANGE)
- `gul_control.dart`
- `stt_engine.dart`
- `stt_engine_speech_to_text.dart`

## Usage

### Access Immigration Mode
```dart
// From mode coordinator
if (ModeCoordinator.instance.currentMode == AppMode.immigration) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ImmigrationDashboardScreen()),
  );
}
```

### Scan a Document
```dart
final result = await DocScannerService.instance.scanDocument(
  imagePath: '/path/to/image.jpg',
  documentType: ImmigrationDocumentType.i94,
);

if (result.success) {
  final document = result.document!;
  // Use document data
}
```

### Track a Case
```dart
await CaseStore.instance.init();
await CaseStore.instance.addCase(
  receiptNumber: 'WAC2190012345',
  formType: USCISFormType.i485,
);
```

### Ask Alwakil
```dart
final response = await ImmigrationAlwakil.instance.askQuestion(
  'How long can I stay on a B1/B2 visa?',
);
print(response.getLocalizedAnswer('ar'));
```

## Integration with Existing Features

| Existing Feature | Immigration Mode Use |
|-----------------|---------------------|
| **GUL** | Speak with officers, lawyers, DMV |
| **EYES (OCR)** | Scan immigration documents |
| **Wallet** | Remittance (Coming Soon) |
| **Quick Phrases** | Immigration-specific templates |
| **Memory** | Document history, case tracking |
| **Alwakil** | Immigration AI assistant |
