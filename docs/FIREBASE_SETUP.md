# Firebase Setup Guide for Zidni Admin Dashboard

## Overview
This guide walks you through configuring Firebase for your Zidni admin dashboard, including Firestore database, authentication, and Cloud Functions.

## Prerequisites
- Google account with Firebase project created
- - Flutter CLI installed locally
  - - Git installed
    - - Access to your Firebase project console
     
      - ## Step 1: Create Firebase Project
     
      - 1. Go to [Firebase Console](https://console.firebase.google.com/)
        2. 2. Click "Add project" or select your Zidni project
           3. 3. Follow the setup wizard:
              4.    - Enable Google Analytics (recommended)
                    -    - Select your region
                         -    - Create the project
                          
                              - ## Step 2: Set Up Firestore Database
                          
                              - ### Create Firestore Instance
                              - 1. In Firebase Console, go to **Firestore Database**
                                2. 2. Click **Create database**
                                   3. 3. Choose production mode (you'll set security rules next)
                                      4. 4. Select your preferred region
                                         5. 5. Click **Create**
                                           
                                            6. ### Create Collections
                                           
                                            7. Create the following collections in Firestore:
                                           
                                            8. ```
                                               users/
                                                 - uid (document)
                                                   - email
                                                   - name
                                                   - subscription_status
                                                   - created_at

                                               deals/
                                                 - deal_id (document)
                                                   - title
                                                   - description
                                                   - status
                                                   - seller_uid
                                                   - created_at

                                               campaigns/
                                                 - campaign_id (document)
                                                   - name
                                                   - status
                                                   - segment_id
                                                   - sent_at

                                               analytics/
                                                 - daily_stats (document)
                                                   - date
                                                   - active_users
                                                   - deals_created
                                               ```

                                               ## Step 3: Configure Firebase Authentication

                                               1. Go to **Authentication** in Firebase Console
                                               2. 2. Click **Get Started**
                                                  3. 3. Enable these providers:
                                                     4.    - Email/Password
                                                           -    - Google Sign-In (optional but recommended)
                                                                - 4. Configure Sign-in method settings as needed
                                                                 
                                                                  5. ## Step 4: Generate Firebase Configuration
                                                                 
                                                                  6. ### For Admin Dashboard (Flutter Web)
                                                                 
                                                                  7. 1. Open terminal in admin directory:
                                                                  ```bash
                                                                  cd admin
                                                                  ```

                                                                  2. Run flutterfire configure:
                                                                  3. ```bash
                                                                     flutterfire configure
                                                                     ```

                                                                     3. When prompted:
                                                                     4.    - Select your Firebase project
                                                                           -    - Keep default settings for iOS/Android (can skip)
                                                                                -    - Select **web** platform when asked
                                                                                     -    - Choose default settings for Firestore
                                                                                      
                                                                                          - 4. This generates `lib/firebase_options.dart` file automatically
                                                                                           
                                                                                            5. ### Verify Generated File
                                                                                           
                                                                                            6. Check that the file was created:
                                                                                            7. ```bash
                                                                                               ls -la lib/firebase_options.dart
                                                                                               ```

                                                                                               The file should contain:
                                                                                               ```dart
                                                                                               class DefaultFirebaseOptions {
                                                                                                 static FirebaseOptions get currentPlatform {
                                                                                                   // Platform specific options here
                                                                                                 }
                                                                                               }
                                                                                               ```

                                                                                               ## Step 5: Set Firebase Security Rules

                                                                                               1. Go to **Firestore Database** → **Rules**
                                                                                               2. 2. Replace with these security rules:
                                                                                                 
                                                                                                  3. ```rules
                                                                                                     rules_version = '2';
                                                                                                     service cloud.firestore {
                                                                                                       match /databases/{database}/documents {
                                                                                                         // Allow authenticated users to read/write their own user data
                                                                                                         match /users/{uid} {
                                                                                                           allow read, write: if request.auth.uid == uid;
                                                                                                         }

                                                                                                         // Allow authenticated admin to read deals
                                                                                                         match /deals/{deal} {
                                                                                                           allow read: if request.auth != null;
                                                                                                           allow write: if request.auth.uid == resource.data.seller_uid;
                                                                                                           allow create: if request.auth != null;
                                                                                                         }

                                                                                                         // Allow authenticated users to read analytics
                                                                                                         match /analytics/{document=**} {
                                                                                                           allow read: if request.auth != null;
                                                                                                           allow write: if false; // Only Cloud Functions can write
                                                                                                         }

                                                                                                         // Allow admin to manage campaigns
                                                                                                         match /campaigns/{campaign} {
                                                                                                           allow read, write: if request.auth != null;
                                                                                                         }

                                                                                                         // Deny everything else
                                                                                                         match /{document=**} {
                                                                                                           allow read, write: if false;
                                                                                                         }
                                                                                                       }
                                                                                                     }
                                                                                                     ```
                                                                                                     
                                                                                                     3. Click **Publish**
                                                                                                    
                                                                                                     4. ## Step 6: Create Firestore Indexes (if needed)
                                                                                                    
                                                                                                     5. If you get index creation errors when querying, go to **Firestore Database** → **Indexes** and create composite indexes as suggested by the error messages.
                                                                                                    
                                                                                                     6. Common indexes you might need:
                                                                                                     7. - `users` collection: sorted by `created_at` descending
                                                                                                        - - `deals` collection: filtered by `status`, sorted by `created_at` descending
                                                                                                          - - `campaigns` collection: filtered by `segment_id`
                                                                                                           
                                                                                                            - ## Step 7: Set Environment Variables
                                                                                                           
                                                                                                            - Create `.env` file in admin directory:
                                                                                                            - ```
                                                                                                            FIREBASE_PROJECT_ID=your_project_id
                                                                                                            FIREBASE_API_KEY=your_api_key
                                                                                                            FIREBASE_APP_ID=your_app_id
                                                                                                            FIREBASE_MESSAGING_SENDER_ID=your_sender_id
                                                                                                            FIREBASE_DATABASE_URL=your_database_url
                                                                                                            ```

                                                                                                            Get these values from Firebase Console:
                                                                                                            1. Go to **Project Settings** (gear icon)
                                                                                                            2. Click **Service Accounts**
                                                                                                            3. Copy configuration details

                                                                                                            ## Step 8: Initialize Firebase in Admin Dashboard

                                                                                                            Update `lib/main.dart`:

                                                                                                            ```dart
                                                                                                            import 'firebase_options.dart';

                                                                                                            void main() async {
                                                                                                              WidgetsFlutterBinding.ensureInitialized();

                                                                                                              await Firebase.initializeApp(
                                                                                                                options: DefaultFirebaseOptions.currentPlatform,
                                                                                                              );

                                                                                                              runApp(const MyApp());
                                                                                                            }
                                                                                                            ```
                                                                                                            
                                                                                                            ## Step 9: Test Firebase Connection
                                                                                                            
                                                                                                            1. Run the admin dashboard:
                                                                                                            2. ```bash
                                                                                                               cd admin
                                                                                                               flutter pub get
                                                                                                               flutter run -d chrome
                                                                                                               ```
                                                                                                               
                                                                                                               2. Go to Firestore Console
                                                                                                               3. 3. Try logging in - check Console for new user document
                                                                                                                 
                                                                                                                  4. 4. Verify in Firestore:
                                                                                                                     5. ```
                                                                                                                        users/ → [user_uid] → should show email, name, etc.
                                                                                                                        ```
                                                                                                                        
                                                                                                                        ## Step 10: Enable Cloud Functions (for next phase)
                                                                                                                        
                                                                                                                        1. Go to **Cloud Functions**
                                                                                                                        2. 2. Click **Get Started** if not already enabled
                                                                                                                           3. 3. Select same region as Firestore
                                                                                                                              4. 4. Click **Create Function** (we'll deploy functions later)
                                                                                                                                
                                                                                                                                 5. ## Troubleshooting
                                                                                                                                
                                                                                                                                 6. ### Issue: `firebase_core` not initialized
                                                                                                                                 7. **Solution:** Make sure Firebase.initializeApp() is called before any Firebase operations
                                                                                                                                
                                                                                                                                 8. ### Issue: Authentication fails
                                                                                                                                 9. **Solution:** Check that Email/Password auth is enabled in Firebase Console
                                                                                                                                
                                                                                                                                 10. ### Issue: Firestore queries return empty
                                                                                                                                 11. **Solution:** Check security rules - they might be too restrictive
                                                                                                                                
                                                                                                                                 12. ### Issue: Web app not recognized
                                                                                                                                 13. **Solution:** Register web app in Firebase Console under Project Settings → Apps
                                                                                                                                
                                                                                                                                 14. ## Next Steps
                                                                                                                                 15. 1. ✅ Firebase configured
                                                                                                                                     2. 2. 📍 Mautic deployment (see MAUTIC_DEPLOYMENT.md)
                                                                                                                                        3. 3. 📍 Cloud Functions setup (see CLOUD_FUNCTIONS.md)
                                                                                                                                           4. 4. 📍 RevenueCat integration (see REVENUCAT_SETUP.md)
                                                                                                                                              5. 5. 📍 Local testing (see LOCAL_TESTING_GUIDE.md)
                                                                                                                                                
                                                                                                                                                 6. ## Useful Links
                                                                                                                                                 7. - [Firebase Console](https://console.firebase.google.com/)
                                                                                                                                                    - - [FlutterFire Documentation](https://firebase.flutter.dev/)
                                                                                                                                                      - - [Firestore Documentation](https://firebase.google.com/docs/firestore)
                                                                                                                                                        - - [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
                                                                                                                                                          - 
