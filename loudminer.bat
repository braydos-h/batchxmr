@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM XMRig Monero Miner Setup Script (Admin-Free Version) with Enhancements
REM
REM Enhancements:
REM  • Checksum validation using SHA256
REM  • Centralized logging to file
REM  • Command-line parameter overrides (WALLET, POOL, XMRIG_VERSION)
REM  • Tool existence check for PowerShell and certutil
REM  • Dynamic retry logic with exponential backoff
REM  • Cleanup of temporary files after extraction
REM  • Improved error handling and exit codes
REM ============================================================

REM ----- Configuration Variables -----
REM Default values can be overridden via command-line arguments:
REM   %1 - WALLET address
REM   %2 - POOL URL (e.g., pool.hashvault.pro:443)
REM   %3 - XMRig version

if not "%~1"=="" set "WALLET=%~1"
if not defined WALLET set "WALLET=4BKmqkuobnj6MNsW78CLzS6ivQjZWqXppf6bbJsp4xW2KfvasaeEw2FL1A5HnGENyN2eardtcrWtg7JFrCMNDbmtM4vePEm"

if not "%~2"=="" set "POOL=%~2"
if not defined POOL set "POOL=pool.hashvault.pro:443"

if not "%~3"=="" set "XMRIG_VERSION=%~3"
if not defined XMRIG_VERSION set "XMRIG_VERSION=6.22.2"

set "ZIP_FILE=xmrig-%XMRIG_VERSION%-msvc-win64.zip"
set "DOWNLOAD_URL=https://github.com/xmrig/xmrig/releases/download/v%XMRIG_VERSION%/%ZIP_FILE%"

REM Expected SHA256 Checksum for version 6.22.2
set "EXPECTED_CHECKSUM=1d903d39c7e4e1706c32c44721d6a6c851aa8c4c10df1479478ee93cd67301bc"

REM ----- Determine Target Directory and Logging -----
set "TARGET_DIR=%LOCALAPPDATA%\xmrig"
set "LOG_FILE=%TARGET_DIR%\xmrig_setup.log"

if not exist "%TARGET_DIR%" (
    md "%TARGET_DIR%" 2>nul
    if errorlevel 1 (
        echo [!] Failed to create directory at %TARGET_DIR%
        echo [%date% %time%] Failed to create directory at %TARGET_DIR% >> "%LOG_FILE%"
        pause
        exit /b 1
    )
)
echo [*] Using target directory: "%TARGET_DIR%"
echo [%date% %time%] Using target directory: "%TARGET_DIR%" >> "%LOG_FILE%"

REM ----- Check for Required Tools -----
where powershell >nul 2>&1
if errorlevel 1 (
    echo [!] PowerShell is required but not found.
    echo [%date% %time%] PowerShell is required but not found. >> "%LOG_FILE%"
    pause
    exit /b 1
)
where certutil >nul 2>&1
if errorlevel 1 (
    echo [!] certutil is required but not found.
    echo [%date% %time%] certutil is required but not found. >> "%LOG_FILE%"
    pause
    exit /b 1
)

REM ----- Download with Multiple Fallback Methods -----
set RETRIES=0
set MAX_RETRIES=3

:DownloadLoop
echo [*] Downloading XMRig from %DOWNLOAD_URL%...
echo [%date% %time%] Attempting download from %DOWNLOAD_URL% >> "%LOG_FILE%"

REM Attempt download using PowerShell with TLS 1.2
powershell -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Try { (New-Object Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TARGET_DIR%\%ZIP_FILE%') } Catch { exit 1 }" >> "%LOG_FILE%" 2>&1

if not exist "%TARGET_DIR%\%ZIP_FILE%" (
    echo [!] PowerShell download failed, trying certutil...
    echo [%date% %time%] PowerShell download failed, trying certutil... >> "%LOG_FILE%"
    certutil -urlcache -split -f "%DOWNLOAD_URL%" "%TARGET_DIR%\%ZIP_FILE%" >nul 2>&1
)

if not exist "%TARGET_DIR%\%ZIP_FILE%" (
    set /a RETRIES+=1
    if %RETRIES% GEQ %MAX_RETRIES% (
        echo [!] Download failed after %RETRIES% attempts.
        echo [%date% %time%] Download failed after %RETRIES% attempts. >> "%LOG_FILE%"
        pause
        exit /b 1
    )
    set /a DELAY=3 * %RETRIES%
    echo [*] Retrying download in %DELAY% seconds...
    echo [%date% %time%] Retrying download in %DELAY% seconds... >> "%LOG_FILE%"
    timeout /t %DELAY% >nul
    goto DownloadLoop
)
echo [√] Download successful.
echo [%date% %time%] Download successful. >> "%LOG_FILE%"

REM ----- Verify Download with Checksum Validation -----
echo [*] Verifying checksum...
for /f "usebackq tokens=*" %%i in (`powershell -Command "Get-FileHash -Algorithm SHA256 '%TARGET_DIR%\%ZIP_FILE%' | ForEach-Object { $_.Hash }"`) do set "FILE_CHECKSUM=%%i"
echo [*] Expected: %EXPECTED_CHECKSUM%
echo [*] Got: %FILE_CHECKSUM%
if /i not "%FILE_CHECKSUM%"=="%EXPECTED_CHECKSUM%" (
    echo [!] Checksum verification failed.
    echo [%date% %time%] Checksum verification failed. Expected: %EXPECTED_CHECKSUM% Got: %FILE_CHECKSUM% >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [√] Checksum verification passed.
echo [%date% %time%] Checksum verification passed. >> "%LOG_FILE%"

REM ----- Extraction with Robust Validation -----
set RETRIES=0
:ExtractLoop
echo [*] Extracting %ZIP_FILE%...
echo [%date% %time%] Extracting %ZIP_FILE% >> "%LOG_FILE%"
powershell -Command "Expand-Archive -Path '%TARGET_DIR%\%ZIP_FILE%' -DestinationPath '%TARGET_DIR%' -Force" >> "%LOG_FILE%" 2>&1

REM Locate the extracted directory (assumes directory name starts with 'xmrig-')
set "MINER_DIR="
for /d %%I in ("%TARGET_DIR%\xmrig-*") do set "MINER_DIR=%%I"

if not defined MINER_DIR (
    set /a RETRIES+=1
    if %RETRIES% GEQ %MAX_RETRIES% (
        echo [!] Extraction failed after %RETRIES% attempts.
        echo [%date% %time%] Extraction failed after %RETRIES% attempts. >> "%LOG_FILE%"
        pause
        exit /b 1
    )
    set /a DELAY=2 * %RETRIES%
    echo [*] Retrying extraction in %DELAY% seconds...
    echo [%date% %time%] Retrying extraction in %DELAY% seconds... >> "%LOG_FILE%"
    timeout /t %DELAY% >nul
    goto ExtractLoop
)
echo [√] Extracted to: "%MINER_DIR%"
echo [%date% %time%] Extraction successful to: "%MINER_DIR%" >> "%LOG_FILE%"

REM ----- Cleanup: Remove Downloaded ZIP File -----
del "%TARGET_DIR%\%ZIP_FILE%" >nul 2>&1
echo [*] Cleaned up ZIP file.
echo [%date% %time%] Cleaned up ZIP file. >> "%LOG_FILE%"

REM ----- Miner Execution with Validation -----
pushd "%MINER_DIR%"
if not exist "xmrig.exe" (
    echo [!] xmrig.exe not found in "%MINER_DIR%"
    echo [%date% %time%] xmrig.exe not found in "%MINER_DIR%" >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo [*] Starting XMRig miner in background...
echo [%date% %time%] Starting xmrig.exe with parameters -o "%POOL%" -u "%WALLET%" >> "%LOG_FILE%"
start "" /B "xmrig.exe" -o "%POOL%" -u "%WALLET%" -p x --tls --donate-level=0

popd
echo [√] Miner started successfully. Check Task Manager for xmrig.exe process.
echo [%date% %time%] Miner started successfully. >> "%LOG_FILE%"
pause
endlocal
