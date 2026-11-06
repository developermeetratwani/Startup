import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createSettlement = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (context.auth?.token.role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Admin only.");
  }
  const { vendorId, amount } = data;
  const now = admin.firestore.FieldValue.serverTimestamp();
  const docRef = await admin.firestore().collection("settlements").add({
    vendorId,
    amount,
    status: "processed",
    createdAt: now,
  });
  return { success: true, settlementId: docRef.id };
});
