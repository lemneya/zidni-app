# Orchestrator API Contract

> Minimal API contract for the Zidni Orchestrator — the shared brain routing layer.

## Base URL

```
Production: https://api.zidni.app/orchestrator/v1
Development: http://localhost:3100/orchestrator/v1
```

---

## Endpoints

### POST /tools/invoke

Invoke a registered tool by name.

**Request:**
```json
{
  "tool": "zidni.detect_mode",
  "params": {
    "text": "I want to find suppliers in Yiwu"
  },
  "client_role": "consumer_app",
  "session_id": "abc123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "result": {
    "detected_mode": "TRADER",
    "confidence": 0.92
  }
}
```

**Response (Denied):**
```json
{
  "success": false,
  "error": "TOOL_NOT_ALLOWED",
  "message": "Tool 'admin.delete_all' is not permitted for role 'consumer_app'"
}
```

**Response (Not Found):**
```json
{
  "success": false,
  "error": "TOOL_NOT_FOUND",
  "message": "Unknown tool: 'zidni.nonexistent'"
}
```

---

### POST /mode/detect

Detect user mode from input text.

**Request:**
```json
{
  "text": "How do I apply for a China visa?",
  "current_mode": "REGULAR"
}
```

**Response:**
```json
{
  "detected_mode": "IMMIGRATION",
  "confidence": 0.88,
  "suggested_switch": true
}
```

---

### POST /mode/set

Explicitly set the user's current mode.

**Request:**
```json
{
  "mode": "TRADER",
  "session_id": "abc123"
}
```

**Response:**
```json
{
  "success": true,
  "mode": "TRADER",
  "previous_mode": "REGULAR"
}
```

**Valid modes:** `REGULAR`, `TRADER`, `TRAVELER`, `IMMIGRATION`

---

### GET /vault/items

Retrieve items from the user's vault.

**Query Parameters:**
- `type` (optional): Filter by item type (e.g., `product`, `evidence`, `document`)
- `limit` (optional): Max items to return (default: 50)
- `offset` (optional): Pagination offset

**Response:**
```json
{
  "items": [
    {
      "id": "item_001",
      "type": "product",
      "data": { "name": "LED Strip", "supplier": "Yiwu Lights Co." },
      "created_at": "2026-01-15T10:30:00Z"
    }
  ],
  "total": 142,
  "limit": 50,
  "offset": 0
}
```

---

### POST /vault/items

Save a new item to the user's vault.

**Request:**
```json
{
  "type": "product",
  "data": {
    "name": "Bluetooth Speaker",
    "url": "https://1688.com/item/12345",
    "price_cny": 45.00
  }
}
```

**Response:**
```json
{
  "success": true,
  "id": "item_002",
  "created_at": "2026-01-31T04:30:00Z"
}
```

---

## Authentication

All requests require:
- `Authorization: Bearer <token>` header
- `X-Client-Role` header (one of: `consumer_app`, `consumer_whatsapp`, `studio_operator`)

The Orchestrator validates the token and enforces permissions based on the declared client role.

---

## Error Codes

| Code               | HTTP Status | Description                           |
|--------------------|-------------|---------------------------------------|
| `TOOL_NOT_FOUND`   | 404         | Requested tool does not exist         |
| `TOOL_NOT_ALLOWED` | 403         | Tool not permitted for client role    |
| `INVALID_MODE`     | 400         | Mode value not in allowed set         |
| `UNAUTHORIZED`     | 401         | Missing or invalid auth token         |
| `VAULT_ERROR`      | 500         | Internal vault storage error          |

---

## SAFE Tool Allowlist

The following 10 tools are permitted for consumer roles (`consumer_app`, `consumer_whatsapp`):

1. `zidni.detect_mode` — Detect appropriate mode from user input
2. `zidni.set_mode` — Switch to a specific mode
3. `zidni.parse_product_link` — Extract product info from URL
4. `zidni.save_to_china_list` — Save product to China shopping list
5. `zidni.draft_supplier_inquiry_zh` — Draft Chinese supplier inquiry
6. `zidni.create_po_skeleton` — Create purchase order skeleton
7. `zidni.save_evidence` — Save receipt/evidence to vault
8. `zidni.translate_text` — Translate text between languages
9. `zidni.summarize_text` — Summarize long text
10. `zidni.get_recent_items` — Retrieve recent vault items

**All other tools are DENIED for consumer roles.**

See `policy/permissions.json` for the complete permission matrix.

---

## Versioning

- Current version: `v1`
- Breaking changes will increment the major version
- Deprecation notices will be provided 90 days in advance

---

*Orchestrator API Contract | ARCH-0 Gate | 2026-01-31*
