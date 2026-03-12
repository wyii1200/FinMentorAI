/**
 * FinMentor AI — Feature 4: Financial Resilience Score
 *
 * onCall function — Flutter calls via FirebaseFunctions.instance.httpsCallable('calcResilience').
 *
 * Data flow:
 *   1. Flutter sends optional overrides: { savings?, fixedExp?, income?, insurance?, bnplDebt? }
 *   2. Backend reads users/{uid} from Firestore for any missing fields
 *      (populated by analyzeSpending on last run)
 *   3. Calculates score and returns to Flutter
 *
 * Flutter reads:
 *   scoreOut10, stressTestScore, tagLabel, survivalMonths, stressDays,
 *   breakdown[], nextLevelLabel, savingsGap, tips[]
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { computeResilience }      = require('../utils/financeMath');
const { validateResilienceInput } = require('../utils/validators');
const { askClaude, _mockResiliencePlan } = require('../services/geminiService');
const { resiliencePrompt }        = require('../utils/prompts');
const { saveResilienceSnap }      = require('../services/firestoreService');
const admin                       = require('firebase-admin');

exports.calcResilience = onCall(async (request) => {
  // ── Auth ───────────────────────────────────────────────────────────────
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'User must be logged in.');

  // ── Read user profile from Firestore (set by analyzeSpending) ─────────
  let userDoc = {};
  try {
    const snap = await admin.firestore().collection('users').doc(uid).get();
    if (snap.exists) userDoc = snap.data();
  } catch (e) {
    console.error('Firestore read error:', e.message);
  }

  // ── Merge: Flutter overrides take priority, Firestore fills the gaps ───
  const body = {
    savings:    Number(request.data.savings    ?? userDoc.savings    ?? 0),
    fixedExp:   Number(request.data.fixedExp   ?? userDoc.expenses   ?? 0),
    income:     Number(request.data.income     ?? userDoc.income     ?? 0),
    varExp:     Number(request.data.varExp     ?? 0),
    insurance:  Number(request.data.insurance  ?? userDoc.insurance  ?? 0),
    bnplDebt:   Number(request.data.bnplDebt   ?? userDoc.bnplCommitments ?? 0),
    dependents: Number(request.data.dependents ?? 0),
  };

  const { valid, error } = validateResilienceInput(body);
  if (!valid) throw new HttpsError('invalid-argument', error);

  // ── Calculate ──────────────────────────────────────────────────────────
  let math;
  try {
    math = computeResilience(body);
  } catch (mathError) {
    throw new HttpsError('invalid-argument', mathError.message);
  }

  // ── AI tips ────────────────────────────────────────────────────────────
  let aiPlan;
  try {
    const { system, user } = resiliencePrompt(body, math);
    const result = await askClaude(system, user, 400);
    aiPlan = result ?? _mockResiliencePlan(math, body);
  } catch (e) {
    console.error('Gemini resilience error:', e.message);
    aiPlan = _mockResiliencePlan(math, body);
  }

  // Parse aiPlan into tips[] array — each line becomes one bolt item in Flutter
  const tips = aiPlan
    .split('\n')
    .map(line => line.replace(/^[\d]+[\.\)]\s*/, '').replace(/^[•\-]\s*/, '').trim())
    .filter(line => line.length > 15)
    .slice(0, 3);

  // ── Save snapshot ──────────────────────────────────────────────────────
  try {
    await saveResilienceSnap(uid, { ...body, ...math, aiPlan });

    // Also update users/{uid} with latest savings for future pre-fills
    await admin.firestore().collection('users').doc(uid).set({
      savings:   body.savings,
      insurance: body.insurance,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

  } catch (e) {
    console.error('Firestore save error:', e.message);
  }

  return {
    scoreOut10:      math.scoreOut10,
    stressTestScore: math.stressTestScore,
    tagLabel:        math.tagLabel,
    survivalMonths:  math.survivalMonths,
    survivalDays:    math.survivalDays,
    stressDays:      math.stressDays,
    breakdown:       math.breakdown,
    nextLevelLabel:  math.nextLevelLabel,
    savingsGap:      math.savingsGap,
    tips,
    aiPlan,
    // Return the values used so Flutter knows what was pre-filled
    usedValues: body,
  };
});

