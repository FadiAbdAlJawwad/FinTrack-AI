// Firestore security rules tests. Runs only against the local emulator with
// the demo project id `demo-fintrack-rules-test` (see package.json).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-fintrack-rules-test';
let env;

const validTx = (id = 'tx1') => ({
  id,
  amountMinor: 1234,
  currency: 'USD',
  type: 'expense',
  category: 'food',
  title: 'Lunch',
  date: '2026-10-03T12:30:00.000',
  walletId: 'cash',
});

const validWallet = (id = 'cash') => ({
  id,
  name: 'Cash',
  icon: 'payments',
  isDefault: true,
});

const validUserDoc = (uid = 'alice') => ({
  fullName: 'Alice',
  email: 'alice@example.com',
  createdAt: serverTimestamp(),
  uid,
});

const asAlice = () => env.authenticatedContext('alice').firestore();
const txRef = (db, id = 'tx1', uid = 'alice') =>
  doc(db, `users/${uid}/transactions/${id}`);

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

beforeEach(async () => env.clearFirestore());
after(async () => env.cleanup());

describe('transactions', () => {
  test('owner can create a valid transaction', async () => {
    await assertSucceeds(setDoc(txRef(asAlice()), validTx()));
  });

  test('owner can update a valid transaction (full map, like the app)', async () => {
    const db = asAlice();
    await assertSucceeds(setDoc(txRef(db), validTx()));
    await assertSucceeds(updateDoc(txRef(db), { ...validTx(), amountMinor: 999 }));
  });

  test('JOD with three-decimal minor units is allowed', async () => {
    await assertSucceeds(
      setDoc(txRef(asAlice()), { ...validTx(), currency: 'JOD', amountMinor: 1005 }),
    );
  });

  test('another user is denied', async () => {
    const bob = env.authenticatedContext('bob').firestore();
    await assertFails(setDoc(txRef(bob), validTx()));
  });

  test('another user cannot read', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(txRef(ctx.firestore()), validTx());
    });
    const bob = env.authenticatedContext('bob').firestore();
    await assertFails(getDoc(txRef(bob)));
  });

  test('unauthenticated is denied', async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(setDoc(txRef(anon), validTx()));
  });

  test('zero amount is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), amountMinor: 0 }));
  });

  test('negative amount is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), amountMinor: -5 }));
  });

  test('amount above the cap is denied', async () => {
    await assertFails(
      setDoc(txRef(asAlice()), { ...validTx(), amountMinor: 1000000000001 }),
    );
  });

  test('amountMinor as a double is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), amountMinor: 12.5 }));
  });

  test('unknown currency is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), currency: 'EUR' }));
  });

  test('unknown type is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), type: 'transfer' }));
  });

  test('unknown category is denied', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), category: 'crypto' }));
  });

  test('extra field is denied (including the legacy amount)', async () => {
    await assertFails(setDoc(txRef(asAlice()), { ...validTx(), amount: 12.34 }));
  });

  test('missing field is denied', async () => {
    const { walletId, ...withoutWallet } = validTx();
    await assertFails(setDoc(txRef(asAlice()), withoutWallet));
  });

  test('id different from the document id is denied', async () => {
    await assertFails(setDoc(txRef(asAlice(), 'tx1'), validTx('other')));
  });

  test('title longer than 500 characters is denied', async () => {
    await assertFails(
      setDoc(txRef(asAlice()), { ...validTx(), title: 'x'.repeat(501) }),
    );
  });

  test('owner can delete', async () => {
    const db = asAlice();
    await assertSucceeds(setDoc(txRef(db), validTx()));
    await assertSucceeds(deleteDoc(txRef(db)));
  });

  test("alice cannot delete bob's transaction", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(txRef(ctx.firestore(), 'tx1', 'bob'), validTx('tx1'));
    });
    await assertFails(deleteDoc(txRef(asAlice(), 'tx1', 'bob')));
  });

  test("alice list query of bob's transactions is denied", async () => {
    await assertFails(getDocs(collection(asAlice(), 'users/bob/transactions')));
  });

  test('transaction update changing type to invalid value is denied', async () => {
    const db = asAlice();
    await assertSucceeds(setDoc(txRef(db), validTx()));
    await assertFails(updateDoc(txRef(db), { type: 'invalid' }));
  });

  test('transaction create with non-string title is denied', async () => {
    await assertFails(
      setDoc(txRef(asAlice()), { ...validTx(), title: 12345 }),
    );
  });

  test('transaction create with non-string date is denied', async () => {
    await assertFails(
      setDoc(txRef(asAlice()), { ...validTx(), date: 20261003 }),
    );
  });
});

describe('wallets', () => {
  const walletRef = (db, id = 'cash') => doc(db, `users/alice/wallets/${id}`);

  test('valid wallet is allowed', async () => {
    await assertSucceeds(setDoc(walletRef(asAlice()), validWallet()));
  });

  test('valid wallet with cash type is allowed', async () => {
    await assertSucceeds(setDoc(walletRef(asAlice(), 'cash_type'), { ...validWallet('cash_type'), type: 'cash' }));
  });

  test('valid wallet with bank type is allowed', async () => {
    await assertSucceeds(setDoc(walletRef(asAlice(), 'bank_type'), { ...validWallet('bank_type'), type: 'bank' }));
  });

  test('valid wallet with eWallet type is allowed', async () => {
    await assertSucceeds(setDoc(walletRef(asAlice(), 'ewallet_type'), { ...validWallet('ewallet_type'), type: 'eWallet' }));
  });

  test('wallet with type crypto is denied', async () => {
    await assertFails(setDoc(walletRef(asAlice(), 'crypto_type'), { ...validWallet('crypto_type'), type: 'crypto' }));
  });

  test('wallet with non-string type is denied', async () => {
    await assertFails(setDoc(walletRef(asAlice(), 'non_string_type'), { ...validWallet('non_string_type'), type: 123 }));
  });

  test('wallet with an empty name is denied', async () => {
    await assertFails(setDoc(walletRef(asAlice()), { ...validWallet(), name: '' }));
  });

  test('wallet with a non-bool isDefault is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), isDefault: 'yes' }),
    );
  });

  test('wallet with an extra field is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), balance: 10 }),
    );
  });

  test('wallet id different from the document id is denied', async () => {
    await assertFails(setDoc(walletRef(asAlice(), 'cash'), validWallet('bank')));
  });

  test("alice cannot read bob's wallet", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/bob/wallets/cash'), validWallet('cash'));
    });
    await assertFails(getDoc(doc(asAlice(), 'users/bob/wallets/cash')));
  });

  test("alice cannot write bob's wallet", async () => {
    await assertFails(
      setDoc(doc(asAlice(), 'users/bob/wallets/cash'), validWallet('cash')),
    );
  });

  test("alice cannot delete bob's wallet", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/bob/wallets/cash'), validWallet('cash'));
    });
    await assertFails(deleteDoc(doc(asAlice(), 'users/bob/wallets/cash')));
  });

  test('unauthenticated list of wallets is denied', async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDocs(collection(anon, 'users/alice/wallets')));
  });

  test('wallet name longer than 50 characters is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), name: 'a'.repeat(51) }),
    );
  });

  test('wallet icon longer than 40 characters is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), icon: 'a'.repeat(41) }),
    );
  });

  test('wallet empty icon is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), icon: '' }),
    );
  });

  test('wallet non-string icon is denied', async () => {
    await assertFails(
      setDoc(walletRef(asAlice()), { ...validWallet(), icon: 12345 }),
    );
  });

  test('wallet update changing id is denied', async () => {
    const db = asAlice();
    await assertSucceeds(setDoc(walletRef(db, 'cash'), validWallet('cash')));
    await assertFails(updateDoc(walletRef(db, 'cash'), { id: 'other' }));
  });
});

describe('users', () => {
  const userRef = (db, uid = 'alice') => doc(db, `users/${uid}`);

  test('unauthenticated user cannot read user doc', async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(userRef(anon, 'alice')));
  });

  test("alice cannot read bob's user doc", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(userRef(ctx.firestore(), 'bob'), validUserDoc('bob'));
    });
    await assertFails(getDoc(userRef(asAlice(), 'bob')));
  });

  test("alice cannot write bob's user doc", async () => {
    await assertFails(
      setDoc(userRef(asAlice(), 'bob'), validUserDoc('bob')),
    );
  });

  test('user create with an extra field is denied', async () => {
    await assertFails(
      setDoc(userRef(asAlice()), { ...validUserDoc('alice'), extraField: true }),
    );
  });

  test('user create with uid != userId is denied', async () => {
    await assertFails(
      setDoc(userRef(asAlice()), validUserDoc('bob')),
    );
  });

  test('user create with fullName longer than 100 is denied', async () => {
    await assertFails(
      setDoc(userRef(asAlice()), { ...validUserDoc('alice'), fullName: 'a'.repeat(101) }),
    );
  });

  test('user create with non-string fullName is denied', async () => {
    await assertFails(
      setDoc(userRef(asAlice()), { ...validUserDoc('alice'), fullName: 12345 }),
    );
  });

  test('user create missing createdAt is denied', async () => {
    const { createdAt, ...withoutCreatedAt } = validUserDoc('alice');
    await assertFails(setDoc(userRef(asAlice()), withoutCreatedAt));
  });

  test('email sign-up document (no baseCurrency) is allowed', async () => {
    await assertSucceeds(
      setDoc(userRef(asAlice()), {
        fullName: 'Alice',
        email: 'alice@example.com',
        createdAt: serverTimestamp(),
        uid: 'alice',
      }),
    );
  });

  test('Google sign-in document is allowed', async () => {
    await assertSucceeds(
      setDoc(userRef(asAlice()), {
        fullName: 'Alice',
        email: 'alice@example.com',
        createdAt: serverTimestamp(),
        photoUrl: null,
        uid: 'alice',
        baseCurrency: 'USD',
      }),
    );
  });

  test('valid Google-shaped create with null email and photoUrl is allowed', async () => {
    await assertSucceeds(
      setDoc(userRef(asAlice()), {
        fullName: 'Alice',
        email: null,
        createdAt: serverTimestamp(),
        photoUrl: null,
        uid: 'alice',
        baseCurrency: 'USD',
      }),
    );
  });

  test('merge-style update of baseCurrency to JOD is allowed', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(userRef(ctx.firestore()), validUserDoc('alice'));
    });
    await assertSucceeds(
      setDoc(userRef(asAlice()), { baseCurrency: 'JOD' }, { merge: true }),
    );
  });

  test('baseCurrency USD is allowed (merge write, like the app)', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(userRef(ctx.firestore()), validUserDoc('alice'));
    });
    await assertSucceeds(
      setDoc(userRef(asAlice()), { baseCurrency: 'USD' }, { merge: true }),
    );
  });

  test('user update changing createdAt is denied', async () => {
    const initialTime = Timestamp.fromDate(new Date('2026-01-01T00:00:00Z'));
    const newTime = Timestamp.fromDate(new Date('2026-02-01T00:00:00Z'));
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(userRef(ctx.firestore()), {
        ...validUserDoc('alice'),
        createdAt: initialTime,
      });
    });
    await assertFails(
      updateDoc(userRef(asAlice()), { createdAt: newTime }),
    );
  });

  test('baseCurrency EUR is denied', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(userRef(ctx.firestore()), validUserDoc('alice'));
    });
    await assertFails(
      setDoc(userRef(asAlice()), { baseCurrency: 'EUR' }, { merge: true }),
    );
  });

  test('another user cannot write the user document', async () => {
    const bob = env.authenticatedContext('bob').firestore();
    await assertFails(setDoc(userRef(bob, 'alice'), validUserDoc('alice')));
  });

  test('client delete of the user document is denied', async () => {
    const db = asAlice();
    await assertSucceeds(setDoc(userRef(db), validUserDoc('alice')));
    await assertFails(deleteDoc(userRef(db)));
  });
});

describe('default deny', () => {
  test('unknown top-level collection is denied', async () => {
    await assertFails(setDoc(doc(asAlice(), 'other/x'), { a: 1 }));
  });

  test('unknown user subcollection is denied', async () => {
    await assertFails(setDoc(doc(asAlice(), 'users/alice/secrets/x'), { a: 1 }));
  });
});
