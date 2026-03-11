/**
 * FinMentor AI — Input Validators
 *
 * Changes from original:
 *   F2: validateSimulationInput now accepts 'loan' as valid scenarioType
 *       (Flutter SimulatorScreen tab 3 = 'Personal Loan' → sends 'loan')
 *   F3: validateBNPLInput now accepts 'duration' as alias for 'months'
 *       (Flutter BNPLScreen field is labelled "Duration (Months)")
 */

// ── Feature 1 — AnalyzerScreen ────────────────────────────────
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
  return null;
};

// ── Feature 2 — SimulatorScreen ───────────────────────────────
// Flutter tabs: 'bnpl' | 'savings' | 'loan'  (loan added for Personal Loan tab)
const validateSimulationInput = ({ scenarioType, income, amount, months }) => {
  if (!scenarioType) return 'scenarioType is required';
  if (!['bnpl', 'savings', 'both', 'loan'].includes(scenarioType))
    return 'scenarioType must be bnpl, savings, loan, or both';
  if (income === undefined || income === null) return 'income is required';
  if (amount === undefined || amount === null) return 'amount is required';
  if (months === undefined || months === null) return 'months is required';
  if (typeof income !== 'number' || income <= 0) return 'income must be a positive number';
  if (typeof amount !== 'number' || amount <= 0) return 'amount must be a positive number';
  if (typeof months !== 'number' || months <= 0 || !Number.isInteger(months))
    return 'months must be a positive integer';
  if (months > 120) return 'months cannot exceed 120 (10 years)';
  return null;
};

// ── Feature 3 — BNPLScreen ────────────────────────────────────
// Flutter field: "Duration (Months)" → body may have 'duration' OR 'months'
// Handler normalises to 'months' before calling validator.
function validateBNPLInput(body) {
  const amount = body.amount;
  const months = body.months ?? body.duration;  // accept either field name

  if (amount === undefined || amount === null)
    return { valid: false, error: 'amount is required.' };
  if (months === undefined || months === null)
    return { valid: false, error: 'months (or duration) is required.' };
  if (typeof amount !== 'number' || amount <= 0)
    return { valid: false, error: 'amount must be a positive number.' };
  if (typeof months !== 'number' || months <= 0 || !Number.isInteger(months))
    return { valid: false, error: 'months must be a positive integer.' };
  if (body.interestRate !== undefined &&
      (typeof body.interestRate !== 'number' || body.interestRate < 0))
    return { valid: false, error: 'interestRate must be a non-negative number.' };
  if (body.lateFee !== undefined &&
      (typeof body.lateFee !== 'number' || body.lateFee < 0))
    return { valid: false, error: 'lateFee must be a non-negative number.' };

  return { valid: true };
}

// ── Feature 4 — ResilienceScreen ─────────────────────────────
function validateResilienceInput(body) {
  const { savings, fixedExp } = body;

  if (savings === undefined || savings === null)
    return { valid: false, error: 'savings is required.' };
  if (fixedExp === undefined || fixedExp === null)
    return { valid: false, error: 'fixedExp is required.' };
  if (typeof savings !== 'number' || savings < 0)
    return { valid: false, error: 'savings must be a non-negative number.' };
  if (typeof fixedExp !== 'number' || fixedExp < 0)
    return { valid: false, error: 'fixedExp must be a non-negative number.' };
  if (body.income !== undefined &&
      (typeof body.income !== 'number' || body.income < 0))
    return { valid: false, error: 'income must be a non-negative number.' };

  return { valid: true };
}



module.exports = {
  validateSpendingInput,
  validateSimulationInput,
  validateBNPLInput,
  validateResilienceInput,
};

