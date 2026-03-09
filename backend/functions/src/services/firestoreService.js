/**
 * FinMentor AI — Firestore Service
 *
 * WHY: Handlers should not contain raw Firestore queries.
 * This service layer keeps DB logic in one place, making it easy
 * to change collection names, add validation, or swap databases later.
 *
 * Schema:
 *   /users/{uid}/bnpl_checks/{checkId}   — Feature 3 history
 *   /users/{uid}/resilience/{snapId}     — Feature 4 history
 *   /rateLimits/{uid_date}               — Rate limiter counters
 */

const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const admin = require("firebase-admin");

const db = () => getFirestore();
const timestamp = () => FieldValue.serverTimestamp();

//analyze Spending (Feature 1)
const saveSpendingAnalysis = async (userId, analysisResult) => {
  await db().collection('users').doc(userId)
    .collection('spendingAnalyses')
    .add({
      ...analysisResult,
      createdAt: new Date(),
    });
};

//future simulator (Feature 2)
const saveSimulation = async (userId, simulationResult) => {
  const ref = await db()
    .collection('users')
    .doc(userId)
    .collection('simulations')
    .add({
      ...simulationResult,
      createdAt: new Date(),
    });
  return ref.id;
};

/**
 * Save a BNPL risk check result for a user.
 * @param {string} uid
 * @param {object} data - combined input + math + aiAdvice
 * @returns {Promise<string>} the new document ID
 */
async function saveBNPLCheck(uid, data) {
  const ref = await db()
    .collection("users")
    .doc(uid)
    .collection("bnpl_checks")
    .add({
      ...data,
      createdAt: timestamp(),
    });
  return ref.id;
}

/**
 * Save a resilience score snapshot for a user.
 * @param {string} uid
 * @param {object} data - combined input + math + aiPlan
 * @returns {Promise<string>} the new document ID
 */
async function saveResilienceSnap(uid, data) {
  const ref = await db()
    .collection("users")
    .doc(uid)
    .collection("resilience")
    .add({
      ...data,
      createdAt: timestamp(),
    });
  return ref.id;
}

/**
 * Get the last N BNPL checks for a user (for history view).
 * @param {string} uid
 * @param {number} limit
 * @returns {Promise<Array>}
 */
async function getBNPLHistory(uid, limit = 10) {
  const snap = await db()
    .collection("users")
    .doc(uid)
    .collection("bnpl_checks")
    .orderBy("createdAt", "desc")
    .limit(limit)
    .get();

  return snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

/**
 * Get the last N resilience snapshots for a user (for trend chart).
 * @param {string} uid
 * @param {number} limit
 * @returns {Promise<Array>}
 */
async function getResilienceHistory(uid, limit = 10) {
  const snap = await db()
    .collection("users")
    .doc(uid)
    .collection("resilience")
    .orderBy("createdAt", "desc")
    .limit(limit)
    .get();

  return snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

/**
 * Save or update user profile.
 * @param {string} uid
 * @param {object} profile - { income, age, occupation, location }
 */
async function saveProfile(uid, profile) {
  await db()
    .collection("users")
    .doc(uid)
    .set(
      {
        ...profile,
        updatedAt: timestamp(),
      },
      { merge: true }
    );
}

module.exports = {
  saveSpendingAnalysis ,
  saveBNPLCheck,
  saveResilienceSnap,
  saveSimulation,
  getBNPLHistory,
  getResilienceHistory,
  saveProfile,
};

