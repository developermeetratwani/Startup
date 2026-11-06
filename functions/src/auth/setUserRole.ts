import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Callable: setUserRole
 * Admin-only. Sets a user's Firebase custom claim role.
 */
export const setUserRole = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    // Only admins can call this
    if (context.auth?.token.role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can assign roles."
      );
    }

    const { uid, role } = data as { uid: string; role: string };
    const allowedRoles = ["customer", "vendor", "driver", "admin"];

    if (!uid || !allowedRoles.includes(role)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid uid or role."
      );
    }

    // Get existing claims to merge
    const user = await admin.auth().getUser(uid);
    const existingClaims = user.customClaims ?? {};

    await admin.auth().setCustomUserClaims(uid, { ...existingClaims, role });
    await admin.firestore().doc(`users/${uid}`).update({
      role,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`Role updated: ${uid} -> ${role}`);
    return { success: true };
  });
