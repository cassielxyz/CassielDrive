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

<h2 align="center">🌌 Reimagining Cloud Storage</h2>
<p align="center">
  CassielDrive isn't just another file manager. It's a visually stunning, highly optimized alternative client for <b>Google Drive</b>. Designed with a pure OLED dark UI, glassmorphism layers, and silky 60-120 FPS transitions, it completely redesigns how you interact with your personal cloud. Watch your files orbit in our signature <b>Storage Galaxy</b> and manage multiple Google Accounts with zero limits.
</p>

## 🌟 Core Features & Architectural Highlights

### 🚀 Unlimited Cloud Expansion & Account Aggregation
Most cloud providers trap you in paid tiers once you hit 15GB. CassielDrive solves this by acting as a master unified storage client. It allows you to authenticate and link **an infinite number of Google Drive accounts simultaneously**. The internal architecture abstracts these isolated accounts into a single cohesive UI, allowing you to instantly hop between "Drives" and treat multiple free 15GB limits as one massive, boundless cloud repository.

### 🔒 Military-Grade AES-256 Secure Vault Architecture
Cloud privacy is a major concern, which is why CassielDrive introduces the **Cassiel Vault**. Rather than relying on standard cloud-side encryption, the app implements true **Zero-Knowledge Architecture**. When you upload a file into the Vault, CassielDrive uses **AES-256 local encryption** running directly on your device's CPU. The file is mathematically scrambled using your private passphrase *before* a single byte is transmitted to Google's servers. Even if your Google account is fully compromised, your files remain completely unreadable without your local Vault key.

### 💻 Widescreen Desktop Optimization & Adaptive UI Constraints
A common flaw in Flutter web apps is that mobile interfaces awkwardly stretch to fill ultra-wide 4K desktop monitors. CassielDrive solves this natively using intelligent layout architectures. The entire application widget tree wraps its core views in a strict `ConstrainedBox(maxWidth: 800)`. This guarantees that whether you are on a massive 32-inch monitor or a 6-inch Android phone, the UI remains perfectly proportioned, centralized, and visually stunning, providing a premium desktop-class experience.

### 🧭 Minimalist Floating Navigation Pill
To maximize the visual real estate for your file grids and folder layouts, we eliminated the bulky, screen-consuming bottom navigation bars typical to Android applications. CassielDrive features a streamlined, non-obtrusive **Top-Right Floating Navigation Pill**. This compact router floats intelligently above your content, giving you instant access to Dashboard, Files, Vault, Accounts, and Settings without eating into your vertical screen space.

### 🌌 OLED-Optimized Dynamic Themes & 3D CSS Rendering
CassielDrive is engineered around a deep-dark, high-contrast palette specifically tailored for OLED displays. This includes frosted glassmorphism containers, neon accents, and fluid 120Hz gesture animations. Furthermore, our standalone promotional website pushes the limits of modern web design with a **pure HTML/CSS 3D device mockup**. By leveraging advanced CSS `transform-style: preserve-3d` properties and keyframe animations, the site realistically renders a floating, rotating 3D phone model—delivering a wildly immersive visual hook without slowing down the page with heavy image assets.

### 🌐 Advanced Dual-Routing Vercel Pipeline
Deploying a single-page application (SPA) alongside a normal static website on the same domain usually requires complex Next.js setups. CassielDrive achieves this using a highly customized `vercel.json` deployment pipeline. When Pushed to GitHub, Vercel natively compiles the Flutter app into a hash-routed SPA serving on the root `/#/home`. Simultaneously, our deployment script injects the lightweight 3D marketing site directly into Flutter's `build/web/welcome/` directory. Vercel then transparently maps these custom subpaths, serving both experiences seamlessly on the exact same `cassieldrive.vercel.app` domain.

## 🛠️ Step-by-Step Setup & Authentication

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

## 💻 Build from Source (Developers)

CassielDrive is fully open-source and ready to compile for any environment. Ensure you have the latest version of [Flutter](https://docs.flutter.dev/get-started/install) installed.

```bash
# Clone the repository
git clone https://github.com/cassielxyz/CassielDrive.git
cd CassielDrive

# Install Flutter dependencies
flutter pub get

# Run the Development Web Server
flutter run -d web

# Compile the Android Production APK
flutter build apk --release
```

## 🚀 Vercel Web Deployment

This project is structured for seamless automated deployments. CassielDrive supports **Vercel Integration** out of the box. By pushing your code changes to the main branch, Vercel leverages the included `vercel.json` configuration to automatically trigger `flutter build web` and instantly deploy your latest UI updates worldwide.

---

## 🔍 SEO & Discoverability
*Keywords:* Google Drive Client, Unlimited Cloud Storage, Flutter File Manager, AES-256 Encryption, Self-Hosted Cloud, Open Source Flutter App, Android Drive App, Web Storage App, CassielDrive, OAuth2 Cloud Integration, Vercel Deployment, Secure Cloud Vault

**Hashtags:** #GoogleDrive #CloudStorage #FlutterDev #OpenSource #AESEncryption #Privacy #WebDeployment #AndroidApp #UIUXDesign #CassielDrive

<br/>

<div align="center">
  <b>Made with 💙 by Cassiel</b>
  <br/>
  <small>Open Source • Transparent • Limitless</small>
</div><div align="center">
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

<h2 align="center">🌌 Reimagining Cloud Storage</h2>
<p align="center">
  CassielDrive isn't just another file manager. It's a visually stunning, highly optimized alternative client for <b>Google Drive</b>. Designed with a pure OLED dark UI, glassmorphism layers, and silky 60-120 FPS transitions, it completely redesigns how you interact with your personal cloud. Watch your files orbit in our signature <b>Storage Galaxy</b> and manage multiple Google Accounts with zero limits.
</p>

## 🌟 Core Features & Architectural Highlights

### 🚀 Unlimited Cloud Expansion & Account Aggregation
Most cloud providers trap you in paid tiers once you hit 15GB. CassielDrive solves this by acting as a master unified storage client. It allows you to authenticate and link **an infinite number of Google Drive accounts simultaneously**. The internal architecture abstracts these isolated accounts into a single cohesive UI, allowing you to instantly hop between "Drives" and treat multiple free 15GB limits as one massive, boundless cloud repository.

### 🔒 Military-Grade AES-256 Secure Vault Architecture
Cloud privacy is a major concern, which is why CassielDrive introduces the **Cassiel Vault**. Rather than relying on standard cloud-side encryption, the app implements true **Zero-Knowledge Architecture**. When you upload a file into the Vault, CassielDrive uses **AES-256 local encryption** running directly on your device's CPU. The file is mathematically scrambled using your private passphrase *before* a single byte is transmitted to Google's servers. Even if your Google account is fully compromised, your files remain completely unreadable without your local Vault key.

### 💻 Widescreen Desktop Optimization & Adaptive UI Constraints
A common flaw in Flutter web apps is that mobile interfaces awkwardly stretch to fill ultra-wide 4K desktop monitors. CassielDrive solves this natively using intelligent layout architectures. The entire application widget tree wraps its core views in a strict `ConstrainedBox(maxWidth: 800)`. This guarantees that whether you are on a massive 32-inch monitor or a 6-inch Android phone, the UI remains perfectly proportioned, centralized, and visually stunning, providing a premium desktop-class experience.

### 🧭 Minimalist Floating Navigation Pill
To maximize the visual real estate for your file grids and folder layouts, we eliminated the bulky, screen-consuming bottom navigation bars typical to Android applications. CassielDrive features a streamlined, non-obtrusive **Top-Right Floating Navigation Pill**. This compact router floats intelligently above your content, giving you instant access to Dashboard, Files, Vault, Accounts, and Settings without eating into your vertical screen space.

### 🌌 OLED-Optimized Dynamic Themes & 3D CSS Rendering
CassielDrive is engineered around a deep-dark, high-contrast palette specifically tailored for OLED displays. This includes frosted glassmorphism containers, neon accents, and fluid 120Hz gesture animations. Furthermore, our standalone promotional website pushes the limits of modern web design with a **pure HTML/CSS 3D device mockup**. By leveraging advanced CSS `transform-style: preserve-3d` properties and keyframe animations, the site realistically renders a floating, rotating 3D phone model—delivering a wildly immersive visual hook without slowing down the page with heavy image assets.

### 🌐 Advanced Dual-Routing Vercel Pipeline
Deploying a single-page application (SPA) alongside a normal static website on the same domain usually requires complex Next.js setups. CassielDrive achieves this using a highly customized `vercel.json` deployment pipeline. When Pushed to GitHub, Vercel natively compiles the Flutter app into a hash-routed SPA serving on the root `/#/home`. Simultaneously, our deployment script injects the lightweight 3D marketing site directly into Flutter's `build/web/welcome/` directory. Vercel then transparently maps these custom subpaths, serving both experiences seamlessly on the exact same `cassieldrive.vercel.app` domain.

## 🛠️ Step-by-Step Setup & Authentication

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

## 💻 Build from Source (Developers)

CassielDrive is fully open-source and ready to compile for any environment. Ensure you have the latest version of [Flutter](https://docs.flutter.dev/get-started/install) installed.

```bash
# Clone the repository
git clone https://github.com/cassielxyz/CassielDrive.git
cd CassielDrive

# Install Flutter dependencies
flutter pub get

# Run the Development Web Server
flutter run -d web

# Compile the Android Production APK
flutter build apk --release
```

## 🚀 Vercel Web Deployment

This project is structured for seamless automated deployments. CassielDrive supports **Vercel Integration** out of the box. By pushing your code changes to the main branch, Vercel leverages the included `vercel.json` configuration to automatically trigger `flutter build web` and instantly deploy your latest UI updates worldwide.

---

## 🔍 SEO & Discoverability
*Keywords:* Google Drive Client, Unlimited Cloud Storage, Flutter File Manager, AES-256 Encryption, Self-Hosted Cloud, Open Source Flutter App, Android Drive App, Web Storage App, CassielDrive, OAuth2 Cloud Integration, Vercel Deployment, Secure Cloud Vault

**Hashtags:** #GoogleDrive #CloudStorage #FlutterDev #OpenSource #AESEncryption #Privacy #WebDeployment #AndroidApp #UIUXDesign #CassielDrive

<br/>

<div align="center">
  <b>Made with 💙 by Cassiel</b>
  <br/>
  <small>Open Source • Transparent • Limitless</small>
</div><div align="center">
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

## 🌟 Core Features & Architectural Highlights

### 🚀 Unlimited Cloud Expansion & Aggregation
Log into multiple Google Drive accounts simultaneously. CassielDrive bypasses standard storage limits by seamlessly aggregating your storage. Effortlessly hop between linked accounts, treating multiple 15GB limits as one massive, unified cloud drive.

### 🔒 Military-Grade AES-256 Secure Vault
Privacy is absolute. The internal Cassiel Vault provides military-grade **AES-256 local encryption** for your most sensitive files. Before a file ever touches the cloud, it is encrypted locally on your device, ensuring total privacy even if your cloud provider is compromised.

### 💻 Widescreen Desktop Optimization & Adaptive UI
Unlike standard mobile ports, CassielDrive respects widescreen web and desktop environments. Complete with strict `800px` `maxWidth` constraints natively coded into the UI, the Web App prevents awkward ultra-wide stretching, guaranteeing a focused, premium layout whether on a 4K monitor or an Android screen.

### 🧭 Minimalist Floating Navigation Pill
We ditched the heavy, screen-consuming bottom navigation bars. CassielDrive utilizes a modern, non-obstructive **Top-Right Floating Navigation Pill**. It stays out of your way, maximizing the screen real-estate for your files and folder grids. 

### 🌌 OLED-Optimized Dynamic Themes & 3D CSS
Experience deep-dark layouts hand-tailored for OLED displays, featuring dynamic ambient backgrounds and frosted glassmorphism containers. Beyond the app, our standalone promotional site features an immersive **pure HTML/CSS 3D device mockup**, completely bypassing the need for heavy image assets while delivering buttery smooth 120Hz keyframe animations.

### 🌐 Advanced Dual-Routing Vercel Deployment
Through a highly customized `vercel.json` deployment pipeline, CassielDrive dynamically supports dual-hosting on a single domain. The Flutter Web App runs natively on the root `/#/home` acting as a localized SPA (Single Page Application), while our lightweight 3D marketing website is compiled and injected directly into the Flutter static build directory to be seamlessly served alongside it on the `/welcome/` subpath.

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


## 🔍 SEO & Discoverability
*Keywords:* Google Drive Client, Unlimited Cloud Storage, Flutter File Manager, AES-256 Encryption, Self-Hosted Cloud, Open Source Flutter App, Android Drive App, Web Storage App, CassielDrive, OAuth2 Cloud Integration, Vercel Deployment, Secure Cloud Vault

**Hashtags:** #GoogleDrive #CloudStorage #FlutterDev #OpenSource #AESEncryption #Privacy #WebDeployment #AndroidApp #UIUXDesign #CassielDrive

---

<br/>

<div align="center">
  <b>Made with ?? by Cassiel</b>
  <br/>
  <small>Open Source � Transparent � Limitless</small>
</div>
