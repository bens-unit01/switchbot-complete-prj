@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:menu
echo.
echo Package for target
echo.
echo Android:
echo.
echo  [1] normal       (apk)
echo  [2] debug        (apk-debug)
echo  [3] captive      (apk-captive-runtime)
echo.
echo iOS:
echo.
echo  [4] fast test    (ipa-test-interpreter)
echo  [5] fast debug   (ipa-debug-interpreter)
echo  [6] slow test    (ipa-test)
echo  [7] slow debug   (ipa-debug)
echo  [8] "ad-hoc"     (ipa-ad-hoc)
echo  [9] App Store    (ipa-app-store)
echo.

:choice


set PLATFORM=android
set OPTIONS=
set TARGET=-captive-runtime

call bat\Packager.bat

if "%PLATFORM%"=="android" goto android-package

:ios-package
if "%AUTO_INSTALL_IOS%" == "yes" goto ios-install
echo Now manually install and start application on device
echo.
goto end

:ios-install
echo Installing application for testing on iOS (%DEBUG_IP%)
echo.
call adt -installApp -platform ios -package "%OUTPUT%"
if errorlevel 1 goto installfail

echo Now manually start application on device
echo.
goto end

:android-package
adb devices
echo.
echo Packaging completed ...
echo.
::adb -d install -r "%OUTPUT%"
echo Installing ...
cd dist
adb install -r  TelepresenceUser-captive-runtime.apk
if errorlevel 1 goto installfail
goto end

:installfail
echo.
echo Installing the app on the device failed

:end
pause
