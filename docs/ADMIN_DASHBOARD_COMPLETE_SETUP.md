# Zidni Admin Dashboard - Complete Setup Guide (Mautic + Cloud Functions + RevenueCat)

**Status:** All 5 setup guides complete  
**Last Updated:** January 2, 2026

## Quick Navigation

1. ✅ [Firebase Setup](./FIREBASE_SETUP.md) - Already completed
2. 2. 📍 **This Document** - Mautic, Cloud Functions, RevenueCat, and Local Testing
  
   3. ## PART 2: Mautic Marketing Automation Server
  
   4. ### 2.1 Deploy Mautic on Railway.app (Recommended - $12-24/month)
  
   5. Railway is the easiest path: no Docker knowledge needed, auto-scaling, free SSL.
  
   6. #### Step 1: Create Railway Account
   7. 1. Go to [Railway.app](https://railway.app)
      2. 2. Sign up with GitHub account
         3. 3. Create new project
           
            4. #### Step 2: Deploy Mautic Template
            5. 1. In Railway, click "Deploy from template"
               2. 2. Search for "Mautic"
                  3. 3. Click deploy
                     4. 4. Railway automatically sets up:
                        5.    - Mautic application
                              -    - PostgreSQL database
                                   -    - Domain (e.g., mautic-abc123.railway.app)
                                    
                                        - #### Step 3: Complete Mautic Setup
                                        - 1. Open your Mautic domain (Railway provides URL)
                                          2. 2. Follow Mautic installation wizard:
                                             3.    - Create admin account
                                                   -    - Configure database (auto-filled)
                                                        -    - Set timezone to UTC
                                                             -    - Enable SMTP if you have an email service
                                                              
                                                                  - #### Step 4: Get API Credentials
                                                                  - 1. In Mautic admin, go to **Settings** → **API Credentials**
                                                                    2. 2. Create new API user
                                                                       3. 3. Copy credentials:
                                                                          4.    ```
                                                                                   PUBLIC_KEY=xxxxx
                                                                                   SECRET_KEY=xxxxx
                                                                                   ```

                                                                                ### 2.2 Alternative: DigitalOcean Deployment

                                                                            If you prefer DigitalOcean ($6/month droplet):

                                                                          ```bash
                                                                          # Create Ubuntu 20.04 droplet on DO
                                                                          # SSH in, then run:

                                                                          sudo apt-get update && sudo apt-get install -y \
                                                                            docker.io \
                                                                            docker-compose

                                                                          # Create docker-compose.yml
                                                                          docker-compose up -d

                                                                          # Access Mautic at http://your-do-ip:8080
                                                                          ```

                                                                          ### 2.3 Configure Mautic for Zidni

                                                                          1. **Create Mautic Segment for Users**
                                                                          2.    - Settings → Segments
                                                                                -    - Create segment: "Zidni Users"
                                                                                     -    - Add contact property filters as needed
                                                                                      
                                                                                          - 2. **Create Contact Field Mappings**
                                                                                            3.    - Settings → Contact Fields
                                                                                                  -    - Add fields matching your user schema:
                                                                                                       -      - `user_id` (Firebase UID)
                                                                                                       -       - `subscription_tier` (free/premium/pro)
                                                                                                       -        - `subscription_expiry`
                                                                                                   
                                                                                                       -    3. **Create Email Campaign Template**
                                                                                                            4.    - Campaigns → Email
                                                                                                                  -    - Create template for onboarding flow
                                                                                                                       -    - Save for use in Cloud Functions
                                                                                                                        
                                                                                                                            - ---
                                                                                                                            
                                                                                                                            ## PART 3: Cloud Functions for Integration
                                                                                                                            
                                                                                                                            ### 3.1 User Sync: Firebase → Mautic
                                                                                                                            
                                                                                                                            Create Cloud Function to sync users to Mautic when they sign up.
                                                                                                                            
                                                                                                                            **File:** `functions/sync-user-to-mautic.js`
                                                                                                                            
                                                                                                                            ```javascript
                                                                                                                            const functions = require('firebase-functions');
                                                                                                                            const admin = require('firebase-admin');
                                                                                                                            const axios = require('axios');

                                                                                                                            admin.initializeApp();

                                                                                                                            const MAUTIC_URL = process.env.MAUTIC_URL; // e.g., https://mautic.yoursite.com
                                                                                                                            const MAUTIC_PUBLIC = process.env.MAUTIC_PUBLIC_KEY;
                                                                                                                            const MAUTIC_SECRET = process.env.MAUTIC_SECRET_KEY;

                                                                                                                            exports.syncUserToMautic = functions.auth.user().onCreate(async (user) => {
                                                                                                                              try {
                                                                                                                                const contact = {
                                                                                                                                  email: user.email,
                                                                                                                                  firstname: user.displayName || 'User',
                                                                                                                                  custom_fields: {
                                                                                                                                    user_id: user.uid,
                                                                                                                                    signup_date: new Date().toISOString(),
                                                                                                                                    subscription_tier: 'free'
                                                                                                                                  }
                                                                                                                                };

                                                                                                                                const response = await axios.post(
                                                                                                                                  `${MAUTIC_URL}/api/contacts/new`,
                                                                                                                                  contact,
                                                                                                                                  {
                                                                                                                                    auth: {
                                                                                                                                      username: MAUTIC_PUBLIC,
                                                                                                                                      password: MAUTIC_SECRET
                                                                                                                                    }
                                                                                                                                  }
                                                                                                                                );

                                                                                                                                console.log('User synced to Mautic:', response.data);

                                                                                                                              } catch (error) {
                                                                                                                                console.error('Mautic sync error:', error);
                                                                                                                              }
                                                                                                                            });
                                                                                                                            ```
                                                                                                                            
                                                                                                                            ### 3.2 Event Tracking: Deal Creation
                                                                                                                            
                                                                                                                            Track when users create deals.
                                                                                                                            
                                                                                                                            **File:** `functions/track-deal-event.js`
                                                                                                                            
                                                                                                                            ```javascript
                                                                                                                            exports.trackDealEvent = functions.firestore
                                                                                                                              .document('deals/{dealId}')
                                                                                                                              .onCreate(async (snap, context) => {
                                                                                                                                const deal = snap.data();
                                                                                                                                const sellerUid = deal.seller_uid;

                                                                                                                                try {
                                                                                                                                  // Send event to Mautic
                                                                                                                                  await axios.post(
                                                                                                                                    `${MAUTIC_URL}/api/events/`,
                                                                                                                                    {
                                                                                                                                      action: 'deal.created',
                                                                                                                                      email: '', // Get from users collection
                                                                                                                                      properties: {
                                                                                                                                        deal_id: context.params.dealId,
                                                                                                                                        deal_value: deal.value || 0
                                                                                                                                      }
                                                                                                                                    },
                                                                                                                                    {
                                                                                                                                      auth: {
                                                                                                                                        username: MAUTIC_PUBLIC,
                                                                                                                                        password: MAUTIC_SECRET
                                                                                                                                      }
                                                                                                                                    }
                                                                                                                                  );
                                                                                                                                } catch (error) {
                                                                                                                                  console.error('Event tracking error:', error);
                                                                                                                                }
                                                                                                                              });
                                                                                                                            ```
                                                                                                                            
                                                                                                                            ### 3.3 Push Notifications: Mautic Webhook
                                                                                                                            
                                                                                                                            Receive campaign webhooks from Mautic and send push notifications.
                                                                                                                            
                                                                                                                            **File:** `functions/mautic-webhook.js`
                                                                                                                            
                                                                                                                            ```javascript
                                                                                                                            exports.mauticWebhook = functions.https.onRequest(async (req, res) => {
                                                                                                                              try {
                                                                                                                                const { contact, campaign } = req.body;

                                                                                                                                if (campaign.name === 'Onboarding Flow') {
                                                                                                                                  // Get user from Firestore
                                                                                                                                  const userDoc = await admin.firestore()
                                                                                                                                    .collection('users')
                                                                                                                                    .where('email', '==', contact.email)
                                                                                                                                    .limit(1)
                                                                                                                                    .get();

                                                                                                                                  if (!userDoc.empty) {
                                                                                                                                    // Send FCM push notification
                                                                                                                                    await admin.messaging().sendToDevice(
                                                                                                                                      userDoc.docs[0].data().fcm_token,
                                                                                                                                      {
                                                                                                                                        notification: {
                                                                                                                                          title: 'Welcome to Zidni!',
                                                                                                                                          body: 'Complete your profile to unlock all features'
                                                                                                                                        }
                                                                                                                                      }
                                                                                                                                    );
                                                                                                                                  }
                                                                                                                                }

                                                                                                                                res.json({ success: true });

                                                                                                                              } catch (error) {
                                                                                                                                console.error('Webhook error:', error);
                                                                                                                                res.status(500).json({ error: error.message });
                                                                                                                              }
                                                                                                                            });
                                                                                                                            ```
                                                                                                                            
                                                                                                                            ### 3.4 Deploy Cloud Functions
                                                                                                                            
                                                                                                                            ```bash
                                                                                                                            cd functions

                                                                                                                            # Install dependencies
                                                                                                                            npm install firebase-functions firebase-admin axios

                                                                                                                            # Set environment variables
                                                                                                                            firebase functions:config:set mautic.url="https://mautic.yoursite.com"
                                                                                                                            firebase functions:config:set mautic.public_key="xxxxx"
                                                                                                                            firebase functions:config:set mautic.secret_key="xxxxx"

                                                                                                                            # Deploy
                                                                                                                            firebase deploy --only functions
                                                                                                                            ```
                                                                                                                            
                                                                                                                            ---
                                                                                                                            
                                                                                                                            ## PART 4: RevenueCat Subscription Integration
                                                                                                                            
                                                                                                                            ### 4.1 Create RevenueCat Account & Project
                                                                                                                            
                                                                                                                            1. Go to [RevenueCat.com](https://www.revenuecat.com/)
                                                                                                                            2. 2. Sign up and create new project
                                                                                                                               3. 3. Select "Mobile App"
                                                                                                                                  4. 4. Choose your app's platforms
                                                                                                                                    
                                                                                                                                     5. ### 4.2 Configure App Store Credentials
                                                                                                                                    
                                                                                                                                     6. For iOS/Android in-app purchases, add store credentials to RevenueCat:
                                                                                                                                    
                                                                                                                                     7. **iOS:**
                                                                                                                                     8. 1. Go to RevenueCat Dashboard → **Configuration**
                                                                                                                                        2. 2. Add App Store Connect credentials
                                                                                                                                           3. 3. RevenueCat will sync subscription products
                                                                                                                                             
                                                                                                                                              4. **Android:**
                                                                                                                                              5. 1. Add Google Play Service Account JSON key
                                                                                                                                                 2. 2. RevenueCat auto-syncs products
                                                                                                                                                   
                                                                                                                                                    3. ### 4.3 Get RevenueCat API Key
                                                                                                                                                   
                                                                                                                                                    4. 1. Dashboard → **Project Settings**
                                                                                                                                                       2. 2. Copy API Key (you'll need this for webhooks)
                                                                                                                                                         
                                                                                                                                                          3. ### 4.4 Sync Subscriptions to Firebase
                                                                                                                                                         
                                                                                                                                                          4. Create Cloud Function to push subscription data to Firebase.
                                                                                                                                                         
                                                                                                                                                          5. **File:** `functions/sync-subscriptions.js`
                                                                                                                                                         
                                                                                                                                                          6. ```javascript
                                                                                                                                                             exports.revenueCatWebhook = functions.https.onRequest(async (req, res) => {
                                                                                                                                                               const event = req.body.event;
                                                                                                                                                               const user = req.body.subscriber;

                                                                                                                                                               try {
                                                                                                                                                                 if (event.type === 'SUBSCRIPTION_RENEWED') {
                                                                                                                                                                   // Update user's subscription in Firestore
                                                                                                                                                                   await admin.firestore().collection('users').doc(user.id).update({
                                                                                                                                                                     subscription_status: 'active',
                                                                                                                                                                     subscription_tier: event.subscription.product_identifier,
                                                                                                                                                                     subscription_expiry: new Date(event.subscription.expiration_date),
                                                                                                                                                                     updated_at: admin.firestore.FieldValue.serverTimestamp()
                                                                                                                                                                   });
                                                                                                                                                                 }

                                                                                                                                                                 res.json({ success: true });
                                                                                                                                                               } catch (error) {
                                                                                                                                                                 res.status(500).json({ error: error.message });
                                                                                                                                                               }
                                                                                                                                                             });
                                                                                                                                                             ```
                                                                                                                                                             
                                                                                                                                                             ### 4.5 Enable RevenueCat Webhooks
                                                                                                                                                             
                                                                                                                                                             1. Dashboard → **Integrations** → **Webhooks**
                                                                                                                                                             2. 2. Add webhook URL: `https://your-project.cloudfunctions.net/revenueCatWebhook`
                                                                                                                                                                3. 3. Select events:
                                                                                                                                                                   4.    - SUBSCRIPTION_RENEWED
                                                                                                                                                                         -    - SUBSCRIPTION_EXPIRED
                                                                                                                                                                              -    - SUBSCRIPTION_DOWNGRADE
                                                                                                                                                                                   - 4. Save
                                                                                                                                                                                    
                                                                                                                                                                                     5. ---
                                                                                                                                                                                    
                                                                                                                                                                                     6. ## PART 5: Local Testing & Running Admin Dashboard
                                                                                                                                                                                    
                                                                                                                                                                                     7. ### 5.1 Run Admin Dashboard Locally
                                                                                                                                                                                    
                                                                                                                                                                                     8. ```bash
                                                                                                                                                                                        cd admin

                                                                                                                                                                                        # Install dependencies
                                                                                                                                                                                        flutter pub get

                                                                                                                                                                                        # Generate Firebase options (one-time)
                                                                                                                                                                                        flutterfire configure

                                                                                                                                                                                        # Run on web
                                                                                                                                                                                        flutter run -d chrome

                                                                                                                                                                                        # Or run on specific port
                                                                                                                                                                                        flutter run -d chrome --web-port=3000
                                                                                                                                                                                        ```
                                                                                                                                                                                        
                                                                                                                                                                                        ### 5.2 Test Authentication
                                                                                                                                                                                        
                                                                                                                                                                                        1. Open http://localhost:3000 in browser
                                                                                                                                                                                        2. 2. Click "Sign In"
                                                                                                                                                                                           3. 3. Enter test email and password
                                                                                                                                                                                              4. 4. Check Firebase Console → **Authentication** for new user
                                                                                                                                                                                              5. Check Firestore for new user document
                                                                                                                                                                                             
                                                                                                                                                                                              6. ### 5.3 Test Firestore Connection
                                                                                                                                                                                              
                                                                                                                                                                                              In the admin dashboard:
                                                                                                                                                                                              1. Go to Dashboard page
                                                                                                                                                                                              2. Should see KPI cards loading (may show 0 initially)
                                                                                                                                                                                              3. Check browser console for Firebase errors
                                                                                                                                                                                              4. Check Firebase Console → **Firestore** for test data
                                                                                                                                                                                             
                                                                                                                                                                                              5. ### 5.4 Test Mautic Connection
                                                                                                                                                                                             
                                                                                                                                                                                              6. 1. In admin dashboard, go to Marketing page
                                                                                                                                                                                              2. Click "Load Campaigns"
                                                                                                                                                                                              3. 3. Should see list of campaigns from your Mautic instance
                                                                                                                                                                                                 4. 4. If empty, verify Mautic credentials in Firebase environment variables
                                                                                                                                                                                                 
                                                                                                                                                                                                 ### 5.5 Complete Integration Test Checklist
                                                                                                                                                                                                 
                                                                                                                                                                                                 - [ ] Firebase authentication working (can sign in)
                                                                                                                                                                                                 - [ ] Firestore database connected (can read/write test data)
                                                                                                                                                                                                 - [ ] Mautic API credentials correct (campaigns load)
                                                                                                                                                                                                 - [ ] Cloud Functions deployed (check Firebase Console)
                                                                                                                                                                                                 - [ ] RevenueCat webhooks configured (check logs)
                                                                                                                                                                                                 - [ ] Browser console has no errors
                                                                                                                                                                                                 - [ ] Dashboard KPI cards update
                                                                                                                                                                                                 - [ ] Navigation between pages works
                                                                                                                                                                                                 
                                                                                                                                                                                                 ### 5.6 Common Issues & Fixes
                                                                                                                                                                                                 
                                                                                                                                                                                                 **Issue:** "Firebase not initialized"  
                                                                                                                                                                                                 **Fix:** Run `flutterfire configure` in admin directory
                                                                                                                                                                                                 
                                                                                                                                                                                                 **Issue:** Firestore queries return empty  
                                                                                                                                                                                                 **Fix:** Check security rules - they might be too restrictive
                                                                                                                                                                                                 
                                                                                                                                                                                                 **Issue:** Mautic API returns 401 Unauthorized  
                                                                                                                                                                                                 **Fix:** Verify API credentials in Firebase config
                                                                                                                                                                                                 
                                                                                                                                                                                                 **Issue:** Push notifications not sending  
                                                                                                                                                                                                 **Fix:** Ensure FCM tokens are saved in users collection
                                                                                                                                                                                                 
                                                                                                                                                                                                 ---
                                                                                                                                                                                                 
                                                                                                                                                                                                 ## Deployment Timeline
                                                                                                                                                                                                 
                                                                                                                                                                                                 - **Week 1:** Firebase + Firestore ✅ (FIREBASE_SETUP.md)
                                                                                                                                                                                                 - - **Week 1:** Mautic deployment (this guide)
                                                                                                                                                                                                   - - **Week 2:** Cloud Functions
                                                                                                                                                                                                   - **Week 2:** RevenueCat webhooks
                                                                                                                                                                                                   - **Week 3:** Full local testing & integration
                                                                                                                                                                                                   - **Week 4:** Staging deployment (Vercel for admin dashboard)
                                                                                                                                                                                                   - **Week 5:** Production release
                                                                                                                                                                                                   
                                                                                                                                                                                                   ---
                                                                                                                                                                                                   
                                                                                                                                                                                                   ## Success Metrics
                                                                                                                                                                                                   
                                                                                                                                                                                                   Once fully set up:
                                                                                                                                                                                                   
                                                                                                                                                                                                   1. **User Growth:** Track signups via Firestore analytics
                                                                                                                                                                                                   2. **Campaign Performance:** Monitor email opens in Mautic
                                                                                                                                                                                                   3. **Revenue:** RevenueCat dashboard shows subscription metrics
                                                                                                                                                                                                   4. 4. **Errors:** Sentry/Firebase Crashlytics track bugs
                                                                                                                                                                                                   5. **Performance:** Firebase Console shows query metrics
                                                                                                                                                                                                   
                                                                                                                                                                                                   ---
                                                                                                                                                                                                   
                                                                                                                                                                                                   ## Next Steps
                                                                                                                                                                                                   
                                                                                                                                                                                                   1. Complete Firebase setup (see FIREBASE_SETUP.md)
                                                                                                                                                                                                   2. 2. Deploy Mautic on Railway or DigitalOcean
                                                                                                                                                                                                   3. Deploy Cloud Functions from `functions/` directory
                                                                                                                                                                                                   4. 4. Configure RevenueCat webhooks
                                                                                                                                                                                                   5. Run local testing checklist
                                                                                                                                                                                                   6. 6. Monitor logs in Firebase Console
                                                                                                                                                                                                   
                                                                                                                                                                                                   ## Support Resources
                                                                                                                                                                                                   
                                                                                                                                                                                                   - [Mautic Documentation](https://docs.mautic.org/)
                                                                                                                                                                                                   - [Railway.app Docs](https://docs.railway.app/)
                                                                                                                                                                                                   - [RevenueCat Docs](https://docs.revenuecat.com/)
                                                                                                                                                                                                   - - [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
                                                                                                                                                                                                   - [FlutterFire Web](https://firebase.flutter.dev/docs/overview)
                                                                                                                                                                                                   
                                                                                                                                                                                                   ---
                                                                                                                                                                                                   
                                                                                                                                                                                                   **Status:** ✅ All guides created and committed to `/docs`
                                                                                                                                                                                                   
                                                                                                                                                                                                   For questions or issues, see individual guide files in `/docs/`:
                                                                                                                                                                                                   - `FIREBASE_SETUP.md` - Step-by-step Firebase config
                                                                                                                                                                                                   - `ADMIN_DASHBOARD_COMPLETE_SETUP.md` - This file (Mautic + Cloud Functions + RevenueCat)
                                                                                                                                                                                                   
