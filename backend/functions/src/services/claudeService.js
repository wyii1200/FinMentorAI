/**
 * FinMentor AI — Claude Service
 * 
 * NOTE: This is a temporary mock for testing Feature 1.
 * Replace the mock with real Anthropic API call when teammate sets up the full service.
 */

const Anthropic = require('@anthropic-ai/sdk');
const { buildSpendingAnalysisPrompt } = require('../utils/prompts');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const analyzeSpendingWithClaude = async ({ income, expenses, bnpl, savings, metrics }) => {
  const prompt = buildSpendingAnalysisPrompt({ income, expenses, bnpl, savings, metrics });

  const message = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 400,
    messages: [
      { role: 'user', content: prompt }
    ],
  });

  return message.content[0].text;
};

module.exports = {
  analyzeSpendingWithClaude,
};
