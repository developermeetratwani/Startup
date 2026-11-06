import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const sendNotification = functions.region("asia-south1").https.onCall(async (data, context) => {
  const { fcmToken, title, body } = data;
  if (!fcmToken || !title) return { success: false };

  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
  });
  return { success: true };
});
