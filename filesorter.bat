@echo off 
setlocal EnableExtensions EnableDelayedExpansion 
 
REM ========================= 
REM CONFIG 
REM ========================= 
set "DROPBOX=C:\filesorter\dropbox" 
set "BASE=C:\filesorter\autocreate" 
 
REM 1 = move each file into the final folder after creating it 
REM 0 = just create folders (no moving) 
set "MOVE_FILES=1" 
 
REM Where to put non-matching files (optional) 
set "QUARANTINE=%DROPBOX%\_unmatched" 
 
REM Log folder 
set "LOGDIR=%BASE%\logs" 
 
REM ========================= 
REM PresentDate (stable): yyyyMMdd 
REM ========================= 
for /f %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "PDATE=%%D" 
 
REM Log file: one per day 
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1 
set "LOGFILE=%LOGDIR%\filesorter_%PDATE%.log" 
 
call :Log "============================================================" 
call :Log "START | dropbox=%DROPBOX% | move_files=%MOVE_FILES% | date=%PDATE%" 
call :Log "============================================================" 
 
for %%F in ("%DROPBOX%\*.*") do ( 
 if exist "%%~fF" ( 
 call :ProcessOne "%%~fF" 
 ) 
) 
 
call :Log "============================================================" 
call :Log "END" 
call :Log "============================================================" 
 
endlocal 
exit /b 
 
 
:ProcessOne 
set "FULL=%~1" 
 
for %%A in ("%FULL%") do ( 
 set "FILENAME=%%~nxA" 
 set "NOEXT=%%~nA" 
 set "EXT=%%~xA" 
) 
 
REM Skip our own log files and folders if any accidentally match 
if /I "%EXT%"==".log" exit /b 
 
REM ========================= 
REM STRICT PATTERN CHECK: 
REM Only accept NOEXT with exactly 3 tokens: token1_token2_token3 
REM i.e., exactly TWO underscores in NOEXT 
REM ========================= 
set "T1=" 
set "T2=" 
set "T3=" 
set "T4=" 
 
for /f "tokens=1-4 delims=_" %%i in ("%NOEXT%") do ( 
 set "T1=%%i" 
 set "T2=%%j" 
 set "T3=%%k" 
 set "T4=%%l" 
) 
 
REM Reject if missing any of first 3 tokens OR has a 4th token 
if not defined T1 goto :NoMatch 
if not defined T2 goto :NoMatch 
if not defined T3 goto :NoMatch 
if defined T4 goto :NoMatch 
 
REM Build folder names 
set "LEVEL1=%T1%" 
set "LEVEL2=%T1%_%T2%" 
set "FINAL=%T1%_%T2%_%PDATE%_%T3%" 
 
REM Create folder tree (log each mkdir) 
set "TARGET=%BASE%\%LEVEL1%" 
call :EnsureDir "!TARGET!" "%FILENAME%" 
 
set "TARGET=%BASE%\%LEVEL1%\%LEVEL2%" 
call :EnsureDir "!TARGET!" "%FILENAME%" 
 
set "TARGET=%BASE%\%LEVEL1%\%LEVEL2%\%FINAL%" 
call :EnsureDir "!TARGET!" "%FILENAME%" 
 
call :Log "[OK] %FILENAME% -> %LEVEL1%\%LEVEL2%\%FINAL%" 
 
REM Optional move 
if "%MOVE_FILES%"=="1" ( 
 REM Determine a non-overwriting destination filename 
 call :GetUniqueDupName "!TARGET!" "!NOEXT!" "!EXT!" "!FILENAME!" 
 
 call :Log "[MOVE] %FILENAME% -> !TARGET!\!UNIQUE_NAME!" 
 move "%FULL%" "!TARGET!\!UNIQUE_NAME!" >nul 2>&1 
 
 if errorlevel 1 ( 
 call :Log "[ERROR] move failed for %FILENAME% -> !TARGET!\!UNIQUE_NAME!" 
 ) else ( 
 call :Log "[MOVED] %FILENAME% -> !TARGET!\!UNIQUE_NAME!" 
 ) 
) 
 
exit /b 
 
 
:NoMatch 
call :Log "[SKIP] %FILENAME% (pattern != xxx_xxx_xxx)" 
 
REM Optional quarantine (uncomment if you want) 
REM if not exist "%QUARANTINE%" mkdir "%QUARANTINE%" >nul 2>&1 
REM move "%FULL%" "%QUARANTINE%\" >nul 2>&1 
REM if errorlevel 1 (call :Log "[ERROR] quarantine move failed for %FILENAME%") else (call :Log "[QUAR] %FILENAME% -> %QUARANTINE%") 
 
exit /b 
 
 
:EnsureDir 
REM %~1 = dir path, %~2 = filename (for context) 
if exist "%~1" ( 
 call :Log "[DIR] exists: %~1" 
) else ( 
 mkdir "%~1" >nul 2>&1 
 if errorlevel 1 ( 
 call :Log "[ERROR] mkdir failed: %~1 (from %~2)" 
 ) else ( 
 call :Log "[DIR] created: %~1" 
 ) 
) 
exit /b 
 
:GetUniqueDupName 
REM Inputs: 
REM %~1 = destination folder 
REM %~2 = base filename without extension (NOEXT) 
REM %~3 = extension including dot (EXT) 
REM Output: 
REM sets UNIQUE_NAME (filename only) 
 
setlocal EnableDelayedExpansion 
set "DEST=%~1" 
set "B=%~2" 
set "E=%~3" 
 
set "CANDIDATE=!B!!E!" 
if not exist "!DEST!\!CANDIDATE!" ( 
 endlocal & set "UNIQUE_NAME=%B%%E%" 
 exit /b 
) 
 
set "N=1" 
:dup_loop 
if "!N!"=="1" ( 
 set "CANDIDATE=!B!_DUP!E!" 
) else ( 
 set "CANDIDATE=!B!_DUP!N!!E!" 
) 
 
if exist "!DEST!\!CANDIDATE!" ( 
 set /a N+=1 
 goto :dup_loop 
) 
 
endlocal & set "UNIQUE_NAME=%CANDIDATE%" 
exit /b 
 
REM If original exists, try DUP, DUP2, DUP3... 
set "N=1" 
:dup_loop 
if "!N!"=="1" ( 
 set "CANDIDATE=%B%_DUP%E%" 
) else ( 
 set "CANDIDATE=%B%_DUP!N!%E%" 
) 
 
if exist "%DEST%\%CANDIDATE%" ( 
 set /a N+=1 
 goto :dup_loop 
) 
 
endlocal & set "UNIQUE_NAME=%CANDIDATE%" 
exit /b 
 
:Log 
REM Timestamp each log line with date+time from PowerShell (stable) 
for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-ddTHH:mm:ss"') do set "TS=%%T" 
>> "%LOGFILE%" echo %TS% %* 
echo %TS% %* 
exit /b
