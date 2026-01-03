# Zidni Admin Dashboard + Marketing Integration Plan

**Prepared by:** Manus AI  
**Date:** January 2, 2026  
**Version:** 1.0

---

## Executive Summary

This document outlines the integration plan for implementing a comprehensive admin dashboard and marketing automation system for Zidni. The solution combines **FlareLine** (Flutter-based admin panel) for day-to-day operations with **Mautic** (open-source marketing automation) for user engagement and growth campaigns.

The total implementation timeline is estimated at **6-8 weeks**, with both systems being 100% free and open source.

---

## 1. System Architecture

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ZIDNI ECOSYSTEM                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐                           ┌─────────────────────────┐  │
│  │  Zidni Mobile   │                           │   FlareLine Admin       │  │
│  │     App         │                           │      Dashboard          │  │
│  │                 │                           │                         │  │
│  │  - iOS/Android  │                           │  - User Management      │  │
│  │  - 24K+ lines   │                           │  - Deal Analytics       │  │
│  │  - Flutter/Dart │                           │  - Content Management   │  │
│  └────────┬────────┘                           │  - Subscription Stats   │  │
│           │                                    └────────────┬────────────┘  │
│           │                                                 │               │
│           ▼                                                 ▼               │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         FIREBASE BACKEND                              │  │
│  │                                                                       │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │  │
│  │   │  Firestore   │  │    Auth      │  │   Storage    │               │  │
│  │   │  (Database)  │  │  (Users)     │  │  (Files)     │               │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘               │  │
│  │                                                                       │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │  │
│  │   │  Analytics   │  │ Crashlytics  │  │     FCM      │               │  │
│  │   │  (Metrics)   │  │  (Crashes)   │  │   (Push)     │               │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    │ Webhooks / API                         │
│                                    ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         MAUTIC MARKETING                              │  │
│  │                                                                       │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │  │
│  │   │    Email     │  │    Push      │  │    Lead      │               │  │
│  │   │  Campaigns   │  │ Automation   │  │   Scoring    │               │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘               │  │
│  │                                                                       │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │  │
│  │   │   Landing    │  │    A/B       │  │  Segments    │               │  │
│  │   │    Pages     │  │   Testing    │  │  & Lists     │               │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Data Flow

| Flow | Source | Destination | Data | Trigger |
|------|--------|-------------|------|---------|
| User Registration | Zidni App | Firebase → Mautic | Email, name, language | On signup |
| Deal Created | Zidni App | Firebase → FlareLine | Deal details | Real-time |
| Subscription Change | RevenueCat | Firebase → Mautic | Plan, status | Webhook |
| Campaign Send | Mautic | FCM → Zidni App | Push notification | Scheduled |
| Analytics Sync | Firebase | FlareLine Dashboard | DAU, retention | Daily |

---

## 2. FlareLine Admin Dashboard

### 2.1 Overview

FlareLine is a free, open-source Flutter admin dashboard template that provides a solid foundation for Zidni's admin panel. It includes pre-built components for charts, tables, forms, and authentication.

| Aspect | Details |
|--------|---------|
| **Repository** | github.com/FlutterFlareLine/FlareLine |
| **License** | MIT (100% free) |
| **Tech Stack** | Flutter 3.24+, Dart |
| **Platforms** | Web, Desktop (Windows, macOS, Linux) |
| **Localization** | Arabic, Chinese, English (pre-built) |

### 2.2 Customization Plan

The following pages need to be created or customized for Zidni:

| Page | Base Component | Customization Needed | Priority | Effort |
|------|---------------|---------------------|----------|--------|
| **Dashboard Home** | `ecommerce_page.dart` | Replace metrics with Zidni KPIs | P0 | 1 day |
| **User Management** | `table/` components | New page with Firestore integration | P0 | 2 days |
| **Deal Analytics** | `chart/` components | Custom charts for deal funnel | P0 | 2 days |
| **Subscription Stats** | `analytics_widget.dart` | RevenueCat API integration | P1 | 2 days |
| **Content Manager** | `form/` components | Phrase pack CRUD | P1 | 3 days |
| **Push Sender** | New page | FCM integration | P1 | 1 day |
| **Translation Monitor** | `grid_card.dart` | API usage tracking | P2 | 1 day |

### 2.3 Firebase Integration

FlareLine does not include Firebase by default. The following packages must be added:

```yaml
# pubspec.yaml additions
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_analytics: ^11.3.6
```

The authentication flow in `sign_in_provider.dart` must be updated from placeholder to real Firebase Auth:

```dart
// Before (placeholder)
Future<void> signIn(BuildContext context) async {
  Navigator.of(context).pushNamed('/');
}

// After (real Firebase Auth)
Future<void> signIn(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    // Check if user is admin
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    if (doc.data()?['role'] == 'admin') {
      Navigator.of(context).pushNamed('/');
    } else {
      throw Exception('Not authorized');
    }
  } catch (e) {
    SnackBarUtil.showSnack(context, 'Login failed: $e');
  }
}
```

### 2.4 Zidni-Specific Dashboard Widgets

#### 2.4.1 KPI Cards (Dashboard Home)

| Metric | Data Source | Update Frequency |
|--------|-------------|------------------|
| Total Users | Firestore `users` collection | Real-time |
| Active Deals | Firestore `deals` collection | Real-time |
| Translation Calls (Today) | Cloud Functions counter | Hourly |
| Revenue (MTD) | RevenueCat API | Daily |
| DAU/MAU | Firebase Analytics | Daily |
| Crash-Free Rate | Firebase Crashlytics | Real-time |

#### 2.4.2 User Management Table

| Column | Type | Actions |
|--------|------|---------|
| Name | Text | - |
| Email | Text | Copy |
| Plan | Badge (Free/Pro/Premium) | Upgrade/Downgrade |
| Deals Created | Number | View deals |
| Last Active | Date | - |
| Status | Badge (Active/Suspended) | Suspend/Activate |

#### 2.4.3 Deal Analytics Charts

| Chart | Type | Data |
|-------|------|------|
| Deals by Status | Pie chart | Draft, Active, Completed, Cancelled |
| Deals Over Time | Line chart | Daily deal creation trend |
| Top Categories | Bar chart | Product categories |
| Conversion Funnel | Funnel chart | Created → Contacted → Negotiating → Closed |

### 2.5 Deployment

FlareLine can be deployed to Vercel for free:

```bash
# Build for web
flutter build web --release

# Deploy to Vercel
vercel deploy --prod
```

Estimated monthly cost: **$0** (Vercel free tier)

---

## 3. Mautic Marketing Automation

### 3.1 Overview

Mautic is the world's largest open-source marketing automation platform, used by over 200,000 companies. It provides enterprise-grade marketing features without licensing costs.

| Aspect | Details |
|--------|---------|
| **Repository** | github.com/mautic/mautic |
| **License** | GPL v3 (100% free) |
| **Tech Stack** | PHP 8.1+, MySQL/MariaDB, Symfony |
| **Languages** | 40+ including Arabic |
| **API** | REST API for integration |

### 3.2 Key Features for Zidni

| Feature | Use Case for Zidni |
|---------|-------------------|
| **Email Campaigns** | Welcome series, feature announcements, re-engagement |
| **Push Notifications** | Deal reminders, new phrase packs, promotions |
| **Lead Scoring** | Identify power users for upselling |
| **Segments** | Group users by language, plan, activity level |
| **Landing Pages** | App download pages, feature showcases |
| **A/B Testing** | Test email subjects, push timing |
| **Automation Workflows** | Drip campaigns, onboarding sequences |

### 3.3 Hosting Options

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **Self-hosted (DigitalOcean)** | $12-24/month | Full control, unlimited contacts | Requires maintenance |
| **Mautic Cloud** | $0 (14-day trial) then paid | Managed, no maintenance | Limited free tier |
| **AWS Lightsail** | $10/month | Scalable, reliable | More complex setup |

**Recommendation:** Start with DigitalOcean $12/month droplet for MVP, scale as needed.

### 3.4 Integration with Zidni

#### 3.4.1 User Sync (Firebase → Mautic)

When a user registers in Zidni, their data should be synced to Mautic for marketing:

```javascript
// Cloud Function: syncUserToMautic
exports.syncUserToMautic = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    
    const mauticPayload = {
      email: user.email,
      firstname: user.name?.split(' ')[0] || '',
      lastname: user.name?.split(' ').slice(1).join(' ') || '',
      language: user.preferredLanguage || 'ar',
      custom_fields: {
        app_user_id: context.params.userId,
        signup_date: user.createdAt,
        subscription_plan: user.plan || 'free',
      }
    };
    
    await fetch(`${MAUTIC_URL}/api/contacts/new`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${MAUTIC_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(mauticPayload),
    });
  });
```

#### 3.4.2 Event Tracking

Track key user actions to trigger marketing automations:

| Event | Trigger | Mautic Action |
|-------|---------|---------------|
| `first_deal_created` | User creates first deal | Send "Deal Tips" email |
| `translation_limit_80` | User hits 80% of translation quota | Send upgrade prompt |
| `inactive_7_days` | No app open for 7 days | Send re-engagement push |
| `subscription_upgraded` | User upgrades plan | Send "Pro Features" guide |
| `deal_completed` | Deal marked as completed | Request review/rating |

#### 3.4.3 Push Notification Integration

Mautic can trigger push notifications via Firebase Cloud Messaging:

```javascript
// Cloud Function: mauticPushWebhook
exports.mauticPushWebhook = functions.https.onRequest(async (req, res) => {
  const { contactId, title, body, data } = req.body;
  
  // Get user's FCM token from Firestore
  const userDoc = await admin.firestore()
    .collection('users')
    .where('mauticContactId', '==', contactId)
    .limit(1)
    .get();
  
  if (userDoc.empty) {
    return res.status(404).send('User not found');
  }
  
  const fcmToken = userDoc.docs[0].data().fcmToken;
  
  // Send push via FCM
  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
    data: data || {},
  });
  
  res.status(200).send('Push sent');
});
```

### 3.5 Marketing Campaigns for Zidni

#### 3.5.1 Onboarding Sequence

| Day | Channel | Message |
|-----|---------|---------|
| 0 | Push | "Welcome to Zidni! Start with Quick Phrases" |
| 1 | Email | "5 Essential Phrases for Your First Trade Fair" |
| 3 | Push | "Try the AI Translator - 50 free translations!" |
| 7 | Email | "Your First Week Stats + Tips" |
| 14 | Push | "Upgrade to Pro for unlimited translations" |

#### 3.5.2 Re-engagement Campaign

| Trigger | Wait | Action |
|---------|------|--------|
| No app open 7 days | - | Send push: "We miss you! New phrases added" |
| No response | 3 days | Send email: "What's holding you back?" |
| No response | 7 days | Send push: "Special offer: 50% off Pro" |

#### 3.5.3 Upgrade Campaign

| Segment | Trigger | Message |
|---------|---------|---------|
| Free users, 10+ deals | Deal #10 created | "You're a power user! Unlock Pro features" |
| Free users, 80% translation quota | API call | "Running low on translations? Upgrade now" |
| Trial ending | 3 days before | "Your trial ends soon - don't lose access" |

---

## 4. Implementation Timeline

### Phase 1: Foundation (Weeks 1-2)

| Task | Owner | Duration | Dependencies |
|------|-------|----------|--------------|
| Clone & setup FlareLine | Dev | 1 day | - |
| Add Firebase packages | Dev | 1 day | FlareLine setup |
| Implement Firebase Auth | Dev | 2 days | Firebase packages |
| Create Dashboard Home | Dev | 2 days | Firebase Auth |
| Setup Mautic server | DevOps | 1 day | - |
| Configure Mautic API | Dev | 1 day | Mautic server |
| Create user sync Cloud Function | Dev | 1 day | Mautic API |

### Phase 2: Core Features (Weeks 3-4)

| Task | Owner | Duration | Dependencies |
|------|-------|----------|--------------|
| User Management page | Dev | 2 days | Dashboard Home |
| Deal Analytics page | Dev | 2 days | Dashboard Home |
| Subscription Stats page | Dev | 2 days | RevenueCat setup |
| Setup onboarding campaign | Marketing | 2 days | User sync |
| Setup re-engagement campaign | Marketing | 1 day | Event tracking |
| Push notification integration | Dev | 2 days | Mautic API |

### Phase 3: Advanced Features (Weeks 5-6)

| Task | Owner | Duration | Dependencies |
|------|-------|----------|--------------|
| Content Manager page | Dev | 3 days | Core features |
| Push Sender page | Dev | 1 day | Push integration |
| Translation Monitor page | Dev | 1 day | Core features |
| A/B testing setup | Marketing | 2 days | Campaigns |
| Landing pages | Marketing | 2 days | Mautic |

### Phase 4: Testing & Launch (Weeks 7-8)

| Task | Owner | Duration | Dependencies |
|------|-------|----------|--------------|
| Integration testing | QA | 3 days | All features |
| Performance optimization | Dev | 2 days | Testing |
| Documentation | Dev | 2 days | All features |
| Deploy to production | DevOps | 1 day | Testing |
| Team training | All | 2 days | Deployment |

---

## 5. Cost Estimate

### 5.1 Monthly Operating Costs

| Service | Cost | Notes |
|---------|------|-------|
| FlareLine (Vercel) | $0 | Free tier |
| Mautic (DigitalOcean) | $12-24 | 2GB-4GB droplet |
| Firebase | $0-25 | Spark plan free, Blaze pay-as-you-go |
| Domain (optional) | $1 | admin.zidni.app |
| **Total** | **$13-50/month** | |

### 5.2 One-Time Setup Costs

| Item | Cost | Notes |
|------|------|-------|
| Development | $0 | If done in-house |
| SSL Certificate | $0 | Let's Encrypt |
| **Total** | **$0** | |

---

## 6. Security Considerations

### 6.1 Admin Dashboard Security

| Measure | Implementation |
|---------|---------------|
| Authentication | Firebase Auth with email/password |
| Authorization | Role-based access (admin role in Firestore) |
| HTTPS | Enforced via Vercel |
| Session timeout | 24 hours |
| IP whitelist | Optional, via Vercel |

### 6.2 Mautic Security

| Measure | Implementation |
|---------|---------------|
| Authentication | Username/password + 2FA |
| API security | API key with rate limiting |
| Data encryption | SSL/TLS for all connections |
| GDPR compliance | Built-in consent management |

---

## 7. Success Metrics

### 7.1 Admin Dashboard KPIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| Admin response time | < 2 hours | Time to resolve user issues |
| Dashboard load time | < 3 seconds | Performance monitoring |
| Data accuracy | 99.9% | Audit vs Firebase |

### 7.2 Marketing KPIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| Email open rate | > 25% | Mautic analytics |
| Push click rate | > 8% | FCM + Mautic |
| Onboarding completion | > 60% | Event tracking |
| Free-to-paid conversion | > 5% | RevenueCat |
| Churn reduction | 20% decrease | Monthly cohort analysis |

---

## 8. Next Steps

1. **Approve this plan** and confirm timeline
2. **Setup development environment** for FlareLine
3. **Provision Mautic server** on DigitalOcean
4. **Create Firebase project** (if not exists) and configure admin role
5. **Begin Phase 1 development**

---

## References

1. [FlareLine GitHub Repository](https://github.com/FlutterFlareLine/FlareLine)
2. [Mautic Official Website](https://mautic.org/)
3. [Mautic GitHub Repository](https://github.com/mautic/mautic)
4. [Firebase Flutter Documentation](https://firebase.flutter.dev/)
5. [Mautic REST API Documentation](https://developer.mautic.org/)
6. [RevenueCat Flutter SDK](https://www.revenuecat.com/docs/getting-started/installation/flutter)

---

*Document prepared by Manus AI on January 2, 2026*
