# Firebase setup for Aajhee

The checked-in `google-services.json` / `GoogleService-Info.plist` were string-updated for package IDs (`com.aajhee.app`) but still belong to the old Firebase project until you replace them.

1. Create Firebase project `aajhee`.
2. Register Android `com.aajhee.app` and iOS `com.aajhee.app`.
3. Replace:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. See `aajhee-backend/AAJHEE_INFRA_CHECKLIST.md` (will move to `aajhee-backend`) for the full infra list.
