/**
 * Simple test script to verify permission enforcement
 * Run: node test.js
 */

const fs = require('fs');
const path = require('path');

// Load permissions
const permissionsPath = path.join(__dirname, '..', 'policy', 'permissions.json');
const permissions = JSON.parse(fs.readFileSync(permissionsPath, 'utf8'));

function isToolAllowed(toolName, clientRole) {
  const role = permissions.roles[clientRole];
  if (!role) return false;
  if (role.allowed_tools === '*') return true;
  return role.allowed_tools.includes(toolName);
}

console.log('=== Permission Matrix Tests ===\n');

// Test 1: Consumer app can use safe tools
console.log('Test 1: Consumer app + safe tool (zidni.translate_text)');
const test1 = isToolAllowed('zidni.translate_text', 'consumer_app');
console.log(`  Result: ${test1 ? 'ALLOWED ✓' : 'DENIED ✗'}`);
console.log(`  Expected: ALLOWED`);
console.log(`  ${test1 ? 'PASS' : 'FAIL'}\n`);

// Test 2: Consumer app cannot use admin tools
console.log('Test 2: Consumer app + dangerous tool (admin.delete_user)');
const test2 = isToolAllowed('admin.delete_user', 'consumer_app');
console.log(`  Result: ${test2 ? 'ALLOWED ✗' : 'DENIED ✓'}`);
console.log(`  Expected: DENIED`);
console.log(`  ${!test2 ? 'PASS' : 'FAIL'}\n`);

// Test 3: WhatsApp consumer cannot use admin tools
console.log('Test 3: WhatsApp consumer + dangerous tool (admin.export_all_users)');
const test3 = isToolAllowed('admin.export_all_users', 'consumer_whatsapp');
console.log(`  Result: ${test3 ? 'ALLOWED ✗' : 'DENIED ✓'}`);
console.log(`  Expected: DENIED`);
console.log(`  ${!test3 ? 'PASS' : 'FAIL'}\n`);

// Test 4: Studio operator can use any tool
console.log('Test 4: Studio operator + dangerous tool (admin.delete_user)');
const test4 = isToolAllowed('admin.delete_user', 'studio_operator');
console.log(`  Result: ${test4 ? 'ALLOWED ✓' : 'DENIED ✗'}`);
console.log(`  Expected: ALLOWED`);
console.log(`  ${test4 ? 'PASS' : 'FAIL'}\n`);

// Test 5: All safe tools accessible to consumer
console.log('Test 5: All safe tools accessible to consumer_app');
const safeTools = permissions.safe_tools.list.map(t => t.name);
const allSafeAllowed = safeTools.every(tool => isToolAllowed(tool, 'consumer_app'));
console.log(`  Safe tools count: ${safeTools.length}`);
console.log(`  All allowed: ${allSafeAllowed ? 'YES ✓' : 'NO ✗'}`);
console.log(`  ${allSafeAllowed ? 'PASS' : 'FAIL'}\n`);

// Summary
console.log('=== Summary ===');
const allPassed = test1 && !test2 && !test3 && test4 && allSafeAllowed;
console.log(`All tests: ${allPassed ? 'PASSED ✓' : 'FAILED ✗'}`);

process.exit(allPassed ? 0 : 1);
