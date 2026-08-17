import * as admin from "firebase-admin";
import * as fs from "fs";

const serviceAccount = JSON.parse(
    fs.readFileSync("/Users/armaansharma/locked-in-app-53d29-firebase-adminsdk-fbsvc-6f2b0f06cf.json", "utf8")
);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: "locked-in-app-53d29",
});

const db = admin.firestore();

async function migratePublicProfiles() {
    const usersSnap = await db.collection('users').get();

    console.log(`Found ${usersSnap.size} users.`)

    let created = 0;
    let skipped = 0;

    for(const userDoc of usersSnap.docs) {
        const userData = userDoc.data();

        const publicProfileRef = db.collection("publicProfiles").doc(userDoc.id);

        const publicProfileSnap = await publicProfileRef.get();

        if(publicProfileSnap.exists) {
            skipped++;
            continue;
        }

        await publicProfileRef.set({
            username: userData.username ?? "",
            bio: userData.bio ?? "",
            profileImageUrl: userData.profileImageUrl ?? null,
        });

        console.log(`Created public profile for ${userDoc.id}`);
        created++;
    }

    console.log(`Migration complete.`);
    console.log(`Created: ${created}`);
    console.log(`Skipped: ${skipped}`);
}

migratePublicProfiles().then(() => {
    console.log("Done.");
    process.exit(0);
}).catch((error) => {
    console.error("Migration failed:", error);
    process.exit(1);
});