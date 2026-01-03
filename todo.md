## Admin Dashboard + Marketing (Hybrid Approach)

### Phase 1: FlareLine Setup
- [x] Clone and configure FlareLine for Zidni
- [x] Add Firebase packages (core, auth, firestore)
- [x] Implement admin authentication with role check
- [x] Configure Arabic/Chinese localization (already in FlareLine)
- [x] Setup project structure

### Phase 2: Admin Pages
- [x] Dashboard Home with Zidni KPIs
- [x] User Management page
- [x] Deal Analytics page
- [ ] Subscription Stats page (RevenueCat) - needs RevenueCat setup
- [x] Content Manager page (Phrase packs)
- [x] Push Notification sender

### Phase 3: Mautic Setup
- [x] Setup Mautic service configuration
- [x] Configure REST API access (mautic_service.dart)
- [ ] Create contact custom fields for Zidni - needs Mautic server
- [ ] Setup email templates - needs Mautic server

### Phase 4: Integration
- [ ] Cloud Function: User sync to Mautic
- [ ] Cloud Function: Event tracking
- [ ] Cloud Function: Push notification webhook
- [ ] Test end-to-end flow

### Phase 5: Marketing Campaigns
- [ ] Onboarding email sequence
- [ ] Re-engagement campaign
- [ ] Upgrade prompts

---

## Completed Files (Pushed to GitHub)

### Admin Dashboard (/admin folder)
- `lib/services/firebase_service.dart` - Firebase integration
- `lib/services/mautic_service.dart` - Mautic API integration
- `lib/pages/zidni/zidni_dashboard_page.dart` - Main dashboard with KPIs
- `lib/pages/zidni/user_management_page.dart` - User management
- `lib/pages/zidni/deal_analytics_page.dart` - Deal analytics
- `lib/pages/zidni/marketing_page.dart` - Marketing automation
- `lib/pages/zidni/content_management_page.dart` - Content management
- `lib/pages/auth/sign_in/sign_in_provider.dart` - Updated with Firebase auth
- `pubspec.yaml` - Updated with Firebase + Riverpod dependencies
