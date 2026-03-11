/**
 * FinMentor AI — Feature 3: BNPL Risk Calculator
 *
 * FLUTTER SCREEN: BNPLScreen
 *
 * Flutter sends:   { amount, months (as 'duration'), interestRate }
 *   IMPORTANT: Flutter's "Interest (%/mo)" label means interestRate is PER MONTH
 *   Flutter formula: totalInterest = p * r * t  (FLAT, not compound)
 *
 * Flutter uses from response:
 *   math.total       → "RM {total}" headline (_buildRepaymentCard)
 *   math.principal   → "Original: RM{principal}"
 *   math.interest    → "+ Interest: RM{interest}"
 *   math.monthly     → "RM {monthly} / month" (_buildMonthlyBreakdownCard)
 *   aiAdvice         → shown after the 4 risk cards
 */

const { onRequest } = require('firebase-functions/https');
const { defineSecret } = require('firebase-functions/params');
const { authMiddleware } = require('../middleware/authMiddleware');
const { rateLimiter } = require('../middleware/rateLimiter');
const { computeBNPL } = require('../utils/financeMath');
const { validateBNPLInput } = require('../utils/validators');
const { bnplPrompt } = require('../utils/prompts');
const { askClaude, ANTHROPIC_KEY } = require('../services/claudeService');
const { saveBNPLCheck } = require('../services/firestoreService');

const analyzeBNPL = onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(204).send('');
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed.' });

  // For emulator testing: comment out authMiddleware block and use fake user
  await authMiddleware(req, res, async () => {
    try {
      const uid = req.user.uid;

      
      const allowed = await rateLimiter(uid);
      if (!allowed) return res.status(429).json({ error: 'Daily limit reached (10/day). Try again tomorrow.' });

      // Flutter sends 'duration' as the months field name — accept both
      const body = {
        ...req.body,
        months: req.body.months ?? req.body.duration,
      };

      const { valid, error } = validateBNPLInput(body);
      if (!valid) return res.status(400).json({ error });


      let math;
      try {
        math = computeBNPL(body);
      } catch (mathError) {
        return res.status(400).json({ error: mathError.message });
      }

      // AI advice
      let aiAdvice;
      try {
        const { system, user } = bnplPrompt(body, math);
        aiAdvice = await askClaude(system, user);
      } catch (aiError) {
        console.error('Claude error:', aiError.message);
        aiAdvice = 'AI analysis temporarily unavailable. Your numbers are shown above.';
      }


      let savedId;
      try {
        savedId = await saveBNPLCheck(uid, { ...body, ...math, aiAdvice });
      } catch (dbError) {
        console.error('Firestore save error:', dbError.message);
      }

      // Response uses Flutter field names exactly
      return res.status(200).json({
        math: {
          principal: math.principal,    // Flutter: "Original: RM{principal}"
          interest: math.interest,      // Flutter: "+ Interest: RM{interest}"
          total: math.total,            // Flutter: "RM {total}" headline
          monthly: math.monthly,        // Flutter: "RM {monthly} / month"
          overpaidPercent: math.overpaidPercent,
          riskLevel: math.riskLevel,
          // Extra fields (not displayed by Flutter yet, but useful for history)
          totalLateFees: math.totalLateFees,
          grandTotal: math.grandTotal,
        },
        aiAdvice,
        savedId,
      });

    } catch (error) {
      console.error('analyzeBNPL error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
});

module.exports = { analyzeBNPL };



