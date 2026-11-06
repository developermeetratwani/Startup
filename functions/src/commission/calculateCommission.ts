import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Firestore Trigger: calculateCommission
 * Triggered when an order status changes to 'delivered'.
 * Creates a commission record and updates vendor earning.
 */
export const calculateCommission = functions
  .region("asia-south1")
  .firestore.document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger on status change to 'delivered'
    if (before.status === after.status || after.status !== "delivered") return;

    const { orderId } = context.params;
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    // Check commission record doesn't already exist (idempotency)
    const existing = await db
      .collection("commissionRecords")
      .where("orderId", "==", orderId)
      .limit(1)
      .get();

    if (!existing.empty) {
      functions.logger.warn(`Commission already calculated for order ${orderId}`);
      return;
    }

    const pricing = after.pricing as Record<string, number>;
    const commissionRate: number = after.commissionRate ?? 0.10;

    const commissionRecord = {
      orderId,
      vendorId: after.vendorId,
      driverId: after.driverId ?? null,
      orderProductTotal: pricing.productTotal,
      commissionRate,
      commissionAmount: pricing.platformCommission,
      vendorEarning: pricing.vendorEarning,
      driverEarning: pricing.driverEarning ?? 0,
      settledAt: null,
      settlementId: null,
      createdAt: now,
    };

    await db.collection("commissionRecords").add(commissionRecord);
    functions.logger.info(`Commission recorded for order ${orderId}`);
  });
