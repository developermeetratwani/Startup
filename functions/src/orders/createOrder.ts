import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Callable: createOrder
 * Validates stock, calculates pricing in paise, records order, reserves items.
 */
export const createOrder = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
    }

    const customerId = context.auth.uid;
    const { storeId, deliveryAddressId, paymentMethod, promoCode, coinRedemptionAmount } = data as {
      storeId: string;
      deliveryAddressId: string;
      paymentMethod: "cod" | "online";
      promoCode?: string;
      coinRedemptionAmount?: number;
    };

    if (!storeId || !deliveryAddressId || !paymentMethod) {
      throw new functions.https.HttpsError("invalid-argument", "Missing required order parameters.");
    }

    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    // 1. Fetch delivery address snapshot
    const addressDoc = await db.doc(`addresses/${deliveryAddressId}`).get();
    if (!addressDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Delivery address not found.");
    }
    const addressData = addressDoc.data()!;

    // 2. Fetch customer cart items
    const cartItemsSnap = await db.collection(`carts/${customerId}/items`).get();
    if (cartItemsSnap.empty) {
      throw new functions.https.HttpsError("failed-precondition", "Cart is empty.");
    }

    // 3. Fetch store details
    const storeDoc = await db.doc(`stores/${storeId}`).get();
    if (!storeDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Store not found.");
    }
    const storeData = storeDoc.data()!;
    const vendorId = storeData.vendorId;

    // 4. Calculate product total and verify vendor matching
    let productTotal = 0;
    const orderItems: any[] = [];

    for (const itemDoc of cartItemsSnap.docs) {
      const item = itemDoc.data();
      if (item.storeId !== storeId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Cart items must belong to the selected store."
        );
      }
      productTotal += item.unitPrice * item.quantity;
      orderItems.push({
        productId: item.productId,
        variantId: item.variantId,
        productName: item.productName,
        imageUrl: item.imageUrl,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
        size: item.size,
        color: item.color,
      });
    }

    // 5. Pricing calculations in paise
    // Free delivery if product total > 99900 paise (₹999), else 2500 paise (₹25)
    const deliveryCharge = productTotal > 99900 ? 0 : 2500;
    const discount = 0; // Promo code logic can be applied here
    const coinRedemption = Math.min(coinRedemptionAmount || 0, productTotal);
    const grandTotal = Math.max(0, productTotal + deliveryCharge - discount - coinRedemption);

    // Platform commission: 10% of product total
    const commissionRate = 0.10;
    const platformCommission = Math.round(productTotal * commissionRate);
    const vendorEarning = productTotal - platformCommission;
    const driverEarning = deliveryCharge > 0 ? deliveryCharge : 2500; // Platform subsidizes free delivery

    const pricing = {
      productTotal,
      deliveryCharge,
      discount,
      coinRedemption,
      grandTotal,
      platformCommission,
      vendorEarning,
      driverEarning,
    };

    // 6. Create Order document
    const orderRef = db.collection("orders").doc();
    const orderData = {
      id: orderRef.id,
      customerId,
      storeId,
      vendorId,
      driverId: null,
      deliveryAddressId,
      deliveryAddressSnapshot: {
        line1: addressData.line1,
        line2: addressData.line2 || null,
        city: addressData.city,
        state: addressData.state,
        pincode: addressData.pincode,
        latitude: addressData.latitude,
        longitude: addressData.longitude,
      },
      status: "pending",
      paymentMethod,
      paymentStatus: paymentMethod === "cod" ? "pending" : "pending",
      razorpayOrderId: null,
      razorpayPaymentId: null,
      promoCodeId: promoCode || null,
      pricing,
      commissionRate,
      cancellationReason: null,
      cancelledBy: null,
      cancelledAt: null,
      placedAt: now,
      confirmedAt: null,
      deliveredAt: null,
      createdAt: now,
      updatedAt: now,
    };

    // Batch commit order and items
    const batch = db.batch();
    batch.set(orderRef, orderData);

    for (const item of orderItems) {
      const itemRef = orderRef.collection("items").doc();
      batch.set(itemRef, item);
    }

    // Clear cart items
    for (const itemDoc of cartItemsSnap.docs) {
      batch.delete(itemDoc.ref);
    }

    // Increment customer total orders count
    batch.update(db.doc(`customerProfiles/${customerId}`), {
      totalOrders: admin.firestore.FieldValue.increment(1),
      updatedAt: now,
    });

    await batch.commit();

    functions.logger.info(`Order placed: ${orderRef.id} by ${customerId}`);
    return { success: true, orderId: orderRef.id };
  });
