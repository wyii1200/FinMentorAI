/**
 * FinMentor AI — Auth Middleware
 *
 * WHY: Every Cloud Function endpoint must be protected.
 * This middleware verifies the Firebase ID token sent by the frontend
 * in the Authorization header. If invalid or missing, it rejects immediately.
 * On success, it attaches req.user (contains uid, email, etc.) for downstream use.
 *
 * Usage:
 *   await authMiddleware(req, res, async () => { ... your handler ... });
 */

const admin = require("firebase-admin");

async function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing or malformed Authorization header." });
  }

  const idToken = authHeader.split("Bearer ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken; // { uid, email, name, ... }
    return next();
  } catch (error) {
    console.error("Token verification failed:", error.message);
    return res.status(401).json({ error: "Invalid or expired token." });
  }
}

module.exports = { authMiddleware };

