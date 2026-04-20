<div align="center">
  <img src="website/cassiellogo.png" alt="CassielDrive Logo" width="120" />
  <br/>
  <h1><span style="color:#25a7da">CASSIEL</span>DRIVE v2.0</h1>
  <p><b>Ultimate Google Drive Client for Unlimited Cloud Storage</b></p>
  <p>A beautifully crafted open-source Flutter client that transforms your Google Drive into a premium, fluid, and limitless cross-platform storage experience.</p>

  <a href="https://cassieldrive.vercel.app/#/home" target="_blank"><img src="https://img.shields.io/badge/Web_App-Live-25a7da?style=for-the-badge&logo=vercel" alt="Live Demo" /></a>
  <a href="https://github.com/cassielxyz/CassielDrive/releases/latest/download/app-release.apk"><img src="https://img.shields.io/badge/Download-APK-3DDC84?style=for-the-badge&logo=android" alt="Download APK" /></a>
  <img src="https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/License-MIT-ff4b4b?style=for-the-badge" alt="License" />
</div>

<br/>

---

<h2 align="center">? ?? Reimagining Cloud Storage</h2>
<p align="center">
  CassielDrive isn't just another file manager. It's a visually stunning, highly optimized alternative client for <b>Google Drive</b>. Designed with a pure OLED dark UI, glassmorphism layers, and silky 60-120 FPS transitions, it completely redesigns how you interact with your personal cloud. Watch your files orbit in our signature <b>Storage Galaxy</b> and manage multiple Google Accounts with zero limits.
</p>

## ?? Core Features & Advantages

*   <span style="color:#25a7da"><b>?? Unlimited Cloud Expansion:</b></span> Log into multiple Google Drive accounts simultaneously. CassielDrive seamlessly aggregates your storage, letting you effortlessly hop between accounts to unlock practically unlimited cloud storage.
*   <span style="color:#ff4b4b"><b>?? Local AES-256 Vault:</b></span> Privacy is paramount. The Cassiel Vault provides military-grade AES-256 local encryption for your most sensitive documents before they ever reach the cloud. 
*   <span style="color:#a74bff"><b>?? OLED-Optimized Dynamic Themes:</b></span> Beautiful deep-dark layouts tailored for OLED displays. Features dynamic blurred ambient background particles, glassmorphism containers, and high-contrast neon accents.
*   <span style="color:#4bff80"><b>? Buttery Smooth UI & Performance:</b></span> Built entirely in Flutter, delivering native 60-120 FPS gesture routing, buttery smooth page transitions, and intelligent responsive layouts for Desktop monitors and mobile screens alike.
*   <span style="color:#ffb84b"><b>?? Seamless Cross-Platform Connectivity:</b></span> Run it natively on your Android device (APK) or access it instantly via the Web App (PWA). Your data, perfectly synced everywhere.

## ?? SEO & Discoverability
*Keywords:* Google Drive Client, Unlimited Cloud Storage, Flutter File Manager, AES-256 Encryption, Self-Hosted Cloud, Open Source Flutter App, Android Drive App, Web Storage App, CassielDrive, OAuth2 Cloud Integration

**Hashtags:** #GoogleDrive #CloudStorage #FlutterDev #OpenSource #AESEncryption #Privacy #WebDeployment #AndroidApp #UIUXDesign #CassielDrive

## ??? Step-by-Step Setup & Authentication

CassielDrive runs strictly on **your own private Google Cloud project credentials**, meaning Google will never throttle your API requests and your data remains entirely in your control.

### <span style="color:#25a7da">1. Generate Your Private OAuth Client ID</span>
1. Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project and enable the **Google Drive API** within the Library.
3. Configure the **OAuth Consent Screen** (Crucial: Add your personal email to the **Test users** list).
4. Create **OAuth Client ID Credentials**. When prompted for an application type, you must select **Desktop app** *(This allows Android to utilize secure local loopback ports for authentication).*

### <span style="color:#25a7da">2. Connect Your Accounts</span>
1. Launch CassielDrive on [Web](https://cassiel-drive-v2.vercel.app/) or natively on your Android phone.
2. Click the gear icon to open **Settings**.
3. Input your newly generated Client ID and Client Secret.
4. Navigate to the **Accounts** tab ("Accts") and tap Add Account.
5. Authenticate via Google, and enjoy your unlimited, hyper-fast cloud!

## ?? Build from Source (Developers)

CassielDrive is fully open-source and ready to compile for any environment. Ensure you have the latest version of [Flutter](https://docs.flutter.dev/get-started/install) installed.

\\\ash
# Clone the repository
git clone https://github.com/cassielxyz/CassielDrive.git
cd CassielDrive

# Install Flutter dependencies
flutter pub get

# Run the Development Web Server
flutter run -d web

# Compile the Android Production APK
flutter build apk --release
\\\

## ?? Vercel Web Deployment

This project is structured for seamless automated deployments. CassielDrive supports **Vercel Integration** out of the box. By pushing your code changes to the main branch, Vercel leverages the included ercel.json configuration to automatically trigger \lutter build web\ and instantly deploy your latest UI updates worldwide.

---

<br/>

<div align="center">
  <b>Made with ?? by Cassiel</b>
  <br/>
  <small>Open Source • Transparent • Limitless</small>
</div>
