#!/bin/bash
# Emulator test for QuickVolumeControl: install the debug APK and drive it like a user.
source scripts/emulator-lib.sh
PKG=com.aistudio.quickvolume.vbnmzx
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
# The 4th action only shows in the expanded notification; the system chevron is also labelled "Expand"
tap resource-id='(?!.*expand_button).*' content-desc=Expand || { tap resource-id='.*expand_button'; shot shade-expanded; tap resource-id='(?!.*expand_button).*' content-desc=Expand; }
sleep 2; shot panel
info(){ RESULTS="$RESULTS%0AINFO  $1"; }
adb shell cmd statusbar expand-notifications; sleep 1; dump
info "shade nodes: $(python3 -c "
import xml.etree.ElementTree as E
print(' | '.join(f\"{n.get('resource-id','').split('/')[-1]}:{n.get('content-desc') or n.get('text')}\" for n in E.parse('ui.xml').iter('node') if n.get('package')=='com.android.systemui' and (n.get('content-desc') or n.get('text')) and ('action' in n.get('resource-id','') or 'expand' in n.get('resource-id','') or n.get('text') in ('Volume Control','Quick Volume Control'))))
")"
adb shell am start -W -n com.aistudio.quickvolume.vbnmzx/com.example.MainActivity >/dev/null; adb shell cmd statusbar expand-notifications; sleep 1
tap resource-id='(?!.*expand_button).*' content-desc=Expand && info "tapped Expand action" || info "Expand action not found"
sleep 2; info "resumed: $(adb shell dumpsys activity activities | grep -m1 'topResumedActivity\|mResumedActivity' | tr -s ' ')"
info "logcat: $(adb logcat -d | grep -i 'VolumePanel\|BAL_BLOCK\|Background activity launch\|blocked' | tail -3 | tr '\n' ' ' | cut -c1-400)"
check "Expand opens volume panel" "screen_has 'Volume Controls'" "saw: $(texts)"
tap text='Volume Controls'; sleep 1; shot panel-tap-inside
check "tap inside the card keeps panel open" "screen_has 'Volume Controls'" "panel closed"
adb shell input tap 540 60; sleep 2; shot panel-tap-outside
check "tap outside closes panel" "! screen_has 'Volume Controls'" "panel still open"
R=$(adb shell am start -n $PKG/com.example.VolumePanelActivity 2>&1)
check "other apps cannot launch VolumePanelActivity" "echo '$R' | grep -qi 'denial\|not exported\|SecurityException'" "launched: $R"
adb shell am start -W -n $PKG/com.example.MainActivity; sleep 2
tap checkable=true; sleep 2; shot service-off
check "switch stops VolumeService" "! adb shell dumpsys activity services $PKG | grep -q 'ServiceRecord.*VolumeService'" "still running"
check "app crashed: none" "! adb logcat -d -b crash | grep -q $PKG" "$(adb logcat -d -b crash | grep -m3 -A3 FATAL | tr '\n' ' ')"
summary
