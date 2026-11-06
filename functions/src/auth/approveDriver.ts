import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Callable: approveDriver
 * Admin approves a pending driver application.
 */
export const approveDriver = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (context.auth?.token.role !== "admin") {
      throw new functions.https.HttpsError("permission-denied", "Admins only.");
    }

    const { driverId } = data as { driverId: string };
    if (!driverId) {
      throw new functions.https.HttpsError("invalid-argument", "driverId required.");
    }

    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const driverSnap = await db.doc(`driverProfiles/${driverId}`).get();
    if (!driverSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Driver not found.");
    }

    await db.doc(`driverProfiles/${driverId}`).update({
      approvalStatus: "approved",
      approvedAt: now,
      approvedBy: context.auth!.uid,
      updatedAt: now,
    });

    // Set custom claims
    const user = await admin.auth().getUser(driverId);
    await admin.auth().setCustomUserClaims(driverId, {
      ...(user.customClaims ?? {}),
      role: "driver",
      driverId,
    });

    await db.doc(`users/${driverId}`).update({ role: "driver", updatedAt: now });

    functions.logger.info(`Driver approved: ${driverId}`);
    return { success: true };
  });
