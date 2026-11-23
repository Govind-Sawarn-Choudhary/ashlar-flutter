# Firebase push (FCM) — Ashlar Lawyer Hub

Use Firebase project **`ashlarlawyer`** (display name: **ashlar lawyer** in console).

Push when the app is **killed** needs three pieces aligned:

1. **Firebase project** with Android app `com.ashlarlawyerhub.ashlar_lawyer_hub`
2. **Server** — `FIREBASE_SERVICE_ACCOUNT_JSON` in backend `.env` (full service account JSON, one line)
3. **Flutter** — dart-defines or `flutterfire configure`

## Backend (Xenax / production)

```bash
cd backend && npm install
```

Add to `.env`:

```env
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

Restart the API. `GET /api/user/notifications` returns `pushEnabled: true` when Firebase Admin initializes.

## Flutter build with FCM

### Step 1 — `google-services.json` (project **ashlarlawyer**)

1. [Firebase Console](https://console.firebase.google.com) → project **ashlarlawyer**
2. Add Android app if missing: package **`com.ashlarlawyerhub.ashlar_lawyer_hub`**
3. Download **`google-services.json`** → save as `flutter/android/app/google-services.json`
4. Sync env for builds:

```bash
cd flutter
dart run tool/sync_firebase_env.dart
```

This updates `env.production.json` with `FIREBASE_*` dart-defines.

Option A — FlutterFire CLI (needs Firebase CLI + login):

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=ashlarlawyer
```

Option B — pass dart-defines manually:

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=your-project \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789 \
  --dart-define=FIREBASE_ANDROID_API_KEY=AIza... \
  --dart-define=FIREBASE_ANDROID_APP_ID=1:123:android:abc
```

Without these, the app still works: **in-app notifications**, badges, and **90s polling** on resume. Killed-state delivery requires FCM configured on both server and app.

## Verify

1. Login as user on device → check backend `device_push_tokens` row after `POST /device-token`.
2. Trigger an event (booking, join consultation, wallet low).
3. Force-stop the app → notification should appear in the system tray.
4. Tap notification → app opens to wallet / consultation / appointments.