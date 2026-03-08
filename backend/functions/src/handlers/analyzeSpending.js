/**
 * FinMentor AI — Feature 1: AI Spending Analyzer
 *
 * Cloud Function: POST /analyzeSpending
 *
 * Flow:
 *   1. Verify Firebase Auth token (authMiddleware)
 *   2. Check daily rate limit (rateLimiter)
 *   3. Validate request body (validators)
 *   4. Calculate spending metrics instantly — no AI needed for numbers (financeMath)
 *   5. Call Claude for personalized spending advice (claudeService)
 *   6. Save result to Firestore under user's analysis history (firestoreService)
 *   7. Return breakdown + risk level + AI advice to frontend
 *
 * Request body:
 * {
 *   userId:   string   (Firebase UID, optional — for saving to Firestore)
 *   income:   number   (RM, required)
 *   expenses: number   (RM, required)
 *   bnpl:     number   (RM/month total BNPL commitments, required)
 *   savings:  number   (RM/month, required)
 * }
 *
 * Response:
 * {
 *   breakdown: {
 *     totalExpenses:    number   (expenses + bnpl combined)
 *     savingsRate:      number   (% of income saved)
 *     bnplBurden:       number   (% of income going to BNPL)
 *     disposableIncome: number   (what's left after expenses + savings)
 *   }
 *   riskLevel: string  ("Low" | "Medium" | "High")
 *   advice:    string  (Claude's personalized financial advice)
 *   timestamp: string  (ISO date of analysis)
 *   savedId:   string  (Firestore document ID for history)
 * }
 */

const { analyzeSpendingWithClaude } = require('../services/claudeService');
const { saveSpendingAnalysis } = require('../services/firestoreService');
const { calculateSpendingMetrics } = require('../utils/financeMath');
const { validateSpendingInput } = require('../utils/validators');

const analyzeSpending = async (req, res) => {
  try {
    const { income, expenses, bnpl, savings, userId } = req.body;

    // 1. Validate input
    const validationError = validateSpendingInput({ income, expenses, bnpl, savings });
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    // 2. Calculate metrics
    const metrics = calculateSpendingMetrics({ income, expenses, bnpl, savings });

    // 3. Get AI advice from Claude
    const aiAdvice = await analyzeSpendingWithClaude({ income, expenses, bnpl, savings, metrics });

    // 4. Build response
    const result = {
      breakdown: {
        totalExpenses: expenses + bnpl,
        savingsRate: metrics.savingsRate,
        bnplBurden: metrics.bnplBurden,
        disposableIncome: metrics.disposableIncome,
      },
      riskLevel: metrics.riskLevel,
      advice: aiAdvice,
      timestamp: new Date().toISOString(),
    };

    // 5. Save to Firestore (optional, skip if no userId)
    if (userId) {
      await saveSpendingAnalysis(userId, result);
    }

    return res.status(200).json(result);

  } catch (error) {
    console.error('analyzeSpending error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { analyzeSpending };