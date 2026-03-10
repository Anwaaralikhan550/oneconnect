@echo off
echo ========================================
echo Flutter Gradle Fix Script
echo ========================================
echo.

echo [1/5] Stopping Java processes...
taskkill /F /IM java.exe /T 2>nul
timeout /T 2 /NOBREAK >nul

echo [2/5] Clearing Gradle caches...
rd /S /Q "%USERPROFILE%\.gradle" 2>nul
rd /S /Q "D:\oneconnect\android\.gradle" 2>nul
rd /S /Q "D:\oneconnect\android\build" 2>nul

echo [3/5] Cleaning Flutter build...
cd /D "D:\oneconnect"
call flutter clean

echo [4/5] Enabling symlink support...
fsutil behavior set SymlinkEvaluation L2L:1 R2R:1 L2R:1 R2L:1

echo [5/5] Running Flutter...
call flutter run

echo.
echo ========================================
echo Script completed!
echo ========================================
pause