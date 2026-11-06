import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Callable: cancelOrder
 * Allows customer or store to cancel an unfulfilled order.
 */
export const cancelOrder = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
    }

    const { orderId, reason } = data as { orderId: string; reason: string };
    if (!orderId) {
      throw new functions.https.HttpsError("invalid-argument", "Missing orderId.");
    }

    const db = admin.firestore();
    const orderDoc = await db.doc(`orders/${orderId}`).get();

    if (!orderDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Order not found.");
    }

    const order = orderDoc.data()!;
    const uid = context.auth.uid;

    // Check ownership (either customer, vendor, or admin)
    const isCustomer = order.customerId === uid;
    const isVendor = order.vendorId === uid;
    const isAdmin = context.auth.token.role === "admin";

    if (!isCustomer && !isVendor && !isAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Not authorized to cancel this order.");
    }

    // Check if order is in cancellable state
    if (!["pending", "confirmed"].includes(order.status)) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Order cannot be cancelled once preparation or delivery has started."
      );
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    await db.doc(`orders/${orderId}`).update({
      status: "cancelled",
      cancellationReason: reason || "Cancelled by user",
      cancelledBy: isCustomer ? "customer" : isVendor ? "vendor" : "admin",
      cancelledAt: now,
      updatedAt: now,
    });

    functions.logger.info(`Order cancelled: ${orderId} by ${uid}`);
    return { success: true };
  });
