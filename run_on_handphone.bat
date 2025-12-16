@echo off
REM ════════════════════════════════════════════════════════════
REM     AGRI-LINK FLUTTER APP - RUN ON HANDPHONE
REM ════════════════════════════════════════════════════════════

echo.
echo ════════════════════════════════════════════════════════════
echo     AGRI-LINK FLUTTER APP - HANDPHONE BUILD & RUN
echo ════════════════════════════════════════════════════════════
echo.

REM Check if adb is available
adb --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: ADB not found!
    echo Please install Android SDK or Android Studio first.
    pause
    exit /b 1
)

echo ════════════════════════════════════════════════════════════
echo     STEP 1: CHECK HANDPHONE CONNECTION
echo ════════════════════════════════════════════════════════════
echo.

adb devices
echo.

REM Check if device found
for /f "skip=1" %%a in ('adb devices') do (
    if "%%a" neq "" (
        if not "%%a"=="List of devices attached" (
            REM Extract device name and status
            for /f "tokens=2" %%s in ('echo %%a') do (
                if "%%s"=="device" (
                    set DEVICE_FOUND=1
                    set DEVICE_NAME=%%a
                    goto device_found
                )
            )
        )
    )
)

if not defined DEVICE_FOUND (
    echo.
    echo ⚠️  HANDPHONE NOT DETECTED!
    echo.
    echo Checklist:
    echo [ ] USB Debugging ENABLED on handphone?
    echo [ ] Permission popup ACCEPTED on handphone?
    echo [ ] USB cable properly connected?
    echo [ ] Using good quality USB cable (not charging only)?
    echo.
    echo For detailed instructions:
    echo - Read: RUN_ON_HANDPHONE_QUICK.txt
    echo - Read: USB_DEBUGGING_SETUP.txt
    echo.
    pause
    exit /b 1
)

:device_found
echo.
echo ✓ Handphone detected!
echo ✓ Ready to build and run app
echo.

echo ════════════════════════════════════════════════════════════
echo     STEP 2: NAVIGATE TO PROJECT
echo ════════════════════════════════════════════════════════════
echo.

cd /d "d:\SEMESTER 7\Pemrogaman_Mobile\TA_MOBILE\agri_link_app"

if not exist "pubspec.yaml" (
    echo ERROR: pubspec.yaml not found!
    echo Are you in the right directory?
    pause
    exit /b 1
)

echo Current directory: %cd%
echo.

echo ════════════════════════════════════════════════════════════
echo     STEP 3: CLEAN & BUILD
echo ════════════════════════════════════════════════════════════
echo.

echo Cleaning build cache...
flutter clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo ════════════════════════════════════════════════════════════
echo     STEP 4: BUILD & RUN ON HANDPHONE
echo ════════════════════════════════════════════════════════════
echo.

echo Starting build process...
echo This may take 5-10 minutes for first build...
echo.
echo DO NOT DISCONNECT USB CABLE DURING BUILD!
echo.

flutter run

echo.
echo ════════════════════════════════════════════════════════════
echo     BUILD COMPLETE!
echo ════════════════════════════════════════════════════════════
echo.
echo If app is running on your handphone:
echo   ✓ BUILD SUCCESS!
echo.
echo If there are errors:
echo   - Check terminal output above
echo   - Ensure USB Debugging is enabled
echo   - Try disconnecting and reconnecting USB
echo.

pause
