import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createRazorpayOrder = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { amount } = data; // in paise
  // Razorpay integration stub
  return { success: true, razorpayOrderId: `rzp_order_${Date.now()}`, amount };
});

export const verifyPayment = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { orderId, razorpayPaymentId } = data;
  await admin.firestore().doc(`orders/${orderId}`).update({
    paymentStatus: "paid",
    razorpayPaymentId,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});

export const processRefund = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");
  const { orderId } = data;
  await admin.firestore().doc(`orders/${orderId}`).update({
    paymentStatus: "refunded",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});
