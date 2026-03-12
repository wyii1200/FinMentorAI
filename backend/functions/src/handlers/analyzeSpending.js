/**
 * FinMentor AI — Feature 1: AI Spending Analyzer
 *
 * Converted from onRequest → onCall.
 * Flutter calls via FirebaseFunctions.instance.httpsCallable('analyzeSpending').
 * Auth token is attached automatically — no manual Authorization header needed.
 *
 * Flutter sends:   { income, expenses, bnpl, savings }
 * Flutter reads:   breakdown.*, riskLevel, advice, savedId
 *
 * Side effect: updates users/{uid} doc with latest income/expenses/bnpl
 * so calcResilience and other features can pre-fill from Firestore.
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { analyzeSpendingWithClaude } = require('../services/geminiService');
const { saveSpendingAnalysis }      = require('../services/firestoreService');
const { calculateSpendingMetrics }  = require('../utils/financeMath');
const { validateSpendingInput }     = require('../utils/validators');
const admin                         = require('firebase-admin');

exports.analyzeSpending = onCall(async (request) => {
  // ── Auth ───────────────────────────────────────────────────────────────
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'User must be logged in.');

  // ── Parse + coerce inputs ──────────────────────────────────────────────
  const income   = Number(request.data.income   ?? 0);
  const expenses = Number(request.data.expenses ?? 0);
  const bnpl     = Number(request.data.bnpl     ?? 0);
  const savings  = Number(request.data.savings  ?? 0);

  const validationError = validateSpendingInput({ income, expenses, bnpl, savings });
  if (validationError) throw new HttpsError('invalid-argument', validationError);

  // ── Math ───────────────────────────────────────────────────────────────
  const metrics = calculateSpendingMetrics({ income, expenses, bnpl, savings });

  // ── AI advice ──────────────────────────────────────────────────────────
  let advice = 'AI advice temporarily unavailable.';
  try {
    advice = await analyzeSpendingWithClaude({ income, expenses, bnpl, savings, metrics });
  } catch (e) {
    console.error('Gemini spending error:', e.message);
  }

  const result = {
    breakdown: {
      pieTotal:             metrics.pieTotal,
      expensesSlice:        metrics.expensesSlice,
      bnplSlice:            metrics.bnplSlice,
      savingsSlice:         metrics.savingsSlice,
      bnplBurden:           metrics.bnplBurden,
      isRisky:              metrics.isRisky,
      monthsToSaveOneMonth: metrics.monthsToSaveOneMonth,
      savingsRate:          metrics.savingsRate,
      disposableIncome:     metrics.disposableIncome,
      totalExpenses:        metrics.totalExpenses,
    },
    riskLevel: metrics.riskLevel,
    advice,
    timestamp: new Date().toISOString(),
  };

  // ── Save analysis history + update user profile ────────────────────────
  try {
    const savedId = await saveSpendingAnalysis(uid, {
      ...result,
      raw: { income, expenses, bnpl, savings },
    });
    result.savedId = savedId;

    // Update users/{uid} so other features (calcResilience) can read latest values
    await admin.firestore().collection('users').doc(uid).set({
      income,
      expenses,
      bnplCommitments: bnpl,
      savingsGoal:     savings * 6,
      updatedAt:       admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

  } catch (e) {
    console.error('Firestore error:', e.message);
  }

  return result;
});

