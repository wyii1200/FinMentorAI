/**
 * FinMentor AI — Feature 2: Future You Simulator
 *
 * FLUTTER SCREEN: SimulatorScreen
 *
 * Flutter tabs map to scenarioType:
 *   'BNPL Purchase'  → scenarioType: 'bnpl'
 *   'Save More'      → scenarioType: 'savings'
 *   'Personal Loan'  → scenarioType: 'loan'  (same math as bnpl)
 *
 * Flutter sends:   { scenarioType, income, amount, months, interestRate?, existingSavings? }
 *   amount:  1500 for bnpl/loan, 400 for savings (Flutter hardcoded defaults)
 *   months:  slider value 3–24
 *
 * Flutter uses from response:
 *   chartData[]          → LineChart spots {month, debt, savings}
 *   netImpact            → "NET IMPACT +RM X" card
 *   scoreDelta           → "SCORE Δ +X pts" card
 *   advice               → _buildFinMentorAdvice() dark card text
 */

const { onRequest } = require('firebase-functions/https');
const { authMiddleware } = require('../middleware/authMiddleware');
const { rateLimiter } = require('../middleware/rateLimiter');
const { simulateFutureWithClaude } = require('../services/geminiService');
const { saveSimulation } = require('../services/firestoreService');
const { computeFutureSimulation } = require('../utils/financeMath');
const { validateSimulationInput } = require('../utils/validators');

const simulateFutureHandler = async (req, res) => {
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

      const { scenarioType, income, amount, months, interestRate = 0, existingSavings = 0 } = req.body;

      // Validate — accepts 'bnpl', 'savings', 'loan' (loan added for Flutter tab 3)
      const validationError = validateSimulationInput({ scenarioType, income, amount, months });
      if (validationError) return res.status(400).json({ error: validationError });

      const simulation = computeFutureSimulation({ scenarioType, income, amount, months, interestRate, existingSavings });

      let advice;
      try {
        advice = await simulateFutureWithClaude({ scenarioType, income, amount, months, interestRate, existingSavings, simulation });
      } catch (e) {
        console.error('Claude error:', e.message);
        advice = 'AI advice temporarily unavailable.';
      }

      const result = {
        // Flutter LineChart data
        chartData: simulation.chartData,         // [{month, debt, savings}] — Flutter plots this

        // Flutter impact summary card
        netImpact: simulation.netImpact,         // "NET IMPACT +RM X"
        scoreDelta: simulation.scoreDelta,        // "SCORE Δ +X pts"

        // Full simulation details
        simulation: {
          debtProjection: simulation.debtProjection,
          savingsProjection: simulation.savingsProjection,
          emergencyScore: simulation.emergencyScore,
          interestPaid: simulation.interestPaid,
          netWorthDelta: simulation.netWorthDelta,
        },

        riskLevel: simulation.riskLevel,
        advice,                                  // Flutter dark advice card text
        timestamp: new Date().toISOString(),
      };

      let savedId;
      try {
        savedId = await saveSimulation(uid, result);
        result.savedId = savedId;
      } catch (e) {
        console.error('Firestore save error:', e.message);
      }

      return res.status(200).json(result);

    } catch (error) {
      console.error('simulateFuture error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
};

const simulateFuture = onRequest(simulateFutureHandler);
module.exports = { simulateFuture };