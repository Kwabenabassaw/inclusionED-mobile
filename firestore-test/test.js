const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');

async function runTests() {
  const testEnv = await initializeTestEnvironment({
    projectId: 'inclusioned-e0383',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080
    },
  });

  console.log("Environment initialized.");

  const alice = testEnv.authenticatedContext('alice', { email: 'alice@example.com' });
  const unauth = testEnv.unauthenticatedContext();

  try {
    // 1. Unauthenticated users cannot read courses
    console.log("Testing unauthenticated read of courses...");
    await assertFails(unauth.firestore().collection('courses').get());
    console.log("PASS: Unauthenticated users cannot read courses");

    // 2. Authenticated users CAN read courses
    console.log("Testing authenticated read of courses...");
    await assertSucceeds(alice.firestore().collection('courses').get());
    console.log("PASS: Authenticated users CAN read courses");

    // 3. Authenticated users CANNOT write to courses
    console.log("Testing authenticated write to courses...");
    await assertFails(alice.firestore().collection('courses').doc('c1').set({ title: 'Hack' }));
    console.log("PASS: Authenticated users CANNOT write to courses");

    // 4. Users can write their own enrollment
    console.log("Testing create own enrollment...");
    await assertSucceeds(alice.firestore().collection('enrollments').doc('e1').set({ studentId: 'alice' }));
    console.log("PASS: Users can write their own enrollment");

    // 5. Users cannot write someone else's enrollment
    console.log("Testing create someone else's enrollment...");
    await assertFails(alice.firestore().collection('enrollments').doc('e2').set({ studentId: 'bob' }));
    console.log("PASS: Users CANNOT write someone else's enrollment");

    // 6. Users can read their own profile
    console.log("Testing read own profile...");
    await assertSucceeds(alice.firestore().collection('users').doc('alice').get());
    console.log("PASS: Users can read their own profile");

    // 7. Users cannot read someone else's profile
    console.log("Testing read someone else's profile...");
    await assertFails(alice.firestore().collection('users').doc('bob').get());
    console.log("PASS: Users CANNOT read someone else's profile");

    console.log("ALL TESTS PASSED SUCCESSFULLY!");
  } catch (e) {
    console.error("TEST FAILED:", e);
    process.exit(1);
  } finally {
    await testEnv.cleanup();
  }
}

runTests();
