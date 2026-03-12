/**
 * FinMentor AI — Gemini Service
 *
 * HOW TO GO LIVE:
 *   1. Get your key: https://aistudio.google.com/app/apikey  (free tier available)
 *   2. Set secret:  firebase functions:secrets:set GEMINI_API_KEY
 *   3. In .secret.local (emulator):  GEMINI_API_KEY=AIza...
 *   4. Change USE_REAL_AI = true below
 *   5. Redeploy:  firebase deploy --only functions
 *
 * Model used: gemini-1.5-flash  (fastest + cheapest, good free-tier quota)
 * All 4 features use the SAME toggle — flip once, everything goes live.
 */

const USE_REAL_AI = true;  // ← change to true when your key is ready

const GEMINI_MODEL = 'gemini-2.5-flash';
const GEMINI_BASE  = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

// ── Core Gemini call ──────────────────────────────────────────────────────
/**
 * Calls Gemini REST API directly — no SDK needed, just node-fetch / https.
 * Returns the text response, or null on error (callers fall back to mock).
 *
 * @param {string} systemInstruction  - role / personality for the model
 * @param {string} userPrompt         - the actual question / data
 * @param {number} maxTokens
 */
const askGemini = async (systemInstruction, userPrompt, maxTokens = 400) => {
  if (!USE_REAL_AI) return null;

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error('GEMINI_API_KEY not set in environment.');
    return null;
  }

  try {
    // Use built-in https to avoid adding a package dependency
    const https = require('https');
    const url   = `${GEMINI_BASE}?key=${apiKey}`;

    const body = JSON.stringify({
      system_instruction: {
        parts: [{ text: systemInstruction }],
      },
      contents: [
        { role: 'user', parts: [{ text: userPrompt }] },
      ],
      generationConfig: {
        maxOutputTokens: maxTokens,
        temperature: 0.7,
      },
    });

    const text = await new Promise((resolve, reject) => {
      const req = https.request(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            if (res.statusCode !== 200) {
              reject(new Error(`Gemini ${res.statusCode}: ${json.error?.message ?? data}`));
              return;
            }
            const result = json.candidates?.[0]?.content?.parts?.[0]?.text;
            if (!result) reject(new Error('Empty Gemini response'));
            else resolve(result.trim());
          } catch (e) { reject(e); }
        });
      });
      req.on('error', reject);
      req.write(body);
      req.end();
    });

    return text;
  } catch (err) {
    console.error('Gemini API error:', err.message);
    return null;
  }
};

// ── Feature 1 — AI Spending Analyzer ─────────────────────────────────────
const { buildSpendingAnalysisPrompt } = require('../utils/prompts');

const analyzeSpendingWithClaude = async ({ income, expenses, bnpl, savings, metrics }) => {
  if (USE_REAL_AI) {
    const system = `You are FinMentor, a friendly and practical financial literacy advisor for ASEAN youth.
Keep responses under 200 words. Use plain text only — no markdown, no bullet symbols.
Be encouraging but honest. Tailor advice to Malaysian/ASEAN context (use RM, mention ASB, EPF, BNPL local habits).`;

    const user = buildSpendingAnalysisPrompt({ income, expenses, bnpl, savings, metrics });
    const result = await askGemini(system, user, 400);
    if (result) return result;
  }
  return _mockSpendingAdvice(metrics);
};

const _mockSpendingAdvice = (metrics) => {
  if (metrics.riskLevel === 'High') {
    return `Your spending is stretched thin right now. With ${metrics.expenseRatio.toFixed(0)}% of income going to expenses and only ${metrics.savingsRate.toFixed(0)}% saved, an unexpected bill could cause real stress. Your BNPL commitments at ${metrics.bnplBurden.toFixed(0)}% of income is the biggest risk — above the safe 15% limit. This month: 1) Pause any new BNPL purchases until current ones are cleared. 2) Move at least RM200 into a separate emergency fund account. 3) List all subscriptions and cancel any unused ones.`;
  }
  if (metrics.riskLevel === 'Medium') {
    return `You are managing reasonably well, but there is room to strengthen your position. Your savings rate of ${metrics.savingsRate.toFixed(0)}% is a decent start — pushing it toward 20% will build a much stronger safety net. Watch the BNPL at ${metrics.bnplBurden.toFixed(0)}% of income. Three things to try this month: 1) Increase savings by RM100–200 using the 50-30-20 rule. 2) Set a monthly reminder to review all BNPL commitments. 3) Keep expenses below 70% of income as your benchmark.`;
  }
  return `Your finances are in good shape — you have a healthy savings rate of ${metrics.savingsRate.toFixed(0)}% and controlled expenses. The next step is to put that discipline to work harder: 1) Move extra savings into ASB or a high-yield account for better returns. 2) Build your emergency fund to cover 6 full months of expenses. 3) Review your insurance coverage to protect the wealth you are building.`;
};

// ── Feature 2 — Future Simulator ─────────────────────────────────────────
const { buildSimulationPrompt } = require('../utils/prompts');

const simulateFutureWithClaude = async ({ scenarioType, income, amount, months, interestRate, existingSavings, simulation }) => {
  if (USE_REAL_AI) {
    const system = `You are FinMentor, a friendly financial literacy advisor for ASEAN youth.
Keep responses under 200 words. Use plain text only. Use RM amounts and local Malaysian context.
Be honest but encouraging.`;

    const user = buildSimulationPrompt({ scenarioType, income, amount, months, interestRate, existingSavings, simulation });
    const result = await askGemini(system, user, 400);
    if (result) return result;
  }
  return _mockSimulationAdvice(simulation, scenarioType, months, amount, interestRate);
};

const _mockSimulationAdvice = (simulation, scenarioType, months, amount, interestRate) => {
  if (scenarioType === 'bnpl' || scenarioType === 'loan') {
    const label = scenarioType === 'loan' ? 'personal loan' : 'BNPL';
    return `After ${months} months, this ${label} will cost you RM${simulation.interestPaid} in interest on top of the original RM${amount}. Your emergency fund covers ${simulation.emergencyScore} months — useful, but tight. The biggest consequence is that monthly repayments reduce your ability to build savings during this period. Alternative 1: Save for 3 months first and pay cash to avoid all interest costs. Alternative 2: If urgent, check if your bank offers a 0% credit card installment plan instead.`;
  }
  if (scenarioType === 'savings') {
    return `After ${months} months of consistent saving, your emergency fund will reach ${simulation.emergencyScore} months of survivability — a meaningful safety net. The biggest win is compound interest quietly growing your balance month by month. Alternative 1: Place savings in ASB or a high-yield savings account to boost the 3.5% rate. Alternative 2: Once you hit 3 months emergency fund, start channelling the extra into unit trusts for long-term growth.`;
  }
  return `Running both scenarios, your net position over ${months} months changes by RM${simulation.netWorthDelta}. The core trade-off: every ringgit in BNPL interest (RM${simulation.interestPaid}) is a ringgit that could not compound in savings. Alternative 1: Clear the highest-interest BNPL first using the debt avalanche method. Alternative 2: After clearing debt, redirect those monthly payments directly into savings.`;
};

// ── Feature 3 — BNPL Risk ─────────────────────────────────────────────────
const { bnplPrompt } = require('../utils/prompts');

/**
 * askClaude — kept as the export name so all 3 handlers (analyzeBNPL,
 * calcResilience, and any future handler) work without any changes.
 */
const askClaude = async (system, user, maxTokens = 350) => {
  return askGemini(system, user, maxTokens);
};

const _mockBnplAdvice = (math, input) => {
  const { riskLevel, overpaidPercent, monthly, total } = math;
  if (riskLevel === 'high') {
    return `💸 This really costs you: You pay RM${total} total — that is ${overpaidPercent.toFixed(0)}% more than the sticker price, purely in interest.\n⚠️ The risk: RM${monthly}/month for ${input.months} months is a real commitment. If your income dips even once, you will struggle to keep up.\n📉 Miss a payment: Late fees, CCRIS records, and your next loan application gets harder or more expensive.\n✅ Smarter alternative: Save RM${Math.ceil(monthly)} per month for ${Math.ceil(input.months * 0.6)} months instead and pay cash — you will save the entire RM${math.overpaid} in interest.`;
  }
  if (riskLevel === 'medium') {
    return `💸 What this costs: You pay RM${Math.round(math.interest || (total - input.amount))} in interest over ${input.months} months — manageable but real.\n⚠️ The risk: Monthly payments of RM${monthly} need to fit comfortably in your budget alongside rent, food, and other BNPL commitments.\n📉 If you miss a payment: Most Malaysian BNPL providers charge RM10–30 per late payment and report to CCRIS after 90 days.\n✅ Smarter move: Make sure this monthly payment is below 15% of your income. If it pushes you over, consider a shorter plan with a higher monthly amount to reduce total interest.`;
  }
  return `💸 Cost breakdown: This plan adds RM${Math.round(math.interest || (total - input.amount))} in interest — a relatively modest premium for the convenience.\n⚠️ Still a commitment: Even "low risk" BNPL adds to your monthly obligations. Make sure you can handle this payment without skipping savings.\n📉 Late payments still hurt: Even small BNPL plans get reported to CCRIS if overdue. A single default can affect your ability to get a home or car loan later.\n✅ Best practice: Set an auto-payment or calendar reminder 3 days before each due date.`;
};

// ── Feature 4 — Resilience ────────────────────────────────────────────────
const _mockResiliencePlan = (math, input) => {
  const gap = math.savingsGap;
  const monthly = math.monthlyBurn;
  const income = input.income || 0;
  const saveSuggest = income > 0 ? Math.round(income * 0.2) : Math.round(monthly * 0.3);

  if (math.level === 'critical' || math.level === 'vulnerable') {
    return `1. Build an emergency fund of RM${Math.round(monthly * 3)} (3 months of expenses) as your first priority — set aside RM${saveSuggest}/month into a separate savings account.\n2. Reduce BNPL commitments by RM${Math.round((input.bnplDebt || 0) * 0.3)} — pay off the smallest balance first to free up monthly cash flow.\n3. Get basic hospitalisation insurance (from RM50–100/month via Takaful or bank plans) to protect against the single biggest financial shock in Malaysia.`;
  }
  if (math.level === 'moderate') {
    return `1. Grow your emergency fund by RM${gap} to reach the 6-month target — at RM${saveSuggest}/month you will get there in ${Math.ceil(gap / (saveSuggest || 1))} months.\n2. Move current savings into ASB or a high-yield savings account to earn more than the standard 0.5–1% bank rate.\n3. Consolidate any BNPL commitments into a single plan with the lowest interest rate — this reduces your monthly obligations and improves your debt-to-income score.`;
  }
  return `1. Maintain your emergency fund at 6+ months and start investing the surplus in unit trusts or EPF top-ups for long-term compound growth.\n2. Review and increase your insurance coverage — include income protection alongside health cover to guard against salary loss from illness.\n3. Set a 6-month savings stretch goal: add RM${Math.round(saveSuggest * 0.5)} more per month and track progress weekly to stay motivated.`;
};

// ── Exported wrapper used by F3 + F4 handlers ─────────────────────────────
const askClaudeWithFallback = async (system, user, fallbackFn, ...fallbackArgs) => {
  const result = await askGemini(system, user);
  if (result) return result;
  return fallbackFn(...fallbackArgs);
};

// ── Secret export — now points to GEMINI_API_KEY ──────────────────────────
let _secret = null;
try {
  const { defineSecret } = require('firebase-functions/params');
  _secret = defineSecret('GEMINI_API_KEY');
} catch (_) {}

module.exports = {
  // Same export names as before — no changes needed in any handler file
  analyzeSpendingWithClaude,
  simulateFutureWithClaude,
  askClaude,              // F3 + F4 handlers call this directly
  askClaudeWithFallback,
  ANTHROPIC_KEY: _secret, // kept as ANTHROPIC_KEY so handlers don't need edits
  _mockBnplAdvice,
  _mockResiliencePlan,
};

