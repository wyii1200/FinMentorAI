# 💰 FinMentor AI

FinMentor AI is a financial wellness platform designed to help users navigate their personal finances with the power of AI. It provides insights into spending habits, evaluates the risks of Buy Now Pay Later (BNPL) schemes, simulates future financial scenarios, and calculates financial resilience.

---

## 🚀 Key Features

### 1. AI Spending Analyzer
Analyzes monthly income, fixed expenses, and BNPL commitments to provide a breakdown of financial health and suggestions for optimizing spending.

### 2. Future You Financial Simulator
Projects how financial decisions today affect the future. Users can simulate scenarios such as increasing savings, taking new debt, or changing spending habits.

### 3. BNPL & Loan Risk Explainer
Helps users understand the hidden costs behind Buy Now Pay Later (BNPL) services and loans.

The system calculates:
- Total repayment amount
- Possible late fees
- Overall financial impact

It also provides simplified explanations of financial risks.

### 4. Financial Resilience Score
Measures your **Financial Runway** — how many months you can sustain your lifestyle if income stops.

Resilience levels include:
- Vulnerable
- Moderate
- Solid
- Fortress

The system also provides suggestions to improve financial stability.

---

# 🛠 Tech Stack

### Frontend
- Flutter (Dart)

### Backend
- Node.js (Firebase Cloud Functions)

### Database
- Google Cloud Firestore

### Authentication
- Firebase Authentication

---

# ▶️ Running the Project

## 1. Clone the Repository

```bash
git clone <repository-url>
cd FinMentorAI
```

---

## 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

## 3. Run the Application

```bash
flutter run
```

After running the command, Flutter will prompt you to select a device.

Example:

```
1 - Windows
2 - Chrome
3 - Edge
```

### Device Options

**Chrome**
- Recommended for quick testing
- Runs the application as a web app

**Mobile Emulator / Virtual Device**
- Best option for testing the mobile experience

**Windows**
- Runs the application as a desktop app

---

# ⚙️ Developer Mode / System Requirements

### Windows (for Desktop Development)

1. Open **Settings**
2. Navigate to **System → For Developers**
3. Enable **Developer Mode**

This allows installation and debugging of local applications.

---

### macOS (for Development & Debugging)

1. Open **System Settings**
2. Go to **Privacy & Security**
3. Scroll to **Developer Tools**
4. Allow your **Terminal / IDE (VS Code, Android Studio)** to run and debug applications

Ensure Flutter and your IDE have permission to run local applications.

---

### Linux (for Desktop Development)

Ensure Flutter SDK is installed and added to your system `PATH`.

For Ubuntu-based systems install required dependencies:

```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

This allows Flutter to build and run Linux desktop applications.

---

# 🎥 Demo Video

https://youtu.be/Aj_NBdZVnos

---

# 🤖 AI Disclosure

FinMentor AI is designed as an AI-powered financial advisor concept.

However, within this hackathon prototype, the analysis and simulations are implemented using **rule-based logic and financial calculations** rather than a deployed AI model.

Examples include:

- Spending ratio analysis
- Savings projections
- Financial resilience scoring

AI tools such as **ChatGPT** and **Gemini** were used during development for:

- Ideation
- Technical guidance
- Documentation assistance

No external AI APIs or machine learning models are currently integrated into the application.

Future versions may integrate **large language models (LLMs)** to generate personalized financial explanations and advice.
