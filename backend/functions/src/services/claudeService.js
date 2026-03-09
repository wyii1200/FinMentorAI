/**
 * FinMentor AI — Claude Service
 * 
 * NOTE: This is a temporary mock for testing Feature 1.
 * Replace the mock with real Anthropic API call when teammate sets up the full service.
 */


//feature 1
const { buildSpendingAnalysisPrompt } = require('../utils/prompts');

const analyzeSpendingWithClaude = async ({ income, expenses, bnpl, savings, metrics }) => {
  
  // ── MOCK RESPONSE (remove this block and uncomment real API call below when credits are added) ──
  return getMockAdvice(metrics);

  // ── REAL API CALL (uncomment when credits are ready) ──
  // const Anthropic = require('@anthropic-ai/sdk');
  // const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  // const prompt = buildSpendingAnalysisPrompt({ income, expenses, bnpl, savings, metrics });
  // const message = await client.messages.create({
  //   model: 'claude-sonnet-4-5',
  //   max_tokens: 400,
  //   messages: [{ role: 'user', content: prompt }],
  // });
  // return message.content[0].text;
};

const getMockAdvice = (metrics) => {
  if (metrics.riskLevel === 'High') {
    return `Your spending is quite tight right now. With ${metrics.expenseRatio}% of your income going to expenses and only ${metrics.savingsRate}% saved, you are at high risk of running out of money if anything unexpected happens. Your biggest risk is your BNPL commitment eating ${metrics.bnplBurden}% of your income. Try these 3 tips: 1) Pause any new BNPL purchases until existing ones are paid off. 2) Set aside at least RM200 per month into a separate emergency savings account. 3) Review your monthly subscriptions and cancel any you do not use regularly.`;
  }
  if (metrics.riskLevel === 'Medium') {
    return `You are managing okay but there is room to improve. Your savings rate of ${metrics.savingsRate}% is a good start but building it up further will protect you better. Watch your BNPL usage at ${metrics.bnplBurden}% of income. Here are 3 tips: 1) Try to increase savings by RM100-200 each month. 2) Use the 50-30-20 rule: 50% needs, 30% wants, 20% savings. 3) Set a reminder to review your BNPL commitments every month.`;
  }
  return `Great job managing your finances! Your savings rate of ${metrics.savingsRate}% is healthy and your expenses are well controlled. Keep it up with these 3 tips: 1) Consider investing your extra savings in unit trusts or ASB for better returns. 2) Build your emergency fund to cover 6 months of expenses. 3) Review your insurance coverage to protect what you have built.`;
};


//feature 2 
const { buildSimulationPrompt } = require('../utils/prompts');

const simulateFutureWithClaude = async ({ scenarioType, income, amount, months, interestRate, existingSavings, simulation }) => {

  // ── MOCK RESPONSE (remove when credits are added) ──
  return getMockSimulationAdvice(simulation, scenarioType, months);

  // ── REAL API CALL (uncomment when credits are ready) ──
  // const prompt = buildSimulationPrompt({ scenarioType, income, amount, months, interestRate, existingSavings, simulation });
  // const message = await client.messages.create({
  //   model: 'claude-sonnet-4-5',
  //   max_tokens: 400,
  //   messages: [{ role: 'user', content: prompt }],
  // });
  // return message.content[0].text;
};

const getMockSimulationAdvice = (simulation, scenarioType, months) => {
  if (scenarioType === 'bnpl') {
    return `After ${months} months, you will have paid RM${simulation.interestPaid} in interest on top of your original purchase. Your emergency fund score is ${simulation.emergencyScore} months, which means you can survive ${simulation.emergencyScore} months without income. The biggest consequence is that this BNPL reduces your ability to save during this period. Alternative 1: Save up for 3 months first and buy with cash to avoid interest. Alternative 2: Look for a 0% installment plan through your bank credit card which has no interest charges.`;
  }
  if (scenarioType === 'savings') {
    return `After ${months} months of consistent saving, your emergency fund score will reach ${simulation.emergencyScore} months. This means you can survive financial shocks like job loss or medical emergencies for ${simulation.emergencyScore} months. The biggest win here is the compound growth on your savings. Alternative 1: Put savings into ASB or a high-yield savings account for better returns. Alternative 2: Once you hit 3 months emergency fund, start investing the extra into unit trusts.`;
  }
  return `Running both scenarios shows the real trade-off of your financial decisions. Your net worth change over ${months} months is RM${simulation.netWorthDelta}. The biggest insight is that BNPL interest of RM${simulation.interestPaid} directly reduces what you can save. Alternative 1: Clear BNPL first before increasing savings. Alternative 2: Use the debt avalanche method — pay minimum on all BNPL and throw extra money at the highest interest one first.`;
};

//feature 3 4
const { defineSecret } = require("firebase-functions/params");
const ANTHROPIC_KEY = defineSecret("ANTHROPIC_API_KEY");

// Temporary mock — replace with real Anthropic call when credits ready
const askClaude = async (system, user) => {
  return "AI advice temporarily using mock. Real API coming soon.";
};

module.exports = {
  analyzeSpendingWithClaude,
  simulateFutureWithClaude,
  askClaude,        // ← F3 and F4 need this
  ANTHROPIC_KEY,    // ← F3 and F4 need this
  
};

