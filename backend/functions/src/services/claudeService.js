/**
 * FinMentor AI — Claude Service
 * 
 * NOTE: This is a temporary mock for testing Feature 1.
 * Replace the mock with real Anthropic API call when teammate sets up the full service.
 */

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

module.exports = {
  analyzeSpendingWithClaude,
};