/**
 * FinMentor AI — Financial Math Utilities
 *
 * IMPORTANT: All formulas here are intentionally matched to what the
 * Flutter screens calculate locally. When the Flutter screens are wired
 * to the backend, the numbers must be identical.
 *
 * Flutter formula references (per screen):
 *   F1 AnalyzerScreen:   pie total = expenses + bnpl + savings
 *                        bnplRatio = (bnpl/income)*100, warn if > 15
 *                        months insight = income / savings
 *   F2 SimulatorScreen:  savings rate = 3.5% annual (0.035/12 monthly)
 *                        debt = simple: principal - (i * monthlyPayment)
 *                        tabs: 'bnpl' | 'savings' | 'loan' (loan = same as bnpl)
 *   F3 BNPLScreen:       interestRate is PER MONTH (not annual)
 *                        totalInterest = principal * monthlyRate * months (FLAT)
 *                        totalRepayment = principal + totalInterest
 *                        monthly = totalRepayment / months
 *   F4 ResilienceScreen: score displayed out of 10 (not raw months)
 *                        6 months survivability = 10/10
 *                        stressTest = normal score * 0.77
 *                        survival days = scoreMonths * 30
 */

// ─────────────────────────────────────────────────────────────
// FEATURE 1 — AnalyzerScreen
// ─────────────────────────────────────────────────────────────
const calculateSpendingMetrics = ({ income, expenses, bnpl, savings }) => {
  const totalExpenses = expenses + bnpl;

  // Flutter pie chart center shows: expenses + bnpl + savings
  const pieTotal = expenses + bnpl + savings;

  const savingsRate = income > 0 ? (savings / income) * 100 : 0;

  // Flutter warning threshold: bnplRatio > 15 = risky
  const bnplBurden = income > 0 ? (bnpl / income) * 100 : 0;
  const isRisky = bnplBurden > 15;

  const disposableIncome = income - totalExpenses - savings;
  const expenseRatio = income > 0 ? (totalExpenses / income) * 100 : 100;

  // Flutter insight: "takes X months to save 1 month of income"
  const monthsToSaveOneMonth = savings > 0 ? round(income / savings) : null;

  // Risk scoring (unchanged from original)
  let riskScore = 0;
  if (savingsRate < 10) riskScore += 2;
  else if (savingsRate < 20) riskScore += 1;
  if (bnplBurden > 20) riskScore += 2;
  else if (bnplBurden > 10) riskScore += 1;
  if (expenseRatio > 90) riskScore += 2;
  else if (expenseRatio > 75) riskScore += 1;

  let riskLevel;
  if (riskScore >= 4) riskLevel = 'High';
  else if (riskScore >= 2) riskLevel = 'Medium';
  else riskLevel = 'Low';

  return {
    // Flutter pie chart fields
    pieTotal: round(pieTotal),             // center "TOTAL RM{pieTotal}"
    expensesSlice: round(expenses),        // blue slice
    bnplSlice: round(bnpl),               // red slice
    savingsSlice: round(savings),         // purple slice

    // Flutter insight card fields
    bnplBurden: parseFloat(bnplBurden.toFixed(2)),       // "BNPL is X% of income"
    isRisky,                                              // true if bnplBurden > 15
    monthsToSaveOneMonth,                                 // "takes X months to save 1 month"

    // Standard fields
    totalExpenses: round(totalExpenses),
    savingsRate: parseFloat(savingsRate.toFixed(2)),
    disposableIncome: parseFloat(disposableIncome.toFixed(2)),
    expenseRatio: parseFloat(expenseRatio.toFixed(2)),
    riskLevel,
    riskScore,
  };
};


// ─────────────────────────────────────────────────────────────
// FEATURE 2 — SimulatorScreen
// Flutter tabs: 'BNPL Purchase' → 'bnpl', 'Save More' → 'savings', 'Personal Loan' → 'loan'
// ─────────────────────────────────────────────────────────────
const computeFutureSimulation = ({ scenarioType, income, amount, months, interestRate = 0, existingSavings = 0 }) => {
  // 'loan' tab behaves identically to 'bnpl' tab in Flutter
  const effectiveType = scenarioType === 'loan' ? 'bnpl' : scenarioType;

  let debtProjection = [];
  let savingsProjection = [];
  let interestPaid = 0;
  let totalDebtPaid = 0;

  // ── Debt projection ──────────────────────────────────────
  // Flutter uses: remaining = principal - (i * monthlyPayment)  (simple, not amortizing)
  if (effectiveType === 'bnpl' || effectiveType === 'both') {
    const monthlyPayment = amount / months;

    for (let i = 1; i <= months; i++) {
      const remaining = Math.max(0, amount - (i * monthlyPayment));
      // Interest on remaining balance (Flutter uses interestRate as annual %)
      const monthlyRate = interestRate / 100 / 12;
      interestPaid += remaining * monthlyRate;
      debtProjection.push({
        month: i,
        balance: round(remaining),
        payment: round(monthlyPayment),
      });
    }
    totalDebtPaid = round(amount + interestPaid);
  }

  // ── Savings projection ────────────────────────────────────
  // Flutter uses: FV of annuity with 3.5% annual rate (0.035/12 monthly)
  if (effectiveType === 'savings' || effectiveType === 'both') {
    const rate = 0.035 / 12; // MUST match Flutter's hardcoded 3.5%
    let balance = existingSavings;

    for (let i = 1; i <= months; i++) {
      // Flutter formula: P * [((1+r)^n - 1) / r]  →  incremental version:
      balance = balance * (1 + rate) + amount;
      savingsProjection.push({ month: i, balance: round(balance) });
    }
  }

  // ── Summary metrics ───────────────────────────────────────
  const finalSavings = savingsProjection.length > 0
    ? savingsProjection[savingsProjection.length - 1].balance
    : existingSavings;

  const monthlyExpenses = income * 0.7;
  const emergencyScore = round(finalSavings / (monthlyExpenses || 1));

  let riskLevel;
  if (effectiveType === 'bnpl') {
    const overpaidPercent = amount > 0 ? (interestPaid / amount) * 100 : 0;
    riskLevel = overpaidPercent > 20 ? 'High' : overpaidPercent > 10 ? 'Medium' : 'Low';
  } else {
    riskLevel = emergencyScore >= 6 ? 'Low' : emergencyScore >= 3 ? 'Medium' : 'High';
  }

  // Flutter shows: NET IMPACT "+RM X" and SCORE Δ "+X pts"
  const netImpact = round(finalSavings - totalDebtPaid);
  const scoreDelta = round((finalSavings / (income * 0.7 || 1)) * 2); // rough pts estimate

  // chartData: Flutter LineChart uses {month, debt, savings}
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
    netWorthDelta: netImpact,
    netImpact,        // Flutter: "NET IMPACT +RM X"
    scoreDelta,       // Flutter: "SCORE Δ +X pts"
    riskLevel,
    chartData,
  };
};


// ─────────────────────────────────────────────────────────────
// FEATURE 3 — BNPLScreen
// Flutter formula: FLAT interest (p * r * t), NOT compound
// interestRate field = per MONTH percent (e.g. 1.5 = 1.5%/month)
// ─────────────────────────────────────────────────────────────
function computeBNPL(input) {
  const {
    amount,
    months,
    interestRate = 0,  // PER MONTH % — matches Flutter's "Interest (%/mo)" label
    lateFee = 0,
    lateMonths = 0,
  } = input;

  if (!amount || !months || amount <= 0 || months <= 0) {
    throw new Error('amount and months are required and must be positive.');
  }

  // Flutter: totalInterest = p * r * t  (r = interestRate/100, t = months)
  const r = interestRate / 100;
  const totalInterest = amount * r * months;          // FLAT — matches Flutter exactly
  const totalRepayment = amount + totalInterest;
  const monthlyInstallment = totalRepayment / months;

  // Late fees (backend-only, Flutter doesn't have these fields)
  const totalLateFees = lateMonths * lateFee;
  const grandTotal = totalRepayment + totalLateFees;
  const overpaid = grandTotal - amount;
  const overpaidPercent = amount > 0 ? (overpaid / amount) * 100 : 0;

  let riskLevel;
  if (overpaidPercent > 30) riskLevel = 'high';
  else if (overpaidPercent > 10) riskLevel = 'medium';
  else riskLevel = 'low';

  return {
    // Flutter field names (matches _calculateData() in BNPLScreen)
    principal: round(amount),
    interest: round(totalInterest),         // Flutter: "+ Interest: RM{interest}"
    total: round(totalRepayment),           // Flutter: "RM {total}" headline
    monthly: round(monthlyInstallment),     // Flutter: "RM {monthly} / month"

    // Extra fields for AI prompt and Firestore
    totalLateFees: round(totalLateFees),
    grandTotal: round(grandTotal),
    overpaid: round(overpaid),
    overpaidPercent: round(overpaidPercent),
    riskLevel,
  };
}


// ─────────────────────────────────────────────────────────────
// FEATURE 4 — ResilienceScreen
// Flutter displays score OUT OF 10, not raw months
// Flutter stress test toggle: score * 0.77
// Flutter 4 breakdown metrics are currently hardcoded — backend
// returns the same 4 categories dynamically
// ─────────────────────────────────────────────────────────────
function computeResilience(input) {
  const {
    savings,
    fixedExp,
    varExp = 0,
    insurance = 0,
    bnplDebt = 0,
    dependents = 0,
    income = 0,
  } = input;

  if (savings === undefined || fixedExp === undefined) {
    throw new Error('savings and fixedExp are required.');
  }

  const monthlyBurn = fixedExp + varExp + dependents * 300;
  const netAssets = savings + insurance * 0.5 - bnplDebt;
  const scoreMonths = monthlyBurn > 0 ? Math.max(0, netAssets / monthlyBurn) : 0;

  // Flutter shows score / 10 — scale: 6 months = perfect (10/10)
  const scoreOut10 = round(Math.min(scoreMonths / 6 * 10, 10));

  // Flutter stress test toggle multiplies score by ~0.77 (job loss scenario)
  const stressTestScore = round(scoreOut10 * 0.77);

  // Flutter text: "You can survive ~X months without income"
  // Flutter stress text: "you have X days of safety"
  const survivalMonths = round(scoreMonths);
  const survivalDays = Math.round(scoreMonths * 30);
  const stressDays = Math.round(scoreMonths * 0.77 * 30);

  // Resilience level
  let level;
  if (scoreMonths >= 6) level = 'resilient';
  else if (scoreMonths >= 3) level = 'moderate';
  else if (scoreMonths >= 1) level = 'vulnerable';
  else level = 'critical';

  // Flutter tag label
  const tagLabel = scoreOut10 >= 7
    ? '⚡ STRONG RESILIENCE'
    : scoreOut10 >= 5
    ? '⚡ MODERATE RESILIENCE'
    : '⚠️ HIGH RISK IN RECESSION';

  // ── 4 breakdown metrics — matches Flutter's hardcoded metrics list ──
  // Flutter shows: icon, title, score/10, color, description
  const debtToIncomeRatio = income > 0 ? round((bnplDebt / income) * 100) : 0;
  const savingsRate = income > 0 ? round((savings / income / 12) * 100) : 0; // rough monthly savings %

  // Emergency fund: how many months covered (target 6)
  const emergencyFundScore = round(Math.min(scoreMonths / 6 * 10, 10));
  const emergencyFundDesc = scoreMonths < 1
    ? `Covers ${survivalDays} days — critical, target: 6 months`
    : `Covers ${survivalMonths} months — target: 6 months`;

  // Insurance: rough score based on coverage vs monthly burn
  const insuranceCoverageMonths = monthlyBurn > 0 ? round(insurance / monthlyBurn) : 0;
  const insuranceScore = round(Math.min(insuranceCoverageMonths / 12 * 10, 10));
  const insuranceDesc = insurance === 0
    ? 'No insurance recorded — high exposure to shocks'
    : `Covers ~${insuranceCoverageMonths} months of expenses`;

  // Debt-to-income: lower is better, 0% = 10/10, 50%+ = 0/10
  const dtiScore = round(Math.max(0, 10 - (debtToIncomeRatio / 5)));
  const dtiDesc = debtToIncomeRatio === 0
    ? 'No BNPL debt — excellent position'
    : `${debtToIncomeRatio}% debt-to-income — ${debtToIncomeRatio < 30 ? 'manageable' : 'high risk'}`;

  // Monthly savings rate: 20% = 10/10
  const savingsScore = round(Math.min(savingsRate / 2, 10));
  const savingsDesc = savingsRate === 0
    ? 'No savings data provided'
    : `~${savingsRate}% of income saved — ${savingsRate >= 20 ? 'great habit!' : 'aim for 20%'}`;

  const breakdown = [
    { icon: '💰', title: 'Emergency Fund',   score: emergencyFundScore, description: emergencyFundDesc },
    { icon: '🛡️', title: 'Insurance Coverage', score: insuranceScore,   description: insuranceDesc },
    { icon: '📉', title: 'Debt-to-Income',   score: dtiScore,           description: dtiDesc },
    { icon: '💸', title: 'Monthly Savings',  score: savingsScore,       description: savingsDesc },
  ];

  // Savings gap to next level
  const targetMonths = scoreMonths < 1 ? 1 : scoreMonths < 3 ? 3 : scoreMonths < 6 ? 6 : 12;
  const targetAssets = targetMonths * monthlyBurn;
  const savingsGap = round(Math.max(0, targetAssets - netAssets));
  const monthsToTarget = monthlyBurn > 0 ? round(savingsGap / (income * 0.2 || 1)) : 0;

  // Next score milestone label (Flutter: "Path to 8.5 (Robust)")
  const nextScoreTarget = round(Math.min(scoreOut10 + 2, 10));
  const nextLevelLabel = nextScoreTarget >= 10 ? 'Perfect (10.0)' :
                         nextScoreTarget >= 8.5 ? 'Robust (8.5)' :
                         nextScoreTarget >= 7 ? 'Strong (7.0)' : 'Moderate (5.0)';

  return {
    // Flutter CircularProgressIndicator fields
    scoreOut10,                    // Flutter: score / 10 for progress, displayed as "X.X"
    stressTestScore,               // Flutter: stress toggle score
    tagLabel,                      // Flutter: AppTag label

    // Flutter description text
    survivalMonths,                // Flutter: "~X months without income"
    survivalDays,                  // Flutter normal display
    stressDays,                    // Flutter: "X days of safety" in stress mode

    // Flutter breakdown list (4 items, maps to _buildMetricsList)
    breakdown,

    // Flutter AI card
    nextLevelLabel,                // Flutter: "Path to X.X (Label)"
    savingsGap,                    // Flutter tip: "Boost emergency fund to RM{X}"

    // Raw values for AI prompt
    monthlyBurn: round(monthlyBurn),
    netAssets: round(netAssets),
    scoreMonths: round(scoreMonths),
    level,
    targetMonths,
    monthsToTarget,
  };
}


function round(n) {
  return Math.round(n * 100) / 100;
}

module.exports = { calculateSpendingMetrics, computeFutureSimulation, computeBNPL, computeResilience };

