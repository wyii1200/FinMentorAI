/**
 * FinMentor AI — Feature 2: "Future You" Financial Simulator
 *
 * Cloud Function: POST /simulateFuture
 *
 * Flow:
 *   1. Verify Firebase Auth token (authMiddleware)
 *   2. Check daily rate limit (rateLimiter)
 *   3. Validate request body (validators)
 *   4. Compute debt projection / savings growth instantly (financeMath)
 *   5. Call Claude for personalized future scenario explanation (claudeService)
 *   6. Save result to Firestore under user's simulation history (firestoreService)
 *   7. Return chart data + AI narrative to frontend
 *
 * Request body:
 * {
 *   userId:        string   (Firebase UID, optional)
 *   scenarioType:  string   ("bnpl" | "savings" | "both", required)
 *   income:        number   (RM, required)
 *   amount:        number   (RM value of purchase or monthly savings, required)
 *   months:        number   (simulation duration in months, required)
 *   interestRate:  number   (%, optional, default 0)
 *   existingSavings: number (RM, optional, default 0)
 * }
 *
 * Response:
 * {
 *   simulation: {
 *     debtProjection:    array    (monthly debt balance over time)
 *     savingsProjection: array    (monthly savings balance over time)
 *     emergencyScore:    number   (months survivable without income)
 *     interestPaid:      number   (total interest paid)
 *     netWorthDelta:     number   (difference vs not taking BNPL)
 *   }
 *   riskLevel:   string   ("Low" | "Medium" | "High")
 *   chartData:   array    (formatted for frontend chart library)
 *   advice:      string   (Claude's future scenario narrative)
 *   timestamp:   string   (ISO date)
 *   savedId:     string   (Firestore document ID)
 * }
 */

const { onRequest } = require('firebase-functions/https');
const { simulateFutureWithClaude } = require('../services/claudeService');
const { saveSimulation } = require('../services/firestoreService');
const { computeFutureSimulation } = require('../utils/financeMath');
const { validateSimulationInput } = require('../utils/validators');

const simulateFutureHandler = async (req, res) => {
  try {
    const { userId, scenarioType, income, amount, months, interestRate = 0, existingSavings = 0 } = req.body;

    // 1. Validate input
    const validationError = validateSimulationInput({ scenarioType, income, amount, months });
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    // 2. Compute simulation math
    const simulation = computeFutureSimulation({ scenarioType, income, amount, months, interestRate, existingSavings });

    // 3. Get AI narrative from Claude
    const advice = await simulateFutureWithClaude({ scenarioType, income, amount, months, interestRate, existingSavings, simulation });

    // 4. Build response
    const result = {
      simulation: {
        debtProjection: simulation.debtProjection,
        savingsProjection: simulation.savingsProjection,
        emergencyScore: simulation.emergencyScore,
        interestPaid: simulation.interestPaid,
        netWorthDelta: simulation.netWorthDelta,
      },
      riskLevel: simulation.riskLevel,
      chartData: simulation.chartData,
      advice,
      timestamp: new Date().toISOString(),
    };

    // 5. Save to Firestore (optional)
    if (userId) {
      const savedId = await saveSimulation(userId, result);
      result.savedId = savedId;
    }

    return res.status(200).json(result);

  } catch (error) {
    console.error('simulateFuture error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

const simulateFuture = onRequest(simulateFutureHandler);
module.exports = { simulateFuture };