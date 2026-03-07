/**
 * FinMentor AI — Feature 3: BNPL & Loan Risk Explainer
 *
 * Cloud Function: POST /analyzeBNPL
 *
 * Flow:
 *   1. Verify Firebase Auth token (authMiddleware)
 *   2. Check daily rate limit (rateLimiter)
 *   3. Validate request body (validators)
 *   4. Compute financial math instantly — no AI needed for numbers (financeMath)
 *   5. Call Claude for personalized risk explanation (claudeService)
 *   6. Save result to Firestore under user's history (firestoreService)
 *   7. Return math + AI advice to frontend
 *
 * Request body:
 * {
 *   purpose:      string   (e.g. "Samsung phone") — optional
 *   amount:       number   (RM, required)
 *   months:       number   (integer, required)
 *   interestRate: number   (%, optional, default 0)
 *   lateFee:      number   (RM/month, optional, default 0)
 *   lateMonths:   number   (optional, default 0)
 * }
 *
 * Response:
 * {
 *   math:     { monthlyPayment, totalRepayment, totalLateFees, grandTotal, overpaid, overpaidPercent, riskLevel }
 *   aiAdvice: string (Claude's explanation)
 *   savedId:  string (Firestore document ID for history)
 * }
 */

const functions = require("firebase-functions");
const { authMiddleware } = require("../middleware/authMiddleware");
const { rateLimiter } = require("../middleware/rateLimiter");
const { computeBNPL } = require("../utils/financeMath");
const { validateBNPLInput } = require("../utils/validators");
const { bnplPrompt } = require("../utils/prompts");
const { askClaude, ANTHROPIC_KEY } = require("../services/claudeService");
const { saveBNPLCheck } = require("../services/firestoreService");

const analyzeBNPL = functions
  .runWith({ secrets: [ANTHROPIC_KEY] })
  .https.onRequest(async (req, res) => {
    // CORS headers — allow your frontend domain in production
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed." });

    // Step 1: Auth
    await authMiddleware(req, res, async () => {
      const uid = req.user.uid;

      // Step 2: Rate limit
      const allowed = await rateLimiter(uid);
      if (!allowed) {
        return res.status(429).json({
          error: "Daily analysis limit reached (10/day). Try again tomorrow.",
        });
      }

      // Step 3: Validate
      const { valid, error } = validateBNPLInput(req.body);
      if (!valid) return res.status(400).json({ error });

      // Step 4: Math (deterministic, instant)
      let math;
      try {
        math = computeBNPL(req.body);
      } catch (mathError) {
        return res.status(400).json({ error: mathError.message });
      }

      // Step 5: AI explanation
      let aiAdvice;
      try {
        const { system, user } = bnplPrompt(req.body, math);
        aiAdvice = await askClaude(system, user);
      } catch (aiError) {
        console.error("Claude API error:", aiError.message);
        // Graceful degradation: return math without AI if Claude fails
        aiAdvice = "AI analysis temporarily unavailable. Your numbers are shown above.";
      }

      // Step 6: Save to Firestore
      let savedId;
      try {
        savedId = await saveBNPLCheck(uid, {
          ...req.body,
          ...math,
          aiAdvice,
        });
      } catch (dbError) {
        console.error("Firestore save error:", dbError.message);
        // Non-fatal: still return result even if save fails
      }

      // Step 7: Respond
      return res.status(200).json({ math, aiAdvice, savedId });
    });
  });

module.exports = { analyzeBNPL };

