<div align="center">
  <img src="website/cassiellogo.png" alt="CassielDrive Logo" width="120" />
  <br/>
  <h1><span style="color:#25a7da">CASSIEL</span>DRIVE v2.0</h1>
  <p><b>Unlimited Cloud. <span style="color:#25a7da">Zero Limits.</span></b></p>
  <p>A beautifully crafted client that transforms your Google Drive into a premium, fluid, and limitless storage experience.</p>

  <a href="https://cassiel-drive-v2.vercel.app/" target="_blank"><img src="https://img.shields.io/badge/Web_App-Live-25a7da?style=for-the-badge&logo=vercel" alt="Live Demo" /></a>
  <a href="https://github.com/cassielxyz/CassielDrive/releases/latest/download/app-release.apk"><img src="https://img.shields.io/badge/Download-APK-3DDC84?style=for-the-badge&logo=android" alt="Download APK" /></a>
  <img src="https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/License-MIT-ff4b4b?style=for-the-badge" alt="License" />
</div>

<br/>

<p align="center">
  <img src="website/dashboard.png" alt="Cassiel Drive UI Preview" width="800" style="border-radius: 20px; box-shadow: 0 10px 30px rgba(37, 167, 218, 0.2);"/>
</p>

---

<h2 align="center">✨ 🌌 The Storage Galaxy</h2>
<p align="center">
  CassielDrive isn't just a file manager; it's a visual experience. Your files orbit in our signature <b>Storage Galaxy</b>, categorized by dynamic planetary colors. Built with a pure OLED dark UI, glassmorphism layers, and silky 60-120 FPS transitions.
</p>

## 🚀 Core Features

*   <span style="color:#25a7da"><b>♾️ Unlimited Organization:</b></span> Seamlessly maps multiple Google Drive accounts into a unified, hyper-fast local interface.
*   <span style="color:#ff4b4b"><b>🔒 Cassiel Vault:</b></span> Military-grade AES-256 local encryption for your most sensitive documents. Keep your private files locked away.
*   <span style="color:#a74bff"><b>🎨 Dynamic OLED Themes:</b></span> Optimized for pure black OLED displays with ambient blurred background particles. Seamlessly toggle between our exclusive high-contrast palettes.
*   <span style="color:#4bff80"><b>⚡ Buttery Smooth UI:</b></span> iOS-like page routing, slick gestures, and a docked glassmorphism top navigation strip tailor-made for Desktop & Web.
*   <span style="color:#ffb84b"><b>📱 Universal Support:</b></span> Flawlessly responsive across Android and Desktop/Web platforms.

## 🛠️ Setup & Installation

CassielDrive runs safely on your personal Google Drive OAuth credentials, ensuring you completely own your API quota and privacy.

### <span style="color:#25a7da">1. Generate OAuth Client ID</span>
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project and enable the **Google Drive API**.
3. Configure the OAuth Consent Screen (<b>crucial:</b> add your personal email as a **Test user**).
4. Create **OAuth Client ID Credentials** and select **Desktop app** as the application type *(this is required to handle native loopback ports on Android securely)*.

### <span style="color:#25a7da">2. Enter Credentials</span>
1. Launch CassielDrive via the [Web App](https://cassiel-drive-v2.vercel.app/) or your Android device.
2. Head to the **Settings** menu at the top right.
3. Paste your Client ID and Client Secret.
4. Go to **Accounts** and click Add Account to authenticate your cloud!

## 💻 Build from Source

Ready to compile the codebase yourself? Ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed.

\\\ash
# Clone the repository
git clone https://github.com/cassielxyz/CassielDrive.git
cd CassielDrive

# Get dependencies
flutter pub get

# Run for Web
flutter run -d web

# Build Android APK
flutter build apk --release
\\\

## 🌐 Deployment (Web / Vercel)

CassielDrive is continuously integrated with **Vercel**. When pushing to the main branch, Vercel automatically runs the \lutter build web\ sequence, ensuring your live web client is always cutting-edge and constraints-optimized.

---

<br/>

<div align="center">
  <b>Made with 💙 by Cassiel</b>
  <br/>
  <small>Reimagining cloud storage interfaces.</small>
</div>
