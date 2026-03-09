/**
 * FinMentor AI — Rate Limiter
 *
 * WHY: The Anthropic API costs money per call.
 * Without a limit, a single user could spam requests and run up your bill.
 * This middleware allows max 10 AI-powered analyses per user per day.
 * It uses a Firestore document keyed by uid + date that auto-resets each day.
 *
 * Usage:
 *   const allowed = await rateLimiter(uid);
 *   if (!allowed) return res.status(429).json({ error: "Daily limit reached." });
 */

const admin = require("firebase-admin");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");  // ADD THIS

const DAILY_LIMIT = 10;

async function rateLimiter(uid) {
  const today = new Date().toISOString().split("T")[0];
  const db = getFirestore();                                               // CHANGE THIS
  const ref = db.collection("rateLimits").doc(`${uid}_${today}`);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(ref);
    const currentCount = doc.exists ? doc.data().count : 0;

    if (currentCount >= DAILY_LIMIT) {
      return false;
    }

    transaction.set(ref, {
      uid,
      date: today,
      count: currentCount + 1,
      updatedAt: FieldValue.serverTimestamp(),                             // CHANGE THIS
    }, { merge: true });

    return true;
  });
}

module.exports = { rateLimiter };

