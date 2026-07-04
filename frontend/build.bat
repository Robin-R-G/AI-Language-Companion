@echo off
REM Build script for AI Language Coach Flutter project
REM Run this script after modifying Freezed models, Riverpod providers, or JSON serializable classes

echo === Cleaning generated files ===
flutter clean
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Getting dependencies ===
flutter pub get
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Running build_runner (code generation) ===
dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Running dart format ===
dart format lib/
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Running flutter analyze ===
flutter analyze
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Build complete ===
echo All code generated, formatted, and analyzed successfully.
