#!/bin/bash
# Emulator test for QuickVolumeControl: install the debug APK and drive it like a user.
source scripts/emulator-lib.sh
PKG=com.aistudio.quickvolume.vbnmzx.debug  # debug builds carry the .debug suffix
vol(){ adb shell cmd media_session volume --stream 3 --get 2>/dev/null | grep -o 'volume is [0-9]*' | grep -o '[0-9]*$'; }
muted(){ adb shell dumpsys audio | grep -A3 '^- STREAM_MUSIC:' | grep -q 'Muted: true'; }
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell pm grant $PKG android.permission.POST_NOTIFICATIONS
adb shell am start -W -n $PKG/com.example.MainActivity; sleep 3; shot main
check "main screen shows inactive service" "screen_has 'Service is Inactive'" "saw: $(texts)"
tap checkable=true; sleep 2; shot service-on
check "switch starts VolumeService" "adb shell dumpsys activity services $PKG | grep -q VolumeService" "service not running"
check "main screen shows active service" "screen_has 'Service is Active'" "saw: $(texts)"
adb shell cmd media_session volume --stream 3 --set 5; sleep 1
adb shell cmd statusbar expand-notifications; sleep 2; shot shade
check "notification has Up/Down/Mute actions" "screen_has 'Up' && screen_has 'Mute' && screen_has 'Down'" "actions missing"
tap resource-id='(?!.*expand_button).*' content-desc=Up; V=$(vol)
check "Up raises media volume 5 -> 6" "[ '$V' = 6 ]" "got $V"
adb shell cmd statusbar expand-notifications; sleep 1
tap resource-id='(?!.*expand_button).*' content-desc=Down; V=$(vol)
check "Down lowers media volume 6 -> 5" "[ '$V' = 5 ]" "got $V"
adb shell cmd statusbar expand-notifications; sleep 1
tap resource-id='(?!.*expand_button).*' content-desc=Mute; sleep 1
check "Mute mutes media at volume 5" "muted" "not muted"
adb shell cmd statusbar expand-notifications; sleep 1
tap resource-id='(?!.*expand_button).*' content-desc=Mute; sleep 1
check "Mute again unmutes" "! muted" "still muted"
adb shell cmd statusbar expand-notifications; sleep 1
# Tapping the notification body opens the panel (the 4th "Expand" action is not rendered on Android 13+)
info(){ RESULTS="$RESULTS%0AINFO  $1"; }
tap text='Tap for all volume sliders' || info "notification text not found"; sleep 2; shot panel
info "after notification tap, resumed: $(adb shell dumpsys activity activities | grep -m1 topResumedActivity | grep -o '[^ /]*/[^ ]*')"
check "tapping the notification opens volume panel" "screen_has 'Volume Controls'" "saw: $(texts)"
tap text='Volume Controls'; sleep 1; shot panel-tap-inside
check "tap inside the card keeps panel open" "screen_has 'Volume Controls'" "panel closed"
# Tap halfway between the top of the screen and the card's title (screen size varies by emulator profile)
dump; TOP=$(grep -o 'text="Volume Controls"[^>]*bounds="\[[0-9]*,[0-9]*' ui.xml | grep -o '[0-9]*$')
info "screen $(adb shell wm size | grep -o '[0-9]*x[0-9]*'), title top y=$TOP, tapping y=$((TOP/2))"
adb shell input tap 100 $((TOP/2)); sleep 2; shot panel-tap-outside
check "tap outside closes panel" "! screen_has 'Volume Controls'" "panel still open"
R=$(adb shell am start -n $PKG/com.example.VolumePanelActivity 2>&1)
check "other apps cannot launch VolumePanelActivity" "echo '$R' | grep -qi 'denial\|not exported\|SecurityException'" "launched: $R"
# Premise check: does the panel render when launched directly (as root, bypassing export rules)?
adb root >/dev/null 2>&1; sleep 3; adb wait-for-device
adb shell am start -W -n $PKG/com.example.VolumePanelActivity >/dev/null 2>&1; sleep 2; shot panel-direct
info "direct launch resumed: $(adb shell dumpsys activity activities | grep -m1 topResumedActivity | grep -o '[^ /]*/[^ ]*')"
check "panel renders when launched directly" "screen_has 'Volume Controls'" "saw: $(texts)"
adb shell input keyevent KEYCODE_BACK; sleep 1
adb shell am start -W -n $PKG/com.example.MainActivity; sleep 2
tap checkable=true; sleep 2; shot service-off
check "switch stops VolumeService" "! adb shell dumpsys activity services $PKG | grep -q 'ServiceRecord.*VolumeService'" "still running"
check "app crashed: none" "! adb logcat -d -b crash | grep -q $PKG" "$(adb logcat -d -b crash | grep -m3 -A3 FATAL | tr '\n' ' ')"
summary
