/**
 * FinMentor AI — Input Validators
 *
 * WHY: Never trust user input, even from your own frontend.
 * These validators run before any math or AI call,
 * returning clear error messages if required fields are missing or invalid.
 */

//analyze Spending (Feature 1)
const validateSpendingInput = ({ income, expenses, bnpl, savings }) => {
  if (income === undefined || income === null) return 'Income is required';
  if (expenses === undefined || expenses === null) return 'Expenses is required';
  if (bnpl === undefined || bnpl === null) return 'BNPL amount is required';
  if (savings === undefined || savings === null) return 'Savings amount is required';

  if (typeof income !== 'number' || income < 0) return 'Income must be a positive number';
  if (typeof expenses !== 'number' || expenses < 0) return 'Expenses must be a positive number';
  if (typeof bnpl !== 'number' || bnpl < 0) return 'BNPL must be a positive number';
  if (typeof savings !== 'number' || savings < 0) return 'Savings must be a positive number';

  if (expenses + bnpl + savings > income * 2) return 'Expenses seem unrealistically high, please check your input';

  return null; // no error
};

//feature 2
const validateSimulationInput = ({ scenarioType, income, amount, months }) => {
  if (!scenarioType) return 'scenarioType is required';
  if (!['bnpl', 'savings', 'both'].includes(scenarioType)) return 'scenarioType must be bnpl, savings, or both';
  if (income === undefined || income === null) return 'income is required';
  if (amount === undefined || amount === null) return 'amount is required';
  if (months === undefined || months === null) return 'months is required';
  if (typeof income !== 'number' || income <= 0) return 'income must be a positive number';
  if (typeof amount !== 'number' || amount <= 0) return 'amount must be a positive number';
  if (typeof months !== 'number' || months <= 0 || !Number.isInteger(months)) return 'months must be a positive integer';
  if (months > 120) return 'months cannot exceed 120 (10 years)';
  return null;
};



/**
 * Validate BNPL analysis input (Feature 3)
 * @param {object} body - req.body
 * @returns {{ valid: boolean, error?: string }}
 */
function validateBNPLInput(body) {
  const { amount, months } = body;

  if (amount === undefined || amount === null) {
    return { valid: false, error: "amount is required." };
  }
  if (months === undefined || months === null) {
    return { valid: false, error: "months is required." };
  }
  if (typeof amount !== "number" || amount <= 0) {
    return { valid: false, error: "amount must be a positive number." };
  }
  if (typeof months !== "number" || months <= 0 || !Number.isInteger(months)) {
    return { valid: false, error: "months must be a positive integer." };
  }
  if (body.interestRate !== undefined && (typeof body.interestRate !== "number" || body.interestRate < 0)) {
    return { valid: false, error: "interestRate must be a non-negative number." };
  }
  if (body.lateFee !== undefined && (typeof body.lateFee !== "number" || body.lateFee < 0)) {
    return { valid: false, error: "lateFee must be a non-negative number." };
  }

  return { valid: true };
}

/**
 * Validate resilience score input (Feature 4)
 * @param {object} body - req.body
 * @returns {{ valid: boolean, error?: string }}
 */
function validateResilienceInput(body) {
  const { savings, fixedExp } = body;

  if (savings === undefined || savings === null) {
    return { valid: false, error: "savings is required." };
  }
  if (fixedExp === undefined || fixedExp === null) {
    return { valid: false, error: "fixedExp is required." };
  }
  if (typeof savings !== "number" || savings < 0) {
    return { valid: false, error: "savings must be a non-negative number." };
  }
  if (typeof fixedExp !== "number" || fixedExp < 0) {
    return { valid: false, error: "fixedExp must be a non-negative number." };
  }
  if (body.income !== undefined && (typeof body.income !== "number" || body.income < 0)) {
    return { valid: false, error: "income must be a non-negative number." };
  }

  return { valid: true };
}

module.exports = {validateSpendingInput,validateSimulationInput, validateBNPLInput, validateResilienceInput, validateSimulationInput};

