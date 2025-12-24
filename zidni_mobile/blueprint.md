# Zidni Mobile App Blueprint

## Overview

Zidni is a mobile application designed to act as a personal assistant. This blueprint outlines the application's features, design, and implementation details.

## Gate #5: Deal Folder and Gul Capture

### Features

- **Deal Folders:** Users can create, view, and manage deal folders. Each folder has a title, booth/hall, category, and priority.
- **Gul Capture:** Users can capture and save transcripts to a deal folder.
- **Quick-create folders:** Quickly create folders for common scenarios like "Taxi / Driver" or "Market / Shopping".
- **Copy Proof:** Copy a formatted block of text containing capture details to the clipboard.

### Design

- **Deal Folders Screen:** A list of deal folders is displayed. Users can tap on a folder to view its details or tap the "+" button to create a new folder.
- **Deal Folder Detail Screen:** A list of captures within a deal folder is displayed.
- **Gul Capture Sheet:** A bottom sheet allows users to enter a transcript and save it to a deal folder.
- **Folder Chooser Modal:** When saving a capture, a modal appears allowing the user to select an existing folder or create a new one using quick-create tiles.
- **Category Defaults:** The category list for creating folders manually is updated to: "Taxi / Driver", "Market / Shopping", "Supplier Meeting", "Shipping / Warehouse", "Hotel / Address", "Problem / Dispute".

### Implementation

- **Models:**
    - `deal_folder.dart`: Represents a deal folder.
    - `gul_capture.dart`: Represents a captured transcript.
- **Services:**
    - `firestore_service.dart`: Handles all interactions with the Firestore database.
- **Screens:**
    - `deal_folders_screen.dart`: Displays a list of deal folders.
    - `deal_folder_detail.dart`: Displays the captures within a deal folder.
- **Widgets:**
    - `zidni_app_bar.dart`: The main app bar with an "Apps" button.
    - `gul_capture_sheet.dart`: The bottom sheet for capturing transcripts.
- **Dependencies:**
    - `cloud_firestore`: For interacting with the Firestore database.
    - `firebase_auth`: For anonymous user authentication.
    - `firebase_core`: For initializing the Firebase app.
    - `provider`: For state management.
