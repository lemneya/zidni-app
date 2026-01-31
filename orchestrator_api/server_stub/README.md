# Orchestrator Stub Server

Minimal reference implementation proving the permission model is executable.

## Purpose

This stub validates that:
1. Tools are checked against the allowlist in `policy/permissions.json`
2. Consumer roles are denied access to dangerous tools (receive 404)
3. Studio operators have full access (denied tools receive 403)
4. Role escalation is prevented without stub secret

## Role Enforcement

**Security model:**
- Default role is `consumer_app` (safest default)
- Role CANNOT be escalated by simply sending `X-Client-Role` header
- To override role for testing: provide BOTH `X-Stub-Secret` AND `X-Client-Role` headers
- This mirrors production where role is derived server-side from authenticated identity

## Usage

```bash
# Install dependencies
npm install

# Run the server
npm start
# Server runs on http://localhost:3100

# Run permission tests
npm test

# Run with custom stub secret
STUB_SECRET=my-secret npm start
```

## Testing the API

### Health Check
```bash
curl http://localhost:3100/health
```

### Default Consumer Call (no role header needed)
Consumer role is applied automatically. Dangerous tools appear as "not found":

```bash
# Consumer invoking safe tool (succeeds)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{"tool":"zidni.translate_text"}'

# Consumer invoking dangerous tool (returns 404, not 403)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{"tool":"admin.delete_user"}'
```

### Escalation Attempt (blocked)
Sending `X-Client-Role` without stub secret has NO effect:

```bash
# This still behaves as consumer_app (returns 404 for admin tool)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -H "X-Client-Role: studio_operator" \
  -d '{"tool":"admin.delete_user"}'
```

### Operator Test Call (requires stub secret)
To test operator flows, provide BOTH headers:

```bash
# Operator invoking dangerous tool (succeeds with stub secret)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -H "X-Stub-Secret: test-stub-secret-do-not-use-in-prod" \
  -H "X-Client-Role: studio_operator" \
  -d '{"tool":"admin.delete_user"}'
```

### Missing Authorization (returns 401)
```bash
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -d '{"tool":"zidni.translate_text"}'
```

## Note

This is a stub implementation for contract validation only. Production implementation will include:
- Actual tool execution
- JWT validation and role derivation from token claims
- Vault persistence
- Audit logging
