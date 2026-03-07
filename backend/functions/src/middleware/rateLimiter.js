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

const DAILY_LIMIT = 10;

async function rateLimiter(uid) {
  // Key resets naturally each day because the date is part of the document ID
  const today = new Date().toISOString().split("T")[0]; // "YYYY-MM-DD"
  const ref = admin.firestore()
    .collection("rateLimits")
    .doc(`${uid}_${today}`);

  return admin.firestore().runTransaction(async (transaction) => {
    const doc = await transaction.get(ref);
    const currentCount = doc.exists ? doc.data().count : 0;

    if (currentCount >= DAILY_LIMIT) {
      return false; // blocked
    }

    transaction.set(
      ref,
      {
        uid,
        date: today,
        count: currentCount + 1,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return true; // allowed
  });
}

module.exports = { rateLimiter };

