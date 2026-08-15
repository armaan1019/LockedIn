import {onCall, HttpsError} from "firebase-functions/v2/https";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import OpenAI from "openai";
import {defineSecret} from "firebase-functions/params";

initializeApp();

const db = getFirestore();
const openaiApiKey = defineSecret("OPENAI_API_KEY");

export const createPost = onCall({secrets: [openaiApiKey]}, async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in to create a post",
    );
  }

  const content = request.data?.content;

  if (typeof content !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "Post content must be a text.",
    );
  }

  const trimmedContent = content.trim();

  if (trimmedContent.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Post cannot be empty.",
    );
  }

  if (trimmedContent.length > 500) {
    throw new HttpsError(
      "invalid-argument",
      "Post cannot exceed 500 characters.",
    );
  }

  const userId = request.auth.uid;

  const userSnapshot = await db
    .collection("users")
    .doc(userId)
    .get();

  if (!userSnapshot.exists) {
    throw new HttpsError(
      "not-found",
      "User profile not found.",
    );
  }

  const userData = userSnapshot.data();

  const username = userData?.username;

  if (typeof username !== "string") {
    throw new HttpsError(
      "failed-precondition",
      "User does not have a valid username.",
    );
  }

  const openai = new OpenAI({
    apiKey: openaiApiKey.value(),
  });

  let moderation;

  try {
    moderation = await openai.moderations.create({
      model: "omni-moderation-latest",
      input: trimmedContent,
    });
  } catch (error: any) {
    console.error("OpenAI moderation error:", error);
    console.error("Status:", error?.status);
    console.error("Message:", error?.message);
    console.error("Code:", error?.code);
    console.error("Type:", error?.type);
    console.error("Request ID:", error?.requestID);

    throw new HttpsError(
      "internal",
      "Post moderation is temporarily unavailable.",
    );
  }

  const result = moderation.results[0];

  if (result.flagged) {
    throw new HttpsError(
      "invalid-argument",
      "This post violates our community guidelines.",
    );
  }

  const postRef = await db.collection("posts").add({
    userId: userId,
    username: username,
    content: trimmedContent,
    createdAt: FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    postId: postRef.id,
  };
});
