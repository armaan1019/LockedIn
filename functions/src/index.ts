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
      "Your post contains explicit content and cannot be published.",
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

export const deletePost = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in to delete a post.",
    );
  }

  const {postId} = request.data;

  if (!postId || typeof postId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "A valid post ID is required.",
    );
  }

  const postRef = db.collection("posts").doc(postId);
  const postSnap = await postRef.get();

  if (!postSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Post not found.",
    );
  }

  const postData = postSnap.data();

  if (postData?.userId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "You can only delete your own posts.",
    );
  }

  const commentsSnap = await postRef.collection("comments").get();
  const likesSnap = await postRef.collection("likes").get();
  const reportsSnap = await postRef.collection("reports").get();

  const batch = db.batch();

  for (const comment of commentsSnap.docs) {
    const commentReportsSnap = await comment.ref.collection("reports").get();

    commentReportsSnap.docs.forEach((report) => {
      batch.delete(report.ref);
    });

    batch.delete(comment.ref);
  }

  likesSnap.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  reportsSnap.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  batch.delete(postRef);

  await batch.commit();

  return {
    success: true,
  };
});

export const deleteComment = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in to delete a comment.",
    );
  }

  const {postId, commentId} = request.data;

  if (!postId || typeof postId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "A valid post ID is required.",
    );
  }

  if (!commentId || typeof commentId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "A valid comment ID is required.",
    );
  }

  const commentRef = db.collection("posts").doc(postId)
    .collection("comments").doc(commentId);
  const commentSnap = await commentRef.get();

  if (!commentSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Comment not found.",
    );
  }

  const commentData = commentSnap.data();

  if (commentData?.userId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "You can only delete your own comments.",
    );
  }

  const reportsSnap = await commentRef.collection("reports").get();

  const batch = db.batch();

  reportsSnap.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  batch.delete(commentRef);

  await batch.commit();

  return {
    success: true,
  };
});

export const deleteUserComments = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in to delete your comments.",
    );
  }

  const userId = request.auth.uid;

  const postsSnap = await db.collection("posts").get();

  const batch = db.batch();

  let commentsDeleted = 0;
  let reportsDeleted = 0;

  for (const post of postsSnap.docs) {
    const commentsSnap = await post.ref
      .collection("comments")
      .where("userId", "==", userId)
      .get();

    for (const comment of commentsSnap.docs) {
      const reportsSnap = await comment.ref
        .collection("reports")
        .get();

      reportsSnap.docs.forEach((report) => {
        batch.delete(report.ref);
        reportsDeleted++;
      });

      batch.delete(comment.ref);
      commentsDeleted++;
    }
  }

  if (commentsDeleted > 0 || reportsDeleted > 0) {
    await batch.commit();
  }

  return {
    success: true,
    commentsDeleted: commentsDeleted,
    reportsDeleted: reportsDeleted,
  };
});

export const deleteUserPosts = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in to delete your posts.",
    );
  }

  const userId = request.auth.uid;

  const postsSnap = await db
    .collection("posts")
    .where("userId", "==", userId)
    .get();

  for (const post of postsSnap.docs) {
    const commentsSnap = await post.ref
      .collection("comments")
      .get();

    const likesSnap = await post.ref
      .collection("likes")
      .get();

    const reportsSnap = await post.ref
      .collection("reports")
      .get();

    const batch = db.batch();

    for (const comment of commentsSnap.docs) {
      const commentReportsSnap = await comment.ref
        .collection("reports")
        .get();

      commentReportsSnap.docs.forEach((report) => {
        batch.delete(report.ref);
      });

      batch.delete(comment.ref);
    }

    likesSnap.docs.forEach((like) => {
      batch.delete(like.ref);
    });

    reportsSnap.docs.forEach((report) => {
      batch.delete(report.ref);
    });

    batch.delete(post.ref);

    await batch.commit();
  }

  return {
    success: true,
    postsDeleted: postsSnap.size,
  };
});
