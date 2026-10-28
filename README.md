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
- **Built-in updates** from GitHub: the app checks for a new release (at most twice a day, can be turned off) and installs it in two taps.
- Small and private: about 1 MB, no ads, no tracking, no analytics. The only network request is the update check to GitHub.

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

Open the app and tap the **gear icon** (top right) → **Check for updates** → **Update to vX.Y.Z**, then confirm on Android's install screen. The first time, Android asks you to allow the app to install updates.

With **Check for updates automatically** on, the app looks for a new version when it opens (at most every 12 hours) and offers it in a dialog. Release builds update from the release APK, debug builds from the debug APK.

## Permissions

| Permission | Why |
| --- | --- |
| Notifications, foreground service | Keep the volume notification visible |
| Internet | Check GitHub for updates and download them |
| Install packages | Hand a downloaded update to Android's installer (you always confirm) |

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

The workflow builds both APKs, signs them and publishes the GitHub release that the in-app updater reads. Versions must be `X.Y.Z`; the version code is derived from it, so every release must be higher than the last.

**Signing.** Updates only install over an app signed with the same key. Builds use the key in `keystore/` unless the repository secrets `KEYSTORE_B64`, `STORE_PASSWORD`, `KEY_ALIAS` and `KEY_PASSWORD` are set, in which case that private key is used. Switching keys means uninstalling once.

## Testing

The **Emulator test** workflow boots an Android 15 emulator, installs the debug APK and drives it like a user (`scripts/emulator-test.sh`): starts the service, taps each notification button and checks the real volume and mute state, opens and closes the panel, and confirms other apps cannot open the panel. Run it with an **old version** (for example `0.9.0`) to test the updater end to end (`scripts/update-test.sh`).

## Project layout

```
app/src/main/java/com/example/
  MainActivity.kt          on/off switch and overview
  VolumeService.kt         foreground service and notification
  VolumeReceiver.kt        notification button actions
  VolumePanelActivity.kt   volume sliders panel
  update/                  GitHub updater, Settings screen, install receiver
```
