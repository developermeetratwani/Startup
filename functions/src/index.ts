import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Initialize Firebase Admin SDK once
admin.initializeApp();

// ── Auth Triggers ───────────────────────────────────────────────
export * from "./auth/onCreate";
export * from "./auth/setUserRole";
export * from "./auth/approveVendor";
export * from "./auth/approveDriver";

// ── Order Functions ─────────────────────────────────────────────
export * from "./orders/createOrder";
export * from "./orders/acceptOrder";
export * from "./orders/rejectOrder";
export * from "./orders/cancelOrder";
export * from "./orders/completeOrder";

// ── Payment Functions ───────────────────────────────────────────
export * from "./payments/createRazorpayOrder";
export * from "./payments/verifyPayment";
export * from "./payments/processRefund";

// ── Commission & Settlement ─────────────────────────────────────
export * from "./commission/calculateCommission";
export * from "./commission/createSettlement";

// ── Referral System ─────────────────────────────────────────────
export * from "./referrals/attributeReferral";
export * from "./referrals/issueCoins";

// ── Notifications ───────────────────────────────────────────────
export * from "./notifications/sendNotification";

// Suppress unused import warning
void functions;
