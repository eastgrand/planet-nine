#!/usr/bin/env node

/**
 * Simple test script for Planet Nine base
 * Tests Fount user creation with proper Sessionless authentication
 */

import sessionless from 'sessionless-node';

// Change this if using different ports
const FOUNT_URL = process.env.FOUNT_URL || 'http://localhost:6006';

let keys = {};
let keysToReturn = {};

async function testFount() {
  console.log('🔑 Generating Sessionless keypair...');

  keys = await sessionless.generateKeys(
    (k) => { keysToReturn = k; },
    () => { return keysToReturn; }
  );

  console.log('   Public Key:', keys.pubKey);
  console.log('   Private Key:', keys.privateKey.substring(0, 20) + '...');

  console.log('\n📤 Creating user in Fount...');

  const payload = {
    timestamp: new Date().getTime() + '',
    pubKey: keys.pubKey,
  };

  // Sign the message (timestamp + pubKey)
  payload.signature = await sessionless.sign(payload.timestamp + payload.pubKey);

  console.log('   Payload:', JSON.stringify(payload, null, 2));

  const response = await fetch(`${FOUNT_URL}/user/create`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  const result = await response.json();

  if (result.uuid) {
    console.log('\n✅ User created successfully!');
    console.log('   UUID:', result.uuid);
    console.log('   MP:', result.mp);
    console.log('   Experience:', result.experience);
    return result;
  } else {
    console.log('\n❌ Error:', result);
    return null;
  }
}

async function main() {
  console.log('='.repeat(50));
  console.log('Planet Nine Base Test');
  console.log('Fount URL:', FOUNT_URL);
  console.log('='.repeat(50));
  console.log('');

  try {
    const user = await testFount();

    if (user) {
      console.log('\n🎉 Your Planet Nine base is working!');
      console.log('\nYour user credentials (save these):');
      console.log('  UUID:', user.uuid);
      console.log('  Public Key:', user.pubKey);
      console.log('  Private Key:', keys.privateKey);
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.log('\nMake sure the container is running:');
    console.log('  docker ps | grep planet-nine-base');
  }
}

main();
