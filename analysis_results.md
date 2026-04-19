# Cassiel Drive — "Access Blocked" Error Analysis

## Root Cause

The **"Access Blocked"** error from Google appears **before** the user can even select their account. This is a **Google Cloud Console configuration issue**, not a code bug. Even though you've added test users, there are several specific requirements that must all be met simultaneously.

---

## Your OAuth Flow (How It Works)

Your app uses a **manual loopback OAuth 2.0 flow**:

1. App opens browser → `accounts.google.com/o/oauth2/v2/auth`
2. User signs in and grants consent
3. Google redirects to `http://127.0.0.1:8085` with an auth code
4. App exchanges the code for tokens at `oauth2.googleapis.com/token`

The code in [auth_service.dart](file:///c:/Users/jesow/Documents/github%20projects/cassiel%20drive/driveunlimited/lib/services/auth_service.dart) is correct. The problem is in how Google Cloud Console is configured.

---

## Checklist: Fix "Access Blocked"

> [!IMPORTANT]
> ALL of these must be correct simultaneously. Missing even one will cause "Access Blocked".

### 1. ✅ OAuth Consent Screen — Publishing Status

| Setting | Required Value |
|---------|---------------|
| **Publishing status** | `Testing` (can stay as Testing) |
| **User type** | `External` |
| **App name** | Must be filled in (e.g., "Cassiel Drive") |
| **User support email** | Must be your Gmail |
| **Developer contact email** | Must be filled in |

### 2. ⚠️ Test Users — EXACT Email Format

Go to: **Google Cloud Console → APIs & Services → OAuth consent screen → Test users**

- You must add the **exact Gmail address** of every account you want to sign in with
- The email must be a `@gmail.com` address (or your Google Workspace domain)
- Maximum 100 test users while in Testing mode
- **The email is case-sensitive** — use all lowercase

> [!WARNING]
> If your consent screen is in "Testing" mode, **ONLY** emails listed as test users can authenticate. Any other email will get "Access Blocked" — even if it's your own Google account.

### 3. ⚠️ OAuth Client Type — MUST Be "Desktop"

This is the **most common mistake**. Go to: **Google Cloud Console → APIs & Services → Credentials**

| Setting | Required Value |
|---------|---------------|
| **Application type** | `Desktop app` |
| **NOT** | Web application, Android, iOS |

**Why?** Your app uses `http://127.0.0.1:8085` as the redirect URI (loopback). This is only allowed for **Desktop** type OAuth clients. If you created a "Web application" or "Android" type client:
- Web clients require explicit redirect URIs registered in the console
- Android clients use a completely different flow (SHA-1 fingerprint)
- **Only Desktop clients auto-allow `127.0.0.1` loopback redirects**

> [!CAUTION]
> If your OAuth client type is set to "Web application" or "Android", you will get *"Access Blocked"* regardless of test users. **Delete the wrong credential and create a new Desktop-type one.**

### 4. ✅ Required API Enabled

Go to: **Google Cloud Console → APIs & Services → Enabled APIs**

Ensure these are enabled:
- `Google Drive API`
- `Google People API` (or at minimum, the userinfo endpoint works with basic OAuth)

### 5. ✅ Scopes Match

Your app requests these scopes (in [auth_service.dart line 27-32](file:///c:/Users/jesow/Documents/github%20projects/cassiel%20drive/driveunlimited/lib/services/auth_service.dart#L27-L32)):
```
email
profile
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/drive.file
```

On the OAuth consent screen, under **Scopes**, make sure you've added:
- `.../auth/drive`
- `.../auth/drive.file`
- `email`
- `profile`

> [!NOTE]
> `drive` is a **sensitive scope**. Google will show a warning screen ("This app isn't verified") but it should still let test users through. If you see "Access Blocked" instead of the warning, the problem is in items 2 or 3 above.

---

## Step-by-Step Fix

### Step 1: Verify OAuth Client Type
1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
2. Click on your OAuth 2.0 Client ID
3. Check **Application type** — it **must say "Desktop app"**
4. If it says "Web application" or "Android":
   - Click **+ CREATE CREDENTIALS → OAuth client ID**
   - Select **Desktop app**
   - Name it "Cassiel Drive Desktop"
   - Copy the new **Client ID** and **Client Secret**
   - Paste them into the app's Settings screen

### Step 2: Verify Test Users
1. Go to [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)
2. Click **Test users → + ADD USERS**
3. Add the exact email you're trying to sign in with
4. Wait **2-5 minutes** for propagation (Google's test user list isn't instant)

### Step 3: Verify APIs Are Enabled
1. Go to [Enabled APIs](https://console.cloud.google.com/apis/dashboard)
2. Search for "Google Drive API" → Enable if not already
3. Search for "People API" → Enable

### Step 4: Clear Browser Cache
- The browser may have cached the old "Access Blocked" decision
- Try signing in from an **incognito/private** browser window
- Or clear cookies for `accounts.google.com`

### Step 5: Update Credentials in App
- Open Cassiel Drive → Settings
- Paste the **Desktop** Client ID and Client Secret
- Hit Save Settings
- Try "Add Google Account" again

---

## Code Issues Found (Minor)

The code is functional, but I found these issues during analysis:

| File | Issue | Severity |
|------|-------|----------|
| `auth_service.dart:85` | Redirect URI `http://127.0.0.1:8085` hardcoded — correct for Desktop OAuth | ✅ OK |
| `auth_service.dart:112` | 3-minute timeout for OAuth — adequate | ✅ OK |
| `auth_service.dart:228` | `storageTotal` overflows `int` on 32-bit — `15 * 1024 * 1024 * 1024` = 16GB which is fine for 64-bit | ⚠️ Minor |
| `AndroidManifest.xml` | No `android:usesCleartextTraffic="true"` — needed for `http://127.0.0.1` redirect on Android | 🔴 Bug |

> [!IMPORTANT]
> **Critical Android Bug**: On Android 9+ (API 28+), cleartext HTTP traffic to `127.0.0.1` is blocked by default. The OAuth redirect to `http://127.0.0.1:8085` will silently fail on Android unless you add `android:usesCleartextTraffic="true"` to the `<application>` tag in `AndroidManifest.xml`. **This could be causing your issue if you're running on an Android device.**

---

## Summary

| Most Likely Cause | Fix |
|---|---|
| **OAuth client type is "Web" or "Android" instead of "Desktop"** | Create a new Desktop-type client credential |
| **Test user email not added or not propagated** | Re-add and wait 5 minutes |
| **Android blocking cleartext HTTP to 127.0.0.1** | Add `usesCleartextTraffic="true"` to manifest |
