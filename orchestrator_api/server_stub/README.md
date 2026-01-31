# Orchestrator Stub Server

Minimal reference implementation proving the permission model is executable.

## Purpose

This stub validates that:
1. Tools are checked against the allowlist in `policy/permissions.json`
2. Consumer roles are denied access to dangerous tools
3. Studio operators have full access

## Usage

```bash
# Install dependencies
npm install

# Run the server
npm start
# Server runs on http://localhost:3100

# Run permission tests
npm test
```

## Testing the API

```bash
# Health check
curl http://localhost:3100/health

# Consumer invoking safe tool (should succeed)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -d '{"tool":"zidni.translate_text","client_role":"consumer_app"}'

# Consumer invoking dangerous tool (should fail with 403)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -d '{"tool":"admin.delete_user","client_role":"consumer_app"}'

# Operator invoking dangerous tool (should succeed)
curl -X POST http://localhost:3100/orchestrator/v1/tools/invoke \
  -H "Content-Type: application/json" \
  -d '{"tool":"admin.delete_user","client_role":"studio_operator"}'
```

## Note

This is a stub implementation for contract validation only. Production implementation will include:
- Actual tool execution
- Authentication/authorization
- Vault persistence
- Audit logging
