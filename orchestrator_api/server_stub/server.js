/**
 * Orchestrator API Stub Server
 *
 * Minimal reference implementation proving the permission model is executable.
 * This validates tool names against the allowlist from permissions.json.
 *
 * NOT for production use - stub only returns placeholder responses.
 */

const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());

// Load permissions at startup
const permissionsPath = path.join(__dirname, '..', 'policy', 'permissions.json');
const permissions = JSON.parse(fs.readFileSync(permissionsPath, 'utf8'));

/**
 * Check if a tool is allowed for a given client role
 */
function isToolAllowed(toolName, clientRole) {
  const role = permissions.roles[clientRole];
  if (!role) {
    return { allowed: false, reason: 'UNKNOWN_ROLE' };
  }

  // Studio operator has full access
  if (role.allowed_tools === '*') {
    return { allowed: true };
  }

  // Check allowlist for consumer roles
  if (role.allowed_tools.includes(toolName)) {
    return { allowed: true };
  }

  return { allowed: false, reason: 'TOOL_NOT_ALLOWED' };
}

/**
 * Get safe tools list
 */
function getSafeTools() {
  return permissions.safe_tools.list.map(t => t.name);
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', version: '0.1.0-stub' });
});

// POST /tools/invoke - Invoke a tool
app.post('/orchestrator/v1/tools/invoke', (req, res) => {
  const { tool, params, client_role, session_id } = req.body;

  if (!tool) {
    return res.status(400).json({
      success: false,
      error: 'MISSING_TOOL',
      message: 'Tool name is required'
    });
  }

  if (!client_role) {
    return res.status(400).json({
      success: false,
      error: 'MISSING_ROLE',
      message: 'Client role is required'
    });
  }

  // Check if tool exists in our known tools
  const safeTools = getSafeTools();
  const knownTools = [
    ...safeTools,
    ...permissions.dangerous_tools.list.map(t => t.name)
  ];

  // For stub: only check against known tools
  const isKnown = knownTools.includes(tool) || tool.startsWith('zidni.') || tool.startsWith('admin.') || tool.startsWith('batch.') || tool.startsWith('system.') || tool.startsWith('prompt.');

  if (!isKnown) {
    return res.status(404).json({
      success: false,
      error: 'TOOL_NOT_FOUND',
      message: `Unknown tool: '${tool}'`
    });
  }

  // Check permission
  const check = isToolAllowed(tool, client_role);
  if (!check.allowed) {
    return res.status(403).json({
      success: false,
      error: check.reason,
      message: `Tool '${tool}' is not permitted for role '${client_role}'`
    });
  }

  // Return placeholder response (stub implementation)
  res.json({
    success: true,
    stub: true,
    result: {
      message: `Tool '${tool}' executed successfully (stub response)`,
      params_received: params || {}
    }
  });
});

// POST /mode/detect - Detect mode from text
app.post('/orchestrator/v1/mode/detect', (req, res) => {
  const { text, current_mode } = req.body;

  // Stub: simple keyword detection
  let detected = 'REGULAR';
  let confidence = 0.5;

  if (text) {
    const lowerText = text.toLowerCase();
    if (lowerText.includes('supplier') || lowerText.includes('yiwu') || lowerText.includes('1688') || lowerText.includes('import')) {
      detected = 'TRADER';
      confidence = 0.85;
    } else if (lowerText.includes('visa') || lowerText.includes('immigration') || lowerText.includes('passport')) {
      detected = 'IMMIGRATION';
      confidence = 0.88;
    } else if (lowerText.includes('travel') || lowerText.includes('flight') || lowerText.includes('hotel')) {
      detected = 'TRAVELER';
      confidence = 0.82;
    }
  }

  res.json({
    detected_mode: detected,
    confidence,
    suggested_switch: detected !== current_mode
  });
});

// POST /mode/set - Set mode explicitly
app.post('/orchestrator/v1/mode/set', (req, res) => {
  const { mode, session_id } = req.body;
  const validModes = ['REGULAR', 'TRADER', 'TRAVELER', 'IMMIGRATION'];

  if (!validModes.includes(mode)) {
    return res.status(400).json({
      success: false,
      error: 'INVALID_MODE',
      message: `Mode must be one of: ${validModes.join(', ')}`
    });
  }

  res.json({
    success: true,
    mode,
    previous_mode: 'REGULAR' // stub
  });
});

// GET /vault/items - Get vault items
app.get('/orchestrator/v1/vault/items', (req, res) => {
  res.json({
    items: [
      {
        id: 'stub_item_001',
        type: 'product',
        data: { name: 'Sample Product (stub)' },
        created_at: new Date().toISOString()
      }
    ],
    total: 1,
    limit: 50,
    offset: 0,
    stub: true
  });
});

// POST /vault/items - Save vault item
app.post('/orchestrator/v1/vault/items', (req, res) => {
  const { type, data } = req.body;

  res.json({
    success: true,
    id: `stub_item_${Date.now()}`,
    created_at: new Date().toISOString(),
    stub: true
  });
});

// Start server
const PORT = process.env.PORT || 3100;
app.listen(PORT, () => {
  console.log(`Orchestrator stub server running on port ${PORT}`);
  console.log(`Safe tools loaded: ${getSafeTools().length}`);
  console.log(`Roles defined: ${Object.keys(permissions.roles).join(', ')}`);
});

module.exports = app;
