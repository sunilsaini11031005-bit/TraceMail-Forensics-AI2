@echo off
title TraceMail Forensics AI - dev server
cd /d "%~dp0"

echo.
echo  ============================================
echo   TraceMail Forensics AI - starting up
echo  ============================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  if exist "C:\Program Files\nodejs\node.exe" (
    set "PATH=C:\Program Files\nodejs;%PATH%"
  ) else (
    echo  [X] Node.js not found.
    echo      Install it from https://nodejs.org and run this file again.
    echo.
    pause
    exit /b 1
  )
)

for /f "tokens=*" %%v in ('node --version') do echo  [ok] Node %%v

if not exist "node_modules\" (
  echo  [..] Installing frontend dependencies, this takes a few minutes...
  call npm install
  if errorlevel 1 goto fail
)

if not exist "server\node_modules\" (
  echo  [..] Installing backend dependencies...
  pushd server
  call npm install
  if errorlevel 1 (
    popd
    goto fail
  )
  popd
)

echo.
echo   Frontend : http://localhost:5173
echo   Backend  : http://localhost:3001
echo   Login    : admin / admin123    ^<-- change this after first login
echo.
echo   The browser opens by itself in a few seconds.
echo   To stop the server: press Ctrl+C in this window, twice.
echo.

start "" cmd /c "timeout /t 7 /nobreak >nul & start "" http://localhost:5173"

call npm run dev:full
goto done

:fail
echo.
echo  [X] npm install failed - read the errors above.
echo      Most common cause: no internet, or a proxy blocking the npm registry.

:done
echo.
echo  Server stopped.
pause
