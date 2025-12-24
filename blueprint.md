# Alwakil - Firestore Blueprint

## 1. Core Design Rules

*   **Rule 1 — Private-by-default:** User-owned data lives under `/users/{uid}/...`
*   **Rule 2 — Public data is mirrored:** Anything searchable globally is a public mirror with limited fields.
*   **Rule 3 — Artifacts are first-class:** Every Alwakil output is an “artifact” you can share (WhatsApp card/PDF).
*   **Rule 4 — Proof is sacred:** Pay always writes to a receipt vault + audit log.
*   **Rule 5 — Trust scoring is server-owned:** Only Cloud Functions can write trust scores / risk flags.

## 2. Collections Overview

### Identity + Trust
*   `users/{uid}` (private root doc)
*   `public_profiles/{uid}` (public mirror for discovery)
*   `trust_profiles/{uid}` (server-owned trust + tiers)
*   `kyc_cases/{caseId}` (optional, if/when you do verification)

### GUL (Voice: “Tongue”)
*   `voice_sessions/{sessionId}`
*   `users/{uid}/voice_sessions/{sessionId}` (user-owned mirror)
*   `conversation_threads/{threadId}` (optional, if you keep threads)

### Alwakil (Action: “Hands”)
*   `deal_folders/{folderId}` (shareable business objects)
*   `artifacts/{artifactId}` (reports, checklists, summaries, drafts)
*   `scans/{scanId}` (OCR inputs + extracted entities)
*   `entities/{entityId}` (normalized suppliers/products/people/orgs)

### Pay (Pocket: money + proof)
*   `wallets/{walletId}` (if/when you store balances; otherwise omit)
*   `payment_intents/{intentId}` (partner-first payments)
*   `invoices/{invoiceId}`
*   `receipts/{receiptId}` (proof vault, immutable)
*   `disputes/{disputeId}` (evidence bundles + timeline)

### Services (City: marketplace)
*   `services/{serviceId}`
*   `merchants/{merchantId}`
*   `orders/{orderId}` (if ordering/bookings exist)
*   `mini_apps/{appId}` (plug-in registry)
*   `subscriptions/{subId}` (Zidni plans + entitlements)

### System
*   `notifications/{notificationId}`
*   `audit_logs/{logId}` (server-only, compliance, debugging)
*   `feature_flags/{flagId}`
*   `rate_limits/{key}` (optional)

## 3. Key Document Schemas

### users/{uid}
```json
{
  "displayName": "String",
  "phone": "String",
  "locale": "String",
  "dialect": "String",
  "createdAt": "Timestamp",
  "lastActiveAt": "Timestamp",
  "roles": ["user", "merchant_admin"],
  "defaults": { "currency": "USD", "country": "MR" },
  "privacy": { "shareByDefault": false }
}
```

### public_profiles/{uid}
```json
{
  "name": "String",
  "city": "String",
  "categories": ["Trader", "Logistics", "Tiles"],
  "tierBadge": "Verified|Pro|Certified",
  "ratingSummary": { "avg": "Number", "count": "Number" },
  "updatedAt": "Timestamp"
}
```

### trust_profiles/{uid}
```json
{
  "tier": "Basic|Verified|Pro|Certified",
  "score": "Number",
  "flags": ["high_dispute_rate", "unverified_docs"],
  "signals": { "receiptsCount": "Number", "disputesCount": "Number", "successfulDeals": "Number" },
  "updatedAt": "Timestamp"
}
```

### voice_sessions/{sessionId}
```json
{
  "ownerUid": "String",
  "mode": "translate|summarize|capture_terms",
  "languages": { "from": "ar", "to": "zh" },
  "status": "open|closed",
  "createdAt": "Timestamp",
  "closedAt": "Timestamp",
  "linked": { "dealFolderId": "String", "threadId": "String" },
  "share": { "enabled": false, "shareId": null }
}
```

### deal_folders/{folderId}
```json
{
  "ownerUid": "String",
  "title": "String",
  "type": "supplier_deal|product_research|immigration_case|personal",
  "participants": [{ "uidOrExternalId": "String", "role": "supplier|buyer|agent" }],
  "tags": ["tiles","foshan"],
  "status": "active|won|lost|archived",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "acl": { "owners":["uid"], "editors":["uid"], "viewers":["uid"], "publicShare":false }
}
```

### scans/{scanId}
```json
{
  "ownerUid": "String",
  "source": "camera|upload",
  "docType": "license|invoice|product|receipt|id|qr",
  "storagePath": "String",
  "extracted": { "text": "String", "fields": "Map", "entities": ["entityId"] },
  "linked": { "dealFolderId": "String", "artifactId": "String" },
  "createdAt": "Timestamp"
}
```

### artifacts/{artifactId}
```json
{
  "ownerUid": "String",
  "kind": "trust_report|summary|checklist|negotiation_script|pdf",
  "title": "String",
  "content": { "blocks":[] },
  "confidence": "Number",
  "sources": [{ "type":"scan", "id":"scanId" }, { "type":"user_note", "id": "String" } ],
  "share": { "enabled":true, "shareId": "String", "expiresAt": "Timestamp" },
  "linked": { "dealFolderId": "String" },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### entities/{entityId}
```json
{
  "type": "supplier|product|person|company",
  "name": "String",
  "identifiers": { "phone": "String", "wechat": "String", "licenseNo": "String", "website": "String" },
  "country": "String",
  "trustSignals": { "seenInReceipts": "Number", "disputes": "Number" },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### payment_intents/{intentId}
```json
{
  "ownerUid": "String",
  "amount": "Number", "currency": "String",
  "purpose": "invoice_payment|escrow|subscription",
  "status": "created|processing|succeeded|failed|canceled",
  "partner": { "name":"Skyee|Stripe|...", "refId": "String" },
  "linked": { "invoiceId": "String", "dealFolderId": "String" },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### receipts/{receiptId}
```json
{
  "ownerUid": "String",
  "type": "payment|refund|escrow_release",
  "amount": "Number", "currency": "String",
  "parties": { "payer": "String", "payee": "String" },
  "proof": { "partnerRef": "String", "invoiceNo": "String", "files":["storagePath"] },
  "linked": { "paymentIntentId": "String", "invoiceId": "String", "dealFolderId": "String" },
  "createdAt": "Timestamp",
  "immutable": true
}
```

### disputes/{disputeId}
```json
{
  "ownerUid": "String",
  "against": { "entityId": "String" or "uid": "String" },
  "status": "open|negotiation|mediation|resolved|closed",
  "claim": { "amount": "Number", "reason": "String" },
  "evidence": { "receipts":["receiptId"], "artifacts":["artifactId"], "scans":["scanId"] },
  "timeline": [{ "at": "Timestamp", "by": "String", "action": "String", "note": "String" }],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### services/{serviceId}
```json
{
  "nameAr": "String",
  "category": "String",
  "enabled": true,
  "routingHint": "services",
  "trustRequiredTier": "Basic|Verified|Pro",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### mini_apps/{appId}
```json
{
  "name": "String",
  "ownerOrgId": "String",
  "entryPoints": [
    { "type":"url"|"native", "pathOrScheme": "String", "intents":["scan","pay","verify"] }
  ],
  "permissions": ["read_public_profile", "create_order"],
  "enabled": true,
  "updatedAt": "Timestamp"
}
```

## 4. Security Rules (Baseline)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only manage their own data
    match /users/{userId}/{documents=**} {
      allow read, write: if request.auth.uid == userId;
    }

    // Public profiles are read-only for authenticated users
    match /public_profiles/{userId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Trust profiles are server-owned
    match /trust_profiles/{userId} {
      allow read, write: if false;
    }

    // Deal folders can be created by the owner
    match /deal_folders/{folderId} {
        allow create: if request.resource.data.ownerUid == request.auth.uid;
        allow read, write: if resource.data.ownerUid == request.auth.uid;
    }

    // Artifacts can be created by the owner
    match /artifacts/{artifactId} {
        allow create: if request.resource.data.ownerUid == request.auth.uid;
        allow read, write: if resource.data.ownerUid == request.auth.uid;
    }

    // Scans can be created by the owner
    match /scans/{scanId} {
        allow create: if request.resource.data.ownerUid == request.auth.uid;
        allow read, write: if resource.data.ownerUid == request.auth.uid;
    }

    // Voice sessions can be created by the owner
    match /voice_sessions/{sessionId} {
        allow create: if request.resource.data.ownerUid == request.auth.uid;
        allow read, write: if resource.data.ownerUid == request.auth.uid;
    }

    // Receipts are immutable
    match /receipts/{receiptId} {
      allow create: if request.resource.data.ownerUid == request.auth.uid;
      allow read: if resource.data.ownerUid == request.auth.uid;
      allow update, delete: if false;
    }

    // Audit logs are server-only
    match /audit_logs/{logId} {
      allow read, write: if false;
    }
  }
}
```
