
# Zidni Mobile App Blueprint

## 1. Purpose & Capabilities

Zidni is a mobile application designed to streamline the process of capturing and organizing information during trade shows and other events. It allows users to create "deal folders" for specific vendors or topics, and within each folder, capture audio snippets of conversations. These audio snippets are then transcribed into text and saved as "Gul captures."

The app is built with Flutter and leverages Firebase for backend services, including:

*   **Firestore:** To store deal folders and Gul captures.
*   **Firebase Authentication:** To authenticate users anonymously.

## 2. Style, Design & Features

### 2.1. Overall Design

The app will have a clean and modern design, with a focus on ease of use. The primary color scheme will be based on shades of blue, with clear and legible typography.

### 2.2. Screens

The app will have the following screens:

*   **Deal Folders Screen:** This screen will display a list of all the user's deal folders. Users will be able to create new folders from this screen.
*   **Deal Folder Detail Screen:** This screen will display the details of a specific deal folder, including a list of all the Gul captures within that folder.
*   **Capture Screen:** This screen will allow the user to record audio and have it transcribed into text.

### 2.3. Features

*   **Create Deal Folders:** Users can create new deal folders to organize their captures.
*   **Capture Audio:** Users can record audio snippets of conversations.
*   **Transcribe Audio:** The app will use a speech-to-text engine to transcribe the audio into text.
*   **Save Captures:** The transcribed text will be saved as a "Gul capture" within a deal folder.
*   **View Captures:** Users can view a list of all their captures within a deal folder.
*   **Offline Support:** The app will use Firestore's offline persistence to allow users to view and create data even when they are not connected to the internet.

## 3. Implementation Plan

The following steps will be taken to implement the Zidni mobile app:

1.  **Set up the project structure:** Create the necessary folders and files for the application.
2.  **Implement the UI:** Build the user interface for the different screens of the app.
3.  **Connect to Firebase:** Set up the Firebase connection and implement the necessary services.
4.  **Implement business logic:** Add the core functionalities of the app, such as creating, reading, and updating data.
5.  **Integrate speech-to-text:** Integrate a speech-to-text engine to transcribe audio.
6.  **Test the app:** Ensure that the app is working as expected.

This `blueprint.md` file will be updated as the project progresses to reflect the current state of the application.
