@echo off
setlocal enabledelayedexpansion
rem ---------------------------------------------------------------------------
rem One-time setup for the full Gmail MCP server (ArtyMcLabin/Gmail-MCP-Server,
rem npm @artymclabin/gmail-mcp). Gives your assistant real Gmail FILTERS and
rem 50-at-a-time labelling, which the built-in Gmail connectors cannot do.
rem
rem Nothing is uploaded anywhere except to Google. The server runs locally.
rem Read INSTALL.md in this folder first if anything below is unclear.
rem ---------------------------------------------------------------------------

set "KEYS_DIR=%USERPROFILE%\.gmail-mcp"

echo.
echo ==========================================================
echo   Gmail MCP server - one-time setup
echo ==========================================================
echo.

rem --- 0. Node check -------------------------------------------------------
where node >nul 2>&1
if errorlevel 1 (
  echo   Node.js is not installed, and this server needs it.
  echo   Install Node 18 or newer from https://nodejs.org and run this again.
  echo.
  pause
  exit /b 1
)

rem --- 1. OAuth client file ------------------------------------------------
echo [1/4] Your Google OAuth client file.
echo.
echo   You need the JSON you downloaded from Google Cloud when you created an
echo   OAuth 2.0 client of type "Desktop app". See INSTALL.md if you have not
echo   made one yet.
echo.

set "KEYS_SRC="
if exist "%~dp0gcp-oauth.keys.json" (
  set "KEYS_SRC=%~dp0gcp-oauth.keys.json"
  echo   Found gcp-oauth.keys.json next to this installer. Using it.
) else (
  echo   Drag that JSON file into this window and press Enter
  echo   (or paste its full path^):
  set /p "KEYS_SRC=  > "
)

rem strip surrounding quotes if the drag added them
set "KEYS_SRC=!KEYS_SRC:"=!"

if not exist "!KEYS_SRC!" (
  echo.
  echo   Could not find that file. Nothing was changed. Run this again.
  echo.
  pause
  exit /b 1
)

if not exist "%KEYS_DIR%" mkdir "%KEYS_DIR%"
copy /Y "!KEYS_SRC!" "%KEYS_DIR%\gcp-oauth.keys.json" >nul
if errorlevel 1 (
  echo   Could not copy the client file into %KEYS_DIR%.
  echo.
  pause
  exit /b 1
)
echo   done.

rem --- 2. Enable the Gmail API --------------------------------------------
echo.
echo [2/4] Switching the Gmail API on for that Google Cloud project.
echo   A browser page opens. Click the blue ENABLE button.
echo   If it already says MANAGE, it is on and there is nothing to do.
echo.
start "" "https://console.cloud.google.com/apis/library/gmail.googleapis.com"
echo   When that is done, come back here and press any key.
pause >nul

rem --- 3. Sign in ----------------------------------------------------------
echo.
echo [3/4] Google sign-in.
echo   A browser tab opens. Choose the account whose mail you want sorted,
echo   click "Continue" past the unverified-app warning (it is your own app^),
echo   then Allow.
echo.
call npx -y @artymclabin/gmail-mcp auth
if errorlevel 1 (
  echo.
  echo   Sign-in did not complete. The usual cause is that your Google address
  echo   is not listed under "Test users" on the OAuth consent screen.
  echo   Add it there, then run this installer again.
  echo.
  pause
  exit /b 1
)

rem --- 4. Register with Claude Code ---------------------------------------
echo.
echo [4/4] Registering the server with Claude Code as "gmail-full"...
where claude >nul 2>&1
if errorlevel 1 (
  echo.
  echo   Claude Code is not on your PATH, so this step was skipped.
  echo   Sign-in above still succeeded. Add the server to your MCP client by
  echo   hand using the JSON snippet at the bottom of INSTALL.md.
) else (
  call claude mcp add -s user gmail-full -- npx -y @artymclabin/gmail-mcp
)

echo.
echo ==========================================================
echo   Done.
echo.
echo   RESTART your assistant now. The new tools are not visible
echo   in the session that installed them.
echo ==========================================================
echo.
pause
