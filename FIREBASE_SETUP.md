# Firebase push (FCM) — Ashlar Lawyer Hub

Use your Firebase project **Ashlar Lawyer** (or similar name in console).

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

Option A — FlutterFire CLI (recommended):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Option B — pass dart-defines:

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