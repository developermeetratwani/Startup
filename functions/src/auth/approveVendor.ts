import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Callable: approveVendor
 * Admin approves a pending vendor. Sets role, creates store stub, issues referral code.
 */
export const approveVendor = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (context.auth?.token.role !== "admin") {
      throw new functions.https.HttpsError("permission-denied", "Admins only.");
    }

    const { vendorId } = data as { vendorId: string };
    if (!vendorId) {
      throw new functions.https.HttpsError("invalid-argument", "vendorId required.");
    }

    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    // Get vendor profile
    const vendorSnap = await db.doc(`vendorProfiles/${vendorId}`).get();
    if (!vendorSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Vendor profile not found.");
    }
    const vendorData = vendorSnap.data()!;

    // Generate a unique store ID
    const storeRef = db.collection("stores").doc();
    const storeId = storeRef.id;

    // Generate referral code (6 chars)
    const referralCode = generateReferralCode(vendorId);

    // Run all writes in a batch
    const batch = db.batch();

    // Create store stub
    batch.set(storeRef, {
      vendorId,
      name: vendorData.businessName,
      description: "",
      bannerImageUrl: null,
      logoImageUrl: null,
      categoryIds: [],
      location: null,         // Vendor sets this in their app
      operatingHours: {},
      isOpen: false,
      isActive: true,
      isDeleted: false,
      rating: 0,
      totalRatings: 0,
      createdAt: now,
      updatedAt: now,
    });

    // Update vendor profile
    batch.update(db.doc(`vendorProfiles/${vendorId}`), {
      approvalStatus: "approved",
      approvedAt: now,
      approvedBy: context.auth!.uid,
      storeId,
      referralCode,
      updatedAt: now,
    });

    // Create referral code doc
    batch.set(db.doc(`referralCodes/${referralCode}`), {
      code: referralCode,
      vendorId,
      storeId,
      isActive: true,
      totalUses: 0,
      createdAt: now,
    });

    // Create storeCoins balance
    batch.set(db.doc(`storeCoins/${vendorId}`), {
      vendorId,
      balance: 0,
      totalEarned: 0,
      totalRedeemed: 0,
      updatedAt: now,
    });

    await batch.commit();

    // Set custom claims: role=vendor + storeId
    const user = await admin.auth().getUser(vendorId);
    const existingClaims = user.customClaims ?? {};
    await admin.auth().setCustomUserClaims(vendorId, {
      ...existingClaims,
      role: "vendor",
      storeId,
      vendorId,
    });

    // Update user role
    await db.doc(`users/${vendorId}`).update({ role: "vendor", updatedAt: now });

    functions.logger.info(`Vendor approved: ${vendorId}, store: ${storeId}`);
    return { success: true, storeId, referralCode };
  });

function generateReferralCode(vendorId: string): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const seed = vendorId.slice(-4).toUpperCase();
  let code = seed;
  while (code.length < 8) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}
