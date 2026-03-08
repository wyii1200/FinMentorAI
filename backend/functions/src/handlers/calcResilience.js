/**
 * FinMentor AI — Feature 4: Financial Resilience Score
 *
 * Cloud Function: POST /calcResilience
 *
 * Flow:
 *   1. Verify Firebase Auth token (authMiddleware)
 *   2. Check daily rate limit (rateLimiter)
 *   3. Validate request body (validators)
 *   4. Compute resilience score — no AI needed for the number (financeMath)
 *   5. Call Claude for personalized action plan (claudeService)
 *   6. Save snapshot to Firestore for trend tracking (firestoreService)
 *   7. Return score + AI plan to frontend
 *
 * Request body:
 * {
 *   income:     number   (RM/month, optional but improves AI advice)
 *   savings:    number   (RM total, required)
 *   fixedExp:   number   (RM/month, required)
 *   varExp:     number   (RM/month, optional, default 0)
 *   insurance:  number   (RM coverage, optional, default 0)
 *   bnplDebt:   number   (RM total outstanding, optional, default 0)
 *   dependents: number   (count, optional, default 0)
 * }
 *
 * Response:
 * {
 *   math:    { monthlyBurn, netAssets, scoreMonths, level, targetMonths, savingsGap, monthsToTarget }
 *   aiPlan:  string (Claude's personalized action plan)
 *   savedId: string (Firestore document ID)
 * }
 */

const functions = require("firebase-functions");
const { authMiddleware } = require("../middleware/authMiddleware");
const { rateLimiter } = require("../middleware/rateLimiter");
const { computeResilience } = require("../utils/financeMath");
const { validateResilienceInput } = require("../utils/validators");
const { resiliencePrompt } = require("../utils/prompts");
const { askClaude, ANTHROPIC_KEY } = require("../services/claudeService");
const { saveResilienceSnap } = require("../services/firestoreService");

const calcResilience = functions
  .runWith({ secrets: [ANTHROPIC_KEY] })
  .https.onRequest(async (req, res) => {
    // CORS headers
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
      const { valid, error } = validateResilienceInput(req.body);
      if (!valid) return res.status(400).json({ error });

      // Step 4: Compute resilience score (deterministic math)
      let math;
      try {
        math = computeResilience(req.body);
      } catch (mathError) {
        return res.status(400).json({ error: mathError.message });
      }

      // Step 5: AI action plan
      let aiPlan;
      try {
        const { system, user } = resiliencePrompt(req.body, math);
        aiPlan = await askClaude(system, user);
      } catch (aiError) {
        console.error("Claude API error:", aiError.message);
        aiPlan = "AI plan temporarily unavailable. Your resilience score is shown above.";
      }

      // Step 6: Save snapshot to Firestore (enables trend tracking over time)
      let savedId;
      try {
        savedId = await saveResilienceSnap(uid, {
          ...req.body,
          ...math,
          aiPlan,
        });
      } catch (dbError) {
        console.error("Firestore save error:", dbError.message);
      }

      // Step 7: Respond
      return res.status(200).json({ math, aiPlan, savedId });
    });
  });

module.exports = { calcResilience };

