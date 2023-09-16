@echo off
set folder="build_output"
if exist %folder% rmdir /s /q %folder%
mkdir %folder%

:: Android
echo Building Android
call flutter build apk
call flutter build appbundle
if not exist %folder%\android mkdir %folder%\android
move build\app\outputs\apk\release\app-release.apk %folder%\android\app-release.apk
move build\app\outputs\bundle\release\app-release.aab %folder%\android\app-release.aab

:: Web
echo Building Web
call flutter build web
move build\web %folder%\web

:: Windows
echo Building Windows
call flutter build windows
if not exist %folder%\windows mkdir %folder%\windows
move build\windows\x64\runner\Release\* %folder%\windows