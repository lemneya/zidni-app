_**This is an internal document and is subject to change.**_

# Offline-First Contract

Zidni is designed to be an **offline-first** application. This means that all core features must be fully functional without an internet connection. This is a critical requirement for our users, who often find themselves in environments with unreliable or non-existent Wi-Fi, such as the Canton Fair. This document outlines the principles, patterns, and rules that govern our offline-first architecture.

## Core Principles

1.  **Local-First Data:** All data is stored locally on the device. The app should never assume that a network connection is available to fetch data.
2.  **Seamless Offline Experience:** The user should not be able to tell the difference between being online and offline. The app should be just as responsive and functional in both states.
3.  **Data Synchronization:** When a network connection becomes available, the app should automatically synchronize local data with the remote server. This should happen in the background without interrupting the user.
4.  **Conflict Resolution:** The app must have a robust conflict resolution strategy to handle cases where data is modified on multiple devices while offline.

## Safe Remote Update Patterns

To ensure that the app can be updated safely without breaking the offline-first guarantee, we follow these patterns:

-   **Bundled Resources:** All essential resources, such as context packs and UI assets, are bundled with the app. This ensures that the app is fully functional even on first launch without a network connection.
-   **Atomic Updates:** Remote updates are downloaded and applied atomically. If an update fails for any reason, the app will roll back to the previous version.
-   **Background Updates:** Updates are downloaded in the background and applied on the next app launch. This ensures that the user is not interrupted while using the app.

## Fail-Safe Rules for Network Operations

All network operations must be designed with failure in mind. The following rules apply to all network requests:

-   **Timeouts:** All network requests must have a short timeout (e.g., 5 seconds). If a request times out, it should be considered a failure.
-   **Retries:** Failed requests should be retried with an exponential backoff strategy. The app should not make more than a few retry attempts before giving up.
-   **Queuing:** If a network request fails, it should be added to a queue and retried later when a network connection becomes available.

## Testing Offline Scenarios

To ensure that the offline-first guarantee is met, we must test all features in an offline environment. This includes:

-   **Disabling Network:** All tests should be run with the network disabled to simulate an offline environment.
-   **Simulating Slow Networks:** We should also test the app on slow and unreliable networks to ensure that it remains responsive.
-   **Testing Data Synchronization:** We need to test the data synchronization process to ensure that it is working correctly and that conflicts are resolved as expected.
