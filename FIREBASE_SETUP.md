# Firebase setup for Aajhee

Checked-in configs target Firebase project `aajhee` / bundle `com.aajhee.app`:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

See `AAJHEE_INFRA_CHECKLIST.md` for the full infra list.
iOS push:
- Debug / local device installs (`flutter run`, `flutter run --release`) use
  `Runner/Runner.entitlements` (`aps-environment` = development). This matches
  Apple Development signing. Do **not** use production entitlements for USB installs.
- For TestFlight / App Store archives, set `aps-environment` to `production`
  (use `Runner/RunnerRelease.entitlements`) before `flutter build ipa`, or let
  Xcode’s Distribute flow resign with a distribution profile.
- Enable **Push Notifications** capability on the `com.aajhee.app` App ID and in
  Xcode → Runner → Signing & Capabilities.
- Upload an APNs Authentication Key (.p8) to Firebase Console → Project settings → Cloud Messaging.
- `AppDelegate` calls `registerForRemoteNotifications()` so FCM can obtain an APNs token.

After login, device logs must show:
- `[Aajhee] APNs token ready: true`
- `[Aajhee] Device token registered for push`

If the in-app Notifications screen gets new rows but no OS banner, FCM/APNs delivery
is the problem (credentials / token / capability). If the inbox stays empty, the
backend notify path is not firing for that user.

## Test iOS pushes in all app states (pre-launch)

Use a **physical iPhone**. Simulator is not reliable for APNs.

### 1. Confirm registration

1. `flutter run` (debug) or a debug build — token files and console token dumps are **debug-only** (`kDebugMode`). Release/Profile use `RunnerRelease.entitlements` (`aps-environment=production`).
2. Log in and allow notification permission.
3. In console (`xcrun devicectl device process launch --device <id> --console com.aajhee.app`
   or Xcode), look for:
   - `[Aajhee] APNs token ready: true`
   - `[Aajhee] FCM token: <token>`
   - `[Aajhee] Device token registered for push`
4. Optional: pull the debug token file written after sync (**debug builds only**):

```bash
xcrun devicectl device copy from \
  --device <device-id> \
  --domain-type appDataContainer \
  --domain-identifier com.aajhee.app \
  --source Documents/fcm_token.txt \
  --destination /tmp/fcm_token.txt
```

### 2. Fix Admin SDK send permission (required for backend / diagnose_push)

If `diagnose_push --send-test` fails with:

`Permission 'cloudmessaging.messages.create' denied on resource .../projects/aajhee`

grant the Firebase Admin SDK service account FCM send access:

1. Open [Google Cloud IAM](https://console.cloud.google.com/iam-admin/iam?project=aajhee)
2. Find `firebase-adminsdk-fbsvc@aajhee.iam.gserviceaccount.com`
3. Add role **Firebase Cloud Messaging Admin** (or **Firebase Admin**)
4. Enable the API: [Firebase Cloud Messaging API](https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=aajhee) → **Enable**
5. Confirm the principal shows **both** Authentication Admin and Cloud Messaging Admin (pencil icon on the row)

Until FCM Admin can send, the backend falls back to **direct APNs** when
`APNS_*` env vars are set and the app registered an `apns_token`.

### 3. Send a test (Firebase Console or backend)

Payload must include a **notification** block (required for background/terminated banners):

```json
{
  "notification": {
    "title": "Test order update",
    "body": "Your order is being prepared"
  },
  "data": {
    "type": "order_status_changed",
    "order_public_id": "REPLACE_WITH_REAL_UUID"
  }
}
```

Canonical data keys: `type`, `notification_id`, `order_public_id`, `business_id`,
`branch_id`, `route` (see `lib/src/features/notifications/data/push_notification_payload.dart`).

Backend (local machine with `FIREBASE_CREDENTIALS_PATH` set):

```bash
cd aajhee-backend
python manage.py diagnose_push --token "$(cat /tmp/fcm_token.txt)" --send-test --state foreground
python manage.py diagnose_push --token "$(cat /tmp/fcm_token.txt)" --send-test --state background
python manage.py diagnose_push --token "$(cat /tmp/fcm_token.txt)" --send-test --state terminated
```

Or by registered user (production DB / Render shell):

```bash
python manage.py diagnose_push --email you@example.com --send-test --state foreground
```

**APNs direct fallback** (works even when Firebase Admin IAM blocks FCM send;
use sandbox host for `flutter run` / USB installs):

```bash
xcrun devicectl device copy from \
  --device <device-id> \
  --domain-type appDataContainer \
  --domain-identifier com.aajhee.app \
  --source Documents/apns_token.txt \
  --destination /tmp/apns_token.txt

export AAJHEE_APNS_KEY_PATH=~/Downloads/AuthKey_U4ZBFCM8MN.p8
export AAJHEE_APNS_KEY_ID=U4ZBFCM8MN
export AAJHEE_APNS_TEAM_ID=J5F5G7B832
python3 scripts/send_apns_test.py --token "$(cat /tmp/apns_token.txt)" --state foreground
python3 scripts/send_apns_test.py --token "$(cat /tmp/apns_token.txt)" --state background
python3 scripts/send_apns_test.py --token "$(cat /tmp/apns_token.txt)" --state terminated
```

### 4. Verify each state

| State | Device setup | Expect |
|-------|--------------|--------|
| Foreground | App open on screen | Banner over UI; tap navigates |
| Background | Home button / app switcher, not force-quit | System banner; tap resumes + navigates |
| Terminated | Swipe away from app switcher | System banner; tap cold-starts + navigates |

Do **not** use data-only FCM messages for these tests on iOS.

### 5. Backend end-to-end

After Console / `diagnose_push` works, change an order status (or trigger a real
notify path) and confirm the same three states again. Inbox row + OS banner =
full path healthy.
