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
const { askClaude } = require('../services/claudeService');
const { saveResilienceSnap } = require('../services/firestoreService');

const calcResilience = onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(204).send('');
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed.' });

  await authMiddleware(req, res, async () => {
    try {
      const uid = req.user.uid;

      const allowed = await rateLimiter(uid);
      if (!allowed) return res.status(429).json({ error: 'Daily limit reached (10/day). Try again tomorrow.' });

      const { valid, error } = validateResilienceInput(req.body);
      if (!valid) return res.status(400).json({ error });

      let math;
      try {
        math = computeResilience(req.body);
      } catch (mathError) {
        return res.status(400).json({ error: mathError.message });
      }

      // AI action plan
      let aiPlan;
      try {
        const { system, user } = resiliencePrompt(req.body, math);
        aiPlan = await askClaude(system, user);
      } catch (aiError) {
        console.error('Claude error:', aiError.message);
        aiPlan = 'AI plan temporarily unavailable.';
      }

      // Parse aiPlan into tips[] array so Flutter can map each to _tipItem()
      // AI is prompted to return numbered tips — we split on \n and filter
      const tips = aiPlan
        .split('\n')
        .map(line => line.replace(/^\d+[\.\)]\s*/, '').trim())
        .filter(line => line.length > 10)
        .slice(0, 3);  // Flutter shows exactly 3 tips

      let savedId;
      try {
        savedId = await saveResilienceSnap(uid, { ...req.body, ...math, aiPlan });
      } catch (dbError) {
        console.error('Firestore save error:', dbError.message);
      }

      return res.status(200).json({
        // Flutter CircularProgressIndicator
        scoreOut10: math.scoreOut10,            // progress = scoreOut10 / 10
        stressTestScore: math.stressTestScore,  // stress toggle value

        // Flutter tag + description text
        tagLabel: math.tagLabel,
        survivalMonths: math.survivalMonths,    // "~X months without income"
        survivalDays: math.survivalDays,
        stressDays: math.stressDays,            // "X days of safety"

        // Flutter 4-item breakdown list
        breakdown: math.breakdown,              // [{icon, title, score, description}]

        // Flutter AI card
        nextLevelLabel: math.nextLevelLabel,    // "Path to X.X (Label)"
        savingsGap: math.savingsGap,            // "Boost emergency fund to RM{X}"
        tips,                                   // Flutter maps each to _tipItem()
        aiPlan,

        // Raw data for history/debug
        raw: {
          scoreMonths: math.scoreMonths,
          monthlyBurn: math.monthlyBurn,
          netAssets: math.netAssets,
          level: math.level,
          targetMonths: math.targetMonths,
          monthsToTarget: math.monthsToTarget,
        },

        savedId,
      });

    } catch (error) {
      console.error('calcResilience error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

module.exports = { calcResilience };

