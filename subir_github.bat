@echo off
setlocal

cd /d "%~dp0"

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo Esta carpeta no esta conectada a un repositorio Git.
  pause
  exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo Este repositorio no tiene configurado el remoto origin.
  pause
  exit /b 1
)

set "HAS_CHANGES="
for /f "delims=" %%A in ('git status --porcelain') do (
  set "HAS_CHANGES=1"
  goto :changes_found
)

:changes_found
if not defined HAS_CHANGES (
  echo No hay cambios para subir.
  pause
  exit /b 0
)

echo.
echo Escribi el mensaje del commit:
set /p COMMIT_MSG=

if not defined COMMIT_MSG (
  set "COMMIT_MSG=Actualizar juego"
)

echo.
echo Subiendo cambios a GitHub...
for /f "delims=" %%A in ('git branch --show-current') do set "CURRENT_BRANCH=%%A"

git add .
if errorlevel 1 goto :error

git commit -m "%COMMIT_MSG%"
if errorlevel 1 goto :error

git push -u origin %CURRENT_BRANCH%
if errorlevel 1 goto :error

echo.
echo Listo. Los cambios fueron subidos a GitHub.
pause
exit /b 0

:error
echo.
echo Hubo un problema al subir los cambios.
pause
exit /b 1
