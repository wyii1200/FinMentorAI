/**
 * FinMentor AI — Cloud Functions Entry Point
 * Initializes Firebase Admin and exports all function handlers.
 */

const admin = require("firebase-admin");
admin.initializeApp();

const { analyzeSpending } = require('./handlers/analyzeSpending');
const { simulateFuture } = require('./handlers/simulateFuture');
const { analyzeBNPL } = require("./handlers/analyzeBNPL");
const { calcResilience } = require("./handlers/calcResilience");
const { authenticate } = require('./middleware/authMiddleware');
const { rateLimiter } = require('./middleware/rateLimiter');

module.exports = {
  analyzeSpending,
  simulateFuture,
  analyzeBNPL,
  calcResilience,
};