/**
 * FinMentor AI — Claude Prompt Templates
 *
 * WHY: Keeping prompts in one file means:
 * - Easy to tweak tone, language, or output format without touching handler logic
 * - Consistent voice across all features
 * - Simple to add multi-language support later (MY/TH/VN/PH)
 */

/**
 * System + user prompt for BNPL Risk Explainer (Feature 3)
 * @param {object} input  - raw user input
 * @param {object} math   - computed numbers from financeMath.js
 * @returns {{ system: string, user: string }}
 */
function bnplPrompt(input, math) {
  const system = `You are FinMentor AI, a friendly and direct financial literacy coach for ASEAN youth.
Your job is to explain BNPL and loan risks in simple, everyday English.
Use bullet points with relevant emojis. Keep it under 180 words.
Structure your response as:
1. 💸 What this really costs you
2. ⚠️ The risk you're taking
3. 📉 What happens if you miss a payment
4. ✅ One smart alternative action

Never use jargon. Be honest but encouraging. Do not repeat the numbers back verbatim — explain what they mean.`;

  const user = `A young adult in ASEAN is considering this BNPL / loan:

Purchase: ${input.purpose || "an item"}
Principal amount: RM ${input.amount}
Repayment tenure: ${input.months} months
Interest / processing fee: ${input.interestRate || 0}%
Monthly payment: RM ${math.monthlyPayment}
Total repayment (with interest): RM ${math.totalRepayment}
Late payment months: ${input.lateMonths || 0} × RM ${input.lateFee || 0} = RM ${math.totalLateFees}
Grand total paid: RM ${math.grandTotal}
Overpaid vs cash price: RM ${math.overpaid} (${math.overpaidPercent}% extra)
Risk level: ${math.riskLevel.toUpperCase()}

Explain the real financial risk and give one concrete alternative.`;

  return { system, user };
}

/**
 * System + user prompt for Financial Resilience Score (Feature 4)
 * @param {object} input  - raw user input
 * @param {object} math   - computed numbers from financeMath.js
 * @returns {{ system: string, user: string }}
 */
function resiliencePrompt(input, math) {
  const system = `You are FinMentor AI, a compassionate financial resilience coach for ASEAN youth.
Your job is to help young people understand how financially prepared they are for emergencies.
ASEAN context: floods, job loss, family medical emergencies are common financial shocks.
Use bullet points with emojis. Keep it under 200 words.
Structure your response as:
1. 📊 What your score means in real life
2. 🎯 Top 3 specific actions to improve (use RM amounts where possible)
3. 🌏 Why this matters in the ASEAN context

Be warm but direct. Use specific RM numbers. Do not be preachy.`;

  const user = `Financial resilience assessment for a young adult in ASEAN:

Monthly income: RM ${input.income || "not provided"}
Total savings / emergency fund: RM ${input.savings}
Fixed expenses per month: RM ${input.fixedExp}
Variable expenses per month: RM ${input.varExp || 0}
Insurance coverage available: RM ${input.insurance || 0}
Total BNPL / outstanding debt: RM ${input.bnplDebt || 0}
Number of financial dependents: ${input.dependents || 0}

Computed results:
Monthly burn rate: RM ${math.monthlyBurn}
Net liquid assets: RM ${math.netAssets}
Resilience score: ${math.scoreMonths} months survivable without income
Level: ${math.level.toUpperCase()}
Gap to next level: RM ${math.savingsGap} more savings needed

Provide a personalized, actionable plan.`;

  return { system, user };
}

module.exports = { bnplPrompt, resiliencePrompt };

