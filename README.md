# FinMentor AI

FinMentor AI is a financial wellness platform designed to help users navigate their personal finances with the power of AI. It provides deep insights into spending habits, evaluates the risks of Buy Now, Pay Later (BNPL) schemes, simulates future financial scenarios, and calculates financial resilience.

## 🚀 Key Features

### 1. AI Spending Analyzer
Analyzes your monthly income, fixed expenses, and BNPL commitments. It provides a detailed breakdown of your financial health and uses AI to offer personalized advice on how to optimize your spending.

### 2. "Future You" Financial Simulator
Visualizes the long-term impact of your financial decisions. Whether it's taking on new debt or increasing your savings, this tool projects your financial future over months and years, accompanied by an AI-driven narrative.

### 3. BNPL & Loan Risk Explainer
Demystifies the true cost of "zero-interest" loans and BNPL purchases. It calculates total overpayment, late fees, and grand totals, while AI explains the specific risks associated with your purchase.

### 4. Financial Resilience Score
Measures your "Financial Runway"—how many months you can sustain your current lifestyle if your income stops today. It provides a Resilience Level (e.g., Vulnerable, Solid, Fortress) and an AI-generated action plan to improve your stability.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js (Firebase Cloud Functions)
- **Database:** Google Cloud Firestore
- **Authentication:** Firebase Authentication

### How to Run

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd FinMentorAI
   ```

2. Install Frontend Dependencies:
   ```bash
    flutter pub get

3. Enable Developer Mode / Tools

   **Windows**
   - Open Settings → System → Advanced
   - Scroll to For developers section
   - Toggle Developer Mode to On
   - Allows installation of apps from any source and enables debugging

   **macOS**
   - Open System Settings → Privacy & Security
   - Scroll to Developer Tools
   - Allow Flutter and your IDE to run apps and debugging
   - Ensure Terminal/IDE has permissions for local app execution

   **Linux**
   - Ensure Flutter SDK is installed and added to PATH
   - Install required packages (Ubuntu example):
     ```bash
      sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   - Ensure your user can run apps and access local devices

4. Run Flutter App
   ```bash
    flutter run

## Demo Video Link
https://youtu.be/Aj_NBdZVnos

## 🤖 AI Disclosure

This project concept includes an AI-powered financial advisor component. However, within the hackathon prototype, the analysis and simulations are implemented using rule-based logic and mathematical calculations (such as spending ratios, savings projections, and compound interest formulas) rather than a deployed AI model.

AI tools such as ChatGPT and Gemini were used only for ideation, technical guidance, and documentation assistance during development. No external AI APIs or machine learning models are currently integrated into the application.

Future versions of the project may integrate large language models to generate personalized financial explanations and advice.
