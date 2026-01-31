/**
 * Permission enforcement tests
 * Run: node test.js
 *
 * Tests cover:
 * - Basic permission matrix (consumer vs operator)
 * - Role escalation prevention (X-Client-Role without stub secret)
 * - Proper 404 vs 403 response codes
 */

const fs = require('fs');
const path = require('path');

// Load permissions
const permissionsPath = path.join(__dirname, '..', 'policy', 'permissions.json');
const permissions = JSON.parse(fs.readFileSync(permissionsPath, 'utf8'));

const STUB_SECRET = 'test-stub-secret-do-not-use-in-prod';

function isToolAllowed(toolName, clientRole) {
  const role = permissions.roles[clientRole];
  if (!role) return false;
  if (role.allowed_tools === '*') return true;
  return role.allowed_tools.includes(toolName);
}

function isConsumerRole(clientRole) {
  return clientRole === 'consumer_app' || clientRole === 'consumer_whatsapp';
}

/**
 * Simulate deriveClientRole from server.js
 */
function deriveClientRole(headers) {
  const stubSecret = headers['X-Stub-Secret'];
  const requestedRole = headers['X-Client-Role'];

  if (stubSecret === STUB_SECRET && requestedRole) {
    if (permissions.roles[requestedRole]) {
      return requestedRole;
    }
  }

  return 'consumer_app';
}

/**
 * Simulate the expected HTTP status for a tool call
 */
function expectedStatus(toolName, clientRole) {
  const allowed = isToolAllowed(toolName, clientRole);
  if (allowed) return 200;

  // Consumer gets 404 (tool hidden), operator gets 403 (explicit deny)
  return isConsumerRole(clientRole) ? 404 : 403;
}

let passed = 0;
let failed = 0;

function test(name, condition) {
  if (condition) {
    console.log(`  ✓ ${name}`);
    passed++;
  } else {
    console.log(`  ✗ ${name}`);
    failed++;
  }
}

console.log('=== Permission Matrix Tests ===\n');

// Test Group 1: Basic Permissions
console.log('Group 1: Basic Permission Checks');
test('Consumer app can use safe tool (zidni.translate_text)',
  isToolAllowed('zidni.translate_text', 'consumer_app') === true);

test('Consumer app CANNOT use dangerous tool (admin.delete_user)',
  isToolAllowed('admin.delete_user', 'consumer_app') === false);

test('WhatsApp consumer CANNOT use dangerous tool (admin.export_all_users)',
  isToolAllowed('admin.export_all_users', 'consumer_whatsapp') === false);

test('Studio operator CAN use dangerous tool (admin.delete_user)',
  isToolAllowed('admin.delete_user', 'studio_operator') === true);

test('All 10 safe tools accessible to consumer_app',
  permissions.safe_tools.list.every(t => isToolAllowed(t.name, 'consumer_app')));

console.log('');

// Test Group 2: Role Derivation (Escalation Prevention)
console.log('Group 2: Role Escalation Prevention');

test('No headers => consumer_app',
  deriveClientRole({}) === 'consumer_app');

test('X-Client-Role alone (no secret) => consumer_app (blocked escalation)',
  deriveClientRole({ 'X-Client-Role': 'studio_operator' }) === 'consumer_app');

test('Wrong X-Stub-Secret + X-Client-Role => consumer_app (blocked escalation)',
  deriveClientRole({ 'X-Stub-Secret': 'wrong-secret', 'X-Client-Role': 'studio_operator' }) === 'consumer_app');

test('Valid X-Stub-Secret + X-Client-Role => studio_operator (allowed)',
  deriveClientRole({ 'X-Stub-Secret': STUB_SECRET, 'X-Client-Role': 'studio_operator' }) === 'studio_operator');

test('Valid secret + invalid role => consumer_app (fallback)',
  deriveClientRole({ 'X-Stub-Secret': STUB_SECRET, 'X-Client-Role': 'super_admin' }) === 'consumer_app');

console.log('');

// Test Group 3: HTTP Status Codes
console.log('Group 3: HTTP Status Codes');

test('Consumer + safe tool => 200',
  expectedStatus('zidni.translate_text', 'consumer_app') === 200);

test('Consumer + dangerous tool => 404 (hidden)',
  expectedStatus('admin.delete_user', 'consumer_app') === 404);

test('Operator + safe tool => 200',
  expectedStatus('zidni.translate_text', 'studio_operator') === 200);

test('Operator + dangerous tool => 200 (allowed)',
  expectedStatus('admin.delete_user', 'studio_operator') === 200);

console.log('');

// Test Group 4: Escalation Attack Simulation
console.log('Group 4: Escalation Attack Simulation');

// Simulate: attacker sends X-Client-Role: studio_operator without secret
const attackerHeaders = { 'X-Client-Role': 'studio_operator' };
const attackerRole = deriveClientRole(attackerHeaders);
const attackerCanUseAdminTool = isToolAllowed('admin.delete_user', attackerRole);

test('Attacker with X-Client-Role header (no secret) is treated as consumer',
  attackerRole === 'consumer_app');

test('Attacker CANNOT access admin tools via header injection',
  attackerCanUseAdminTool === false);

test('Attacker receives 404 (not 403) - tool appears non-existent',
  expectedStatus('admin.delete_user', attackerRole) === 404);

console.log('');

// Test Group 5: Legitimate Operator Testing
console.log('Group 5: Legitimate Operator Testing');

const operatorHeaders = { 'X-Stub-Secret': STUB_SECRET, 'X-Client-Role': 'studio_operator' };
const operatorRole = deriveClientRole(operatorHeaders);
const operatorCanUseAdminTool = isToolAllowed('admin.delete_user', operatorRole);

test('Operator with valid secret + role header is treated as studio_operator',
  operatorRole === 'studio_operator');

test('Operator CAN access admin tools',
  operatorCanUseAdminTool === true);

test('Operator receives 200 for admin tools',
  expectedStatus('admin.delete_user', operatorRole) === 200);

console.log('');

// Summary
console.log('=== Summary ===');
console.log(`Passed: ${passed}`);
console.log(`Failed: ${failed}`);
console.log(`Total:  ${passed + failed}`);
console.log(`Result: ${failed === 0 ? 'ALL TESTS PASSED ✓' : 'SOME TESTS FAILED ✗'}`);

process.exit(failed === 0 ? 0 : 1);
