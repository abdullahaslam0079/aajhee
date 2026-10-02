# Aajhee infra cutover checklist

Complete these dashboard steps after the code rename lands. Product is not live — prefer a clean cutover.

## 1. Firebase (new project `aajhee`)

1. Create project named `aajhee` at https://console.firebase.google.com/
2. Enable Auth providers used today (Phone, Google, Apple as needed).
3. Add apps:
   - Android package: `com.aajhee.app`
   - iOS bundle: `com.aajhee.app`
   - Web app for `aajhee-web`
4. Download and place:
   - `google-services.json` → consumer Flutter `android/app/`
   - `GoogleService-Info.plist` → consumer Flutter `ios/Runner/`
   - Web config → `aajhee-web` `.env.local` as `NEXT_PUBLIC_FIREBASE_*`
   - Service account JSON → Render env `FIREBASE_CREDENTIALS_JSON` (minified one line) and local `secrets/firebase-adminsdk.json`
   - Grant that service account **Firebase Cloud Messaging Admin** in GCP IAM (`firebase-adminsdk-fbsvc@aajhee.iam.gserviceaccount.com`), and enable the FCM API. Without this, inbox rows still create but OS banners never leave the server.
5. Add Android SHA-1 / SHA-256 for the debug keystore and for the release upload keystore.

   Debug builds keep the Android debug key. Release builds (`flutter build apk`, `flutter build appbundle`, `flutter run --release`) read `android/key.properties`, which is gitignored. Copy `android/key.properties.example` to `android/key.properties` and set `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` (absolute path, or a path relative to `android/app`). Do not commit `key.properties` or the `.jks`. If `key.properties` is missing, debug builds still work and a release task fails. Release does not fall back to the debug key.

   The current GitHub workflow does not build a release APK. A later release job should write `android/key.properties` and the keystore from CI secrets at build time.
6. Restrict Google Maps API keys to `com.aajhee.app` / `com.aajhee.business` / `com.aajhee.admin` and `aajhee.com`.

## 2. Render

1. Deploy from renamed repo using updated `render.yaml` (`aajhee-backend` / `aajhee-db`).
2. Set env:
   - `ALLOWED_HOSTS=api.aajhee.com,aajhee-backend.onrender.com`
   - `CORS_ALLOWED_ORIGINS=https://aajhee.com,https://www.aajhee.com,https://admin.aajhee.com`
   - `FIREBASE_CREDENTIALS_JSON=...`
   - `AWS_*` (R2/S3)
   - `DATABASE_URL` (from new DB)
3. Custom domain: `api.aajhee.com`
4. After green checks, delete old `goluto-backend` service + `goluto-db`.

## 3. GoDaddy DNS (`aajhee.com`)

| Type | Name | Value |
|------|------|--------|
| A/ALIAS/CNAME | `@` | web host (Vercel/Render static) — remove Parked |
| CNAME | `www` | web host |
| CNAME | `api` | Render `aajhee-backend` target |
| CNAME | `admin` | admin web host (Vercel) |

Add any TXT/CNAME verification records Render/Vercel/Firebase request.

## 4. GitHub

Rename remotes:

- `goluto` → `aajhee`
- `GoLuto-backend` → `aajhee-backend`
- `goluto-web` → `aajhee-web`
- `goluto_business` → `aajhee_business`
- create/rename `aajhee-admin` for admin web, `aajhee_admin` for admin Flutter if needed

## 5. Retire old Firebase

After auth works on `aajhee`, stop using project `goluto-c5020`.

## 6. Smoke test (after infra is live)

1. `https://api.aajhee.com/api/docs/` opens
2. Consumer app phone/social login (new Firebase) → API JWT works
3. `aajhee-web` login + CORS
4. `admin.aajhee.com` / admin web login
5. Offer QR uses `AAJHEE:` prefix; scanner still accepts legacy `GOLUTO:`
6. Image upload to R2
7. Maps load with updated key restrictions
8. Delete old Render `goluto-backend` and stop using Firebase `goluto-c5020`
