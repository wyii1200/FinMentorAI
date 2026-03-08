/**
 * FinMentor AI — Financial Math Utilities
 *
 * WHY these are separate from AI:
 * Math is deterministic — it should always give the same answer instantly.
 * Running math through AI would be: slower, more expensive, and occasionally wrong.
 * So we compute all numbers here first, then pass the results to Claude
 * only for the explanation and personalized advice.
 *
 * All amounts are in Malaysian Ringgit (RM) by default,
 * but the math is currency-agnostic.
 */

//Analyaze Spending (Feature 1)
const calculateSpendingMetrics = ({ income, expenses, bnpl, savings }) => {
  const totalExpenses = expenses + bnpl;
  const savingsRate = income > 0 ? (savings / income) * 100 : 0;
  const bnplBurden = income > 0 ? (bnpl / income) * 100 : 0;
  const disposableIncome = income - totalExpenses - savings;

  // Risk scoring
  let riskScore = 0;

  if (savingsRate < 10) riskScore += 2;
  else if (savingsRate < 20) riskScore += 1;

  if (bnplBurden > 20) riskScore += 2;
  else if (bnplBurden > 10) riskScore += 1;

  const expenseRatio = income > 0 ? (totalExpenses / income) * 100 : 100;
  if (expenseRatio > 90) riskScore += 2;
  else if (expenseRatio > 75) riskScore += 1;

  let riskLevel;
  if (riskScore >= 4) riskLevel = 'High';
  else if (riskScore >= 2) riskLevel = 'Medium';
  else riskLevel = 'Low';

  return {
    savingsRate: parseFloat(savingsRate.toFixed(2)),
    bnplBurden: parseFloat(bnplBurden.toFixed(2)),
    disposableIncome: parseFloat(disposableIncome.toFixed(2)),
    expenseRatio: parseFloat(expenseRatio.toFixed(2)),
    riskLevel,
    riskScore,
  };
};

//future simulator (Feature 2) 
const computeFutureSimulation = ({ scenarioType, income, amount, months, interestRate = 0, existingSavings = 0 }) => {
  const monthlyRate = interestRate / 100 / 12;
  
  let debtProjection = [];
  let savingsProjection = [];
  let interestPaid = 0;
  let totalDebtPaid = 0;

  // Debt projection (BNPL scenario)
  if (scenarioType === 'bnpl' || scenarioType === 'both') {
    let balance = amount;
    const monthlyPayment = monthlyRate > 0
      ? (amount * monthlyRate) / (1 - Math.pow(1 + monthlyRate, -months))
      : amount / months;

    for (let i = 1; i <= months; i++) {
      const interestCharge = balance * monthlyRate;
      interestPaid += interestCharge;
      balance = Math.max(0, balance - monthlyPayment + interestCharge);
      debtProjection.push({ month: i, balance: round(balance), payment: round(monthlyPayment) });
    }
    totalDebtPaid = round(amount + interestPaid);
  }

  // Savings projection (savings scenario)
  if (scenarioType === 'savings' || scenarioType === 'both') {
    const annualRate = 0.04; // 4% annual return (conservative EPF-like)
    const monthlyGrowthRate = annualRate / 12;
    let balance = existingSavings;

    for (let i = 1; i <= months; i++) {
      balance = balance * (1 + monthlyGrowthRate) + amount;
      savingsProjection.push({ month: i, balance: round(balance) });
    }
  }

  // Emergency fund score
  const finalSavings = savingsProjection.length > 0
    ? savingsProjection[savingsProjection.length - 1].balance
    : existingSavings;
  const monthlyExpenses = income * 0.7; // estimate 70% of income as expenses
  const emergencyScore = round(finalSavings / (monthlyExpenses || 1));

  // Risk level
  let riskLevel;
  if (scenarioType === 'bnpl') {
    const overpaidPercent = amount > 0 ? (interestPaid / amount) * 100 : 0;
    riskLevel = overpaidPercent > 20 ? 'High' : overpaidPercent > 10 ? 'Medium' : 'Low';
  } else {
    riskLevel = emergencyScore >= 6 ? 'Low' : emergencyScore >= 3 ? 'Medium' : 'High';
  }

  // Chart data formatted for frontend
  const chartData = Array.from({ length: months }, (_, i) => ({
    month: i + 1,
    debt: debtProjection[i]?.balance ?? null,
    savings: savingsProjection[i]?.balance ?? null,
  }));

  return {
    debtProjection,
    savingsProjection,
    emergencyScore,
    interestPaid: round(interestPaid),
    netWorthDelta: round(finalSavings - totalDebtPaid),
    riskLevel,
    chartData,
  };
};


/**
 * BNPL / Loan cost breakdown (Feature 3)
 *
 * @param {object} input
 * @param {number} input.amount        - Principal amount (RM)
 * @param {number} input.months        - Repayment tenure in months
 * @param {number} [input.interestRate=0] - Annual interest / processing fee %
 * @param {number} [input.lateFee=0]   - Late payment fee per month (RM)
 * @param {number} [input.lateMonths=0] - How many months the user pays late
 * @returns {object} Computed breakdown
 */
function computeBNPL(input) {
  const {
    amount,
    months,
    interestRate = 0,
    lateFee = 0,
    lateMonths = 0,
  } = input;

  if (!amount || !months || amount <= 0 || months <= 0) {
    throw new Error("amount and months are required and must be positive.");
  }

  const monthlyPayment = amount / months;
  const totalRepayment = amount * (1 + interestRate / 100);
  const totalLateFees = lateMonths * lateFee;
  const grandTotal = totalRepayment + totalLateFees;
  const overpaid = grandTotal - amount;
  const overpaidPercent = (overpaid / amount) * 100;

  // Risk classification based on how much extra the user pays vs the cash price
  let riskLevel;
  if (overpaidPercent > 30) {
    riskLevel = "high";
  } else if (overpaidPercent > 10) {
    riskLevel = "medium";
  } else {
    riskLevel = "low";
  }

  return {
    monthlyPayment: round(monthlyPayment),
    totalRepayment: round(totalRepayment),
    totalLateFees: round(totalLateFees),
    grandTotal: round(grandTotal),
    overpaid: round(overpaid),
    overpaidPercent: round(overpaidPercent),
    riskLevel,
  };
}

/**
 * Financial Resilience Score (Feature 4)
 *
 * Formula:
 *   monthlyBurn  = fixedExpenses + variableExpenses + (dependents × RM300)
 *   netAssets    = savings + (insurance × 0.5) − totalDebt
 *   scoreMonths  = netAssets / monthlyBurn
 *
 * The insurance × 0.5 discount accounts for the fact that insurance
 * payouts are not always liquid or immediately accessible.
 * RM300/dependent is a conservative ASEAN monthly cost estimate.
 *
 * @param {object} input
 * @param {number} input.savings       - Total savings / emergency fund (RM)
 * @param {number} input.fixedExp      - Fixed monthly expenses (rent, bills, RM)
 * @param {number} [input.varExp=0]    - Variable monthly expenses (food, transport, RM)
 * @param {number} [input.insurance=0] - Insurance coverage available (RM)
 * @param {number} [input.bnplDebt=0]  - Total outstanding BNPL/loan debt (RM)
 * @param {number} [input.dependents=0] - Number of financial dependents
 * @returns {object} Computed resilience metrics
 */
function computeResilience(input) {
  const {
    savings,
    fixedExp,
    varExp = 0,
    insurance = 0,
    bnplDebt = 0,
    dependents = 0,
  } = input;

  if (savings === undefined || fixedExp === undefined) {
    throw new Error("savings and fixedExp are required.");
  }

  const monthlyBurn = fixedExp + varExp + dependents * 300;
  const netAssets = savings + insurance * 0.5 - bnplDebt;
  const scoreMonths = monthlyBurn > 0 ? Math.max(0, netAssets / monthlyBurn) : 0;

  // Resilience level mirrors ASEAN disaster protection gap research:
  // 6+ months = international best practice emergency fund
  let level;
  if (scoreMonths >= 6) {
    level = "resilient";
  } else if (scoreMonths >= 3) {
    level = "moderate";
  } else if (scoreMonths >= 1) {
    level = "vulnerable";
  } else {
    level = "critical";
  }

  // Savings gap: how much more the user needs to reach the next level
  const targetMonths = scoreMonths < 1 ? 1 : scoreMonths < 3 ? 3 : scoreMonths < 6 ? 6 : 12;
  const targetAssets = targetMonths * monthlyBurn;
  const savingsGap = Math.max(0, targetAssets - netAssets);
  const monthsToTarget = monthlyBurn > 0 ? savingsGap / (input.income * 0.2 || 1) : 0;

  return {
    monthlyBurn: round(monthlyBurn),
    netAssets: round(netAssets),
    scoreMonths: round(scoreMonths),
    level,
    targetMonths,
    savingsGap: round(savingsGap),
    monthsToTarget: round(monthsToTarget),
  };
}

// Round to 2 decimal places
function round(n) {
  return Math.round(n * 100) / 100;
}

module.exports = {calculateSpendingMetrics,computeFutureSimulation, computeBNPL, computeResilience };

