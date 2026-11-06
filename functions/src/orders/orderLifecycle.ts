import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const acceptOrder = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { orderId } = data;
  await admin.firestore().doc(`orders/${orderId}`).update({
    status: "confirmed",
    confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});

export const rejectOrder = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { orderId, reason } = data;
  await admin.firestore().doc(`orders/${orderId}`).update({
    status: "cancelled",
    cancellationReason: reason || "Store declined order",
    cancelledBy: "vendor",
    cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});

export const completeOrder = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { orderId } = data;
  await admin.firestore().doc(`orders/${orderId}`).update({
    status: "delivered",
    deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});
