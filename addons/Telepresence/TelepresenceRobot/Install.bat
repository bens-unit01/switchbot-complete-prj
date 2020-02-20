@echo off
echo.
echo Installing the app ...
cd dist
adb install -r TelepresenceMegamip-captive-runtime.apk
::adb install -r TelepresenceMegamip-debug.apk
pause


