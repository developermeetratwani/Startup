import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const attributeReferral = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { referralCode } = data;
  const db = admin.firestore();

  const codeDoc = await db.doc(`referralCodes/${referralCode}`).get();
  if (!codeDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Invalid referral code.");
  }

  const { vendorId } = codeDoc.data()!;
  await db.doc(`customerProfiles/${context.auth.uid}`).update({
    referredByVendorId: vendorId,
    referralAttributedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, vendorId };
});

export const issueCoins = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (context.auth?.token.role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Admin only.");
  }
  const { vendorId, amount, reason } = data;
  const db = admin.firestore();

  await db.doc(`storeCoins/${vendorId}`).update({
    balance: admin.firestore.FieldValue.increment(amount),
    totalEarned: admin.firestore.FieldValue.increment(amount),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection("coinTransactions").add({
    vendorId,
    type: "credit",
    amount,
    reason: reason || "referral_reward",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
