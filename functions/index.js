/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
admin.initializeApp();

exports.updateRatingsIndex = functions.firestore
    .document("ratings/{productType}/{productId}/{userId}")
    .onCreate((snap, context) => {
      const productType = context.params.productType;
      const productId = context.params.productId;

      const indexRef = admin.firestore().collection("metadata")
          .doc("ratingsIndex");

      return admin.firestore().runTransaction(async (transaction) => {
        const indexDoc = await transaction.get(indexRef);

        if (!indexDoc.exists) {
          transaction.set(indexRef, {
            [productType]: [productId],
          });
        } else {
          const currentIds = indexDoc.get(productType) || [];
          if (!currentIds.includes(productId)) {
            transaction.update(indexRef, {
              [productType]: [...currentIds, productId],
            });
          }
        }
      });
    });

exports.updateReviewsIndex = functions.firestore
    .document("reviews/{productType}/{productId}/{userId}")
    .onCreate((snap, context) => {
      const productType = context.params.productType;
      const productId = context.params.productId;

      const indexRef = admin.firestore().collection("metadata")
          .doc("reviewsIndex");

      return admin.firestore().runTransaction(async (transaction) => {
        const indexDoc = await transaction.get(indexRef);

        if (!indexDoc.exists) {
          transaction.set(indexRef, {
            [productType]: [productId],
          });
        } else {
          const currentIds = indexDoc.get(productType) || [];
          if (!currentIds.includes(productId)) {
            transaction.update(indexRef, {
              [productType]: [...currentIds, productId],
            });
          }
        }
      });
    });

const TMDB_API_KEY = "703bd0b2519d5fd488e1070d1adb9502";

exports.getPosterUrl = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method not allowed");
    return;
  }

  const type = req.body.type;
  const id = req.body.id;

  try {
    const response = await axios
        .get(`https://api.themoviedb.org/3/${type}/${id}?api_key=${TMDB_API_KEY}`);

    const posterPath = response.data.poster_path;
    res.send({posterPath: posterPath});
  } catch (error) {
    res.status(500).send("Failed to fetch poster URL");
  }
});
