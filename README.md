<div align="center">
  <img src="docs/icon.png" width="96" alt="Quick Volume Control icon" />

  # Quick Volume Control

  Control your phone's volume from a notification, without touching the volume buttons.

  [![Download APK](https://img.shields.io/badge/Download-APK-3D5AFE?style=for-the-badge&logo=android&logoColor=white)](https://github.com/moansari1234/QuickVolumeControl/releases/latest/download/QuickVolumeControl.apk)
  [![Debug APK](https://img.shields.io/badge/Debug-APK-555555?style=for-the-badge&logo=android&logoColor=white)](https://github.com/moansari1234/QuickVolumeControl/releases/latest/download/QuickVolumeControl-debug.apk)
  [![Latest release](https://img.shields.io/github/v/release/moansari1234/QuickVolumeControl?style=for-the-badge)](https://github.com/moansari1234/QuickVolumeControl/releases/latest)
</div>

## What it does

- **Persistent notification** with **Volume down**, **Mute / unmute** and **Volume up** buttons for media volume.
- **Tap the notification** to open a full panel with sliders for media, ring, alarm and notification volume. Tap outside the panel to close it.
- Small and private: about 1 MB, no ads, no tracking, no analytics. No internet permission at all: the app never goes online.

## Install

1. Download **[QuickVolumeControl.apk](https://github.com/moansari1234/QuickVolumeControl/releases/latest/download/QuickVolumeControl.apk)** on your phone.
2. Open it. If Android asks, allow your browser or file manager to **install unknown apps**.
3. Open **Quick Volume Control**, turn the switch on and allow notifications.

Requires Android 7.0 (API 24) or newer.

### Release vs debug APK

| APK | Use it for | Package |
| --- | --- | --- |
| `QuickVolumeControl.apk` | Everyday use. Minified, about 1 MB. | `com.aistudio.quickvolume.vbnmzx` |
| `QuickVolumeControl-debug.apk` | Testing and bug reports. Installs next to the release build. | `com.aistudio.quickvolume.vbnmzx.debug` |

Each release also lists `SHA256SUMS.txt` so you can check a download.

## Updating

Open the app, tap the **gear icon** (top right) → **Download latest version**. That opens the [latest release](https://github.com/moansari1234/QuickVolumeControl/releases/latest) in your browser; download `QuickVolumeControl.apk` and install it over the old one. Your settings stay.

## Permissions

| Permission | Why |
| --- | --- |
| Notifications, foreground service | Keep the volume notification visible |

## Build from source

```bash
git clone https://github.com/moansari1234/QuickVolumeControl.git
cd QuickVolumeControl
gradle assembleDebug        # app/build/outputs/apk/debug/app-debug.apk
gradle assembleRelease      # app/build/outputs/apk/release/app-release.apk
```

Needs JDK 21 and Gradle 9.3+ (or open the folder in Android Studio). Kotlin, Jetpack Compose, Material 3.

## Releasing a new version

Push a tag, or run the **Release** workflow from the Actions tab with a version number:

```bash
git tag v1.0.1 && git push origin v1.0.1
```

The workflow builds both APKs, signs them and publishes the GitHub release. Versions must be `X.Y.Z`; the version code is derived from it, so every release must be higher than the last.

**Signing.** Updates only install over an app signed with the same key. Published APKs are signed with a private key in `keystore/release.p12`, encrypted with a random password kept only in the `SIGNING_PASSWORD` Actions secret, so nobody else can sign an update. Certificate SHA-256: `C1:BB:3B:B9:16:EC:73:63:A4:E9:15:CC:E4:B7:73:39:00:17:5D:A0:B3:E1:7B:77:5D:AA:FF:A8:13:25:0D:DA`. Local builds without that secret use the standard Android debug key and won't update a published install. APKs from v1.0.x used an old public key: uninstall them once before installing v1.1.0 or later.

## Testing

The **Emulator test** workflow boots an Android 15 emulator, installs the debug APK and drives it like a user (`scripts/emulator-test.sh`): starts the service, taps each notification button and checks the real volume and mute state, opens and closes the panel, and confirms other apps cannot open the panel.

## Project layout

```
app/src/main/java/com/example/
  MainActivity.kt          on/off switch and overview
  VolumeService.kt         foreground service and notification
  VolumeReceiver.kt        notification button actions
  VolumePanelActivity.kt   volume sliders panel
```
