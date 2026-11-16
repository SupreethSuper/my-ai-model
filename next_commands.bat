
@echo off
cd /d "%~dp0"
setlocal

echo ===== CHECKING BRANCH =====
git switch main
if errorlevel 1 goto failed

echo.
echo ===== STAGING SUBMODULE CONFIGURATION =====
git add .gitmodules bazel-orfs third_party/cocogfx third_party/cvfpu third_party/hardfloat third_party/ramulator third_party/softfloat tools/bsg_fakeram next_commands.bat
if errorlevel 1 goto failed

echo.
echo ===== REVIEWING COMMIT =====
git status
git diff --cached --stat

echo.
echo ===== COMMITTING =====
git commit -m "Add OpenROAD and third-party dependencies as submodules"
if errorlevel 1 goto failed

echo.
echo ===== PUSHING MAIN =====
git push origin main
if errorlevel 1 goto failed

echo.
echo SUCCESS: Main pushed to GitHub.
pause
exit /b 0

:failed
echo.
echo ERROR: Operation failed. Do not retry blindly.
pause
exit /b 1
