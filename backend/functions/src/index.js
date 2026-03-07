/**
 * FinMentor AI — Cloud Functions Entry Point
 * Initializes Firebase Admin and exports all function handlers.
 */

const admin = require("firebase-admin");
admin.initializeApp();

const { analyzeBNPL } = require("./handlers/analyzeBNPL");
const { calcResilience } = require("./handlers/calcResilience");

module.exports = {
  analyzeBNPL,
  calcResilience,
};
