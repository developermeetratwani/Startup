import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Triggered when a new Firebase Auth user is created.
 * Creates the base /users/{uid} document and sets default role = 'customer'.
 */
export const onUserCreate = functions
  .region("asia-south1")
  .auth.user()
  .onCreate(async (user) => {
    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const userData = {
      uid: user.uid,
      email: user.email ?? null,
      phone: user.phoneNumber ?? null,
      role: "customer",
      displayName: user.displayName ?? user.email?.split("@")[0] ?? "User",
      photoUrl: user.photoURL ?? null,
      isActive: true,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    };

    // Write base user doc
    await db.doc(`users/${user.uid}`).set(userData);

    // Write customer profile
    await db.doc(`customerProfiles/${user.uid}`).set({
      userId: user.uid,
      fullName: userData.displayName,
      defaultAddressId: null,
      referredByVendorId: null,
      referralAttributedAt: null,
      totalOrders: 0,
      createdAt: now,
      updatedAt: now,
    });

    // Set custom claim: role = customer
    await admin.auth().setCustomUserClaims(user.uid, { role: "customer" });

    functions.logger.info(`User created: ${user.uid} role=customer`);
  });
