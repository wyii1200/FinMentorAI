/**
 * FinMentor AI — Feature 1: AI Spending Analyzer
 *
 * FLUTTER SCREEN: AnalyzerScreen
 *
 * Flutter sends:   { income, expenses, bnpl, savings }
 * Flutter uses from response:
 *   breakdown.pieTotal               → pie chart center "RM{total}"
 *   breakdown.bnplBurden             → InsightCard "BNPL is X% of income"
 *   breakdown.isRisky                → switches warning card icon/color/text (threshold: 15%)
 *   breakdown.monthsToSaveOneMonth   → InsightCard "takes X months to save 1 month of income"
 *   riskLevel                        → "Low" | "Medium" | "High"
 *   advice                           → AI text block
 */

const { onRequest } = require('firebase-functions/https');
const { authMiddleware } = require('../middleware/authMiddleware');
const { rateLimiter } = require('../middleware/rateLimiter');
const { analyzeSpendingWithClaude } = require('../services/claudeService');
const { saveSpendingAnalysis } = require('../services/firestoreService');
const { calculateSpendingMetrics } = require('../utils/financeMath');
const { validateSpendingInput } = require('../utils/validators');

const analyzeSpendingHandler = async (req, res) => {
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

      const { income, expenses, bnpl, savings } = req.body;

      const validationError = validateSpendingInput({ income, expenses, bnpl, savings });
      if (validationError) return res.status(400).json({ error: validationError });

      const metrics = calculateSpendingMetrics({ income, expenses, bnpl, savings });

      let advice;
      try {
        advice = await analyzeSpendingWithClaude({ income, expenses, bnpl, savings, metrics });
      } catch (e) {
        console.error('Claude error:', e.message);
        advice = 'AI advice temporarily unavailable.';
      }

      const result = {
        breakdown: {
          pieTotal: metrics.pieTotal,                          // Flutter pie center "RM{X}"
          expensesSlice: metrics.expensesSlice,                // blue slice
          bnplSlice: metrics.bnplSlice,                        // red slice
          savingsSlice: metrics.savingsSlice,                  // purple slice
          bnplBurden: metrics.bnplBurden,                      // "BNPL is X% of income"
          isRisky: metrics.isRisky,                            // bnplBurden > 15 → warning card
          monthsToSaveOneMonth: metrics.monthsToSaveOneMonth,  // insight card months
          savingsRate: metrics.savingsRate,
          disposableIncome: metrics.disposableIncome,
          totalExpenses: metrics.totalExpenses,
        },
        riskLevel: metrics.riskLevel,   // "Low" | "Medium" | "High"
        advice,
        timestamp: new Date().toISOString(),
      };

      let savedId;
      try {
        savedId = await saveSpendingAnalysis(uid, result);
        result.savedId = savedId;
      } catch (e) {
        console.error('Firestore save error:', e.message);
      }

      return res.status(200).json(result);

    } catch (error) {
      console.error('analyzeSpending error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  });
};

const analyzeSpending = onRequest(analyzeSpendingHandler);
module.exports = { analyzeSpending };

