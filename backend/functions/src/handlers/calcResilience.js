/**
 * FinMentor AI — Feature 4: Financial Resilience Score
 *
 * FLUTTER SCREEN: ResilienceScreen
 *
 * Flutter currently has HARDCODED data — this backend makes it dynamic.
 * Match every field name to what ResilienceScreen needs to display.
 *
 * Flutter sends:   { savings, fixedExp, income?, varExp?, insurance?, bnplDebt?, dependents? }
 *
 * Flutter uses from response:
 *   scoreOut10            → CircularProgressIndicator value (score/10), displayed as "X.X"
 *   stressTestScore       → score when stress test toggle is ON
 *   tagLabel              → AppTag text ("⚡ MODERATE RESILIENCE" etc)
 *   survivalMonths        → "~X months without income" normal text
 *   stressDays            → "X days of safety" stress test text
 *   breakdown[]           → _buildMetricsList() — 4 items with {icon, title, score, description}
 *   nextLevelLabel        → AI card title "Path to X.X (Label)"
 *   savingsGap            → AI tip "Boost emergency fund to RM{X}"
 *   aiPlan                → AI strategy text / tips
 */

const { onRequest } = require('firebase-functions/https');
const { authMiddleware } = require('../middleware/authMiddleware');
const { rateLimiter } = require('../middleware/rateLimiter');
const { computeResilience } = require('../utils/financeMath');
const { validateResilienceInput } = require('../utils/validators');
const { resiliencePrompt } = require('../utils/prompts');
const { askClaude } = require('../services/geminiService');
const { saveResilienceSnap } = require('../services/firestoreService');

const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.calcResilience = onCall(async (request) => {
  try {
    const data = request.data;
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError("unauthenticated", "User must be logged in.");
    }

    const { valid, error } = validateResilienceInput(data);
    if (!valid) {
      throw new HttpsError("invalid-argument", error);
    }

    const math = computeResilience(data);

    const tips = [
      "Build your emergency fund to at least 3 months of expenses.",
      "Reduce BNPL commitments below 20% of income.",
      "Create consistent monthly savings automation."
    ];

    return {
      scoreOut10: math.scoreOut10,
      stressTestScore: math.stressTestScore,
      tagLabel: math.tagLabel,
      survivalMonths: math.survivalMonths,
      survivalDays: math.survivalDays,
      stressDays: math.stressDays,
      breakdown: math.breakdown,
      nextLevelLabel: math.nextLevelLabel,
      savingsGap: math.savingsGap,
      tips,
      aiPlan: "AI temporarily disabled"
    };

  } catch (err) {
    console.error(err);
    throw new HttpsError("internal", "Failed to calculate resilience");
  }
});



