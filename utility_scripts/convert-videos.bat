@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT_DIR=%~dp0.."
set "ASSETS_DIR=%ROOT_DIR%\assets"

echo ========================================
echo Video Converter for Portfolio Website
echo ========================================
echo.

call :require_tool ffmpeg
if errorlevel 1 exit /b 1

call :require_tool ffprobe
if errorlevel 1 exit /b 1

call :detect_av1_encoder
if errorlevel 1 exit /b 1

if "%~1"=="" (
    echo ERROR: No files provided.
    echo.
    echo Usage: Drag and drop video files onto this batch file
    echo Naming hint: include "landing", "thumb", "thumbnail", or "preview"
    echo in the filename so the correct resolution preset is chosen automatically.
    echo.
    pause
    exit /b 1
)

if not exist "%ASSETS_DIR%" mkdir "%ASSETS_DIR%"

echo Processing videos...
echo.

:loop
if "%~1"=="" goto :done

call :process_video "%~1"
echo.
echo ----------------------------------------
echo.

shift
goto :loop

:done
echo ========================================
echo All videos processed.
echo ========================================
echo.
echo Output files are in the "assets" folder.
echo.
pause
exit /b 0

:require_tool
where %~1 >nul 2>nul
if errorlevel 1 (
    echo ERROR: %~1 is not installed or not in PATH.
    echo.
    echo Please install ffmpeg so both ffmpeg and ffprobe are available.
    echo.
    pause
    exit /b 1
)
exit /b 0

:detect_av1_encoder
set "AV1_ENCODER="

ffmpeg -hide_banner -encoders 2>nul | findstr /i /c:"libsvtav1" >nul
if not errorlevel 1 set "AV1_ENCODER=libsvtav1"

if not defined AV1_ENCODER (
    ffmpeg -hide_banner -encoders 2>nul | findstr /i /c:"libaom-av1" >nul
    if not errorlevel 1 set "AV1_ENCODER=libaom-av1"
)

if not defined AV1_ENCODER (
    echo ERROR: No AV1 encoder available in this ffmpeg build.
    echo Required: libsvtav1 or libaom-av1
    echo.
    pause
    exit /b 1
)

echo AV1 encoder: %AV1_ENCODER%
echo.
exit /b 0

:process_video
setlocal EnableExtensions EnableDelayedExpansion

set "INPUT=%~1"
set "BASENAME=%~n1"
set "EXTENSION=%~x1"
set "RESOLUTION="
set "ASSET_TYPE="
set "ORIENTATION="

echo Processing: !BASENAME!!EXTENSION!
echo.

for /f "usebackq tokens=*" %%A in (`ffprobe -v error -select_streams v:0 -show_entries stream^=width^,height -of csv^=s^=x:p^=0 "!INPUT!"`) do set "RESOLUTION=%%A"

if not defined RESOLUTION (
    echo   ERROR: Could not read video resolution.
    endlocal & exit /b 1
)

for /f "tokens=1,2 delims=x" %%A in ("!RESOLUTION!") do (
    set /a WIDTH=%%A
    set /a HEIGHT=%%B
)

if "!WIDTH!"=="" (
    echo   ERROR: Could not parse video width.
    endlocal & exit /b 1
)

if "!HEIGHT!"=="" (
    echo   ERROR: Could not parse video height.
    endlocal & exit /b 1
)

set /a ASPECT_RATIO=!WIDTH! * 100 / !HEIGHT!

if !ASPECT_RATIO! GTR 100 (
    set "ORIENTATION=desktop"
) else (
    set "ORIENTATION=mobile"
)

call :detect_asset_type "!BASENAME!" ASSET_TYPE

echo Detected source: !WIDTH!x!HEIGHT!
echo Orientation: !ORIENTATION!
echo Asset type: !ASSET_TYPE!
echo.

if /i "!ORIENTATION!"=="desktop" (
    if /i "!ASSET_TYPE!"=="landing" (
        set "MAX_WIDTH=1920"
        set "MAX_HEIGHT=1080"
        set "MIN_WIDTH=1280"
        set "MIN_HEIGHT=720"
    ) else (
        set "MAX_WIDTH=1440"
        set "MAX_HEIGHT=810"
        set "MIN_WIDTH=960"
        set "MIN_HEIGHT=540"
    )
) else (
    if /i "!ASSET_TYPE!"=="landing" (
        set "MAX_WIDTH=1080"
        set "MAX_HEIGHT=1920"
        set "MIN_WIDTH=720"
        set "MIN_HEIGHT=1280"
    ) else (
        set "MAX_WIDTH=900"
        set "MAX_HEIGHT=1600"
        set "MIN_WIDTH=540"
        set "MIN_HEIGHT=960"
    )
)

set "OUTPUT_AV1=%ASSETS_DIR%\!BASENAME!-!ORIENTATION!-!MAX_WIDTH!x!MAX_HEIGHT!.mp4"
set "OUTPUT_VP9=%ASSETS_DIR%\!BASENAME!-!ORIENTATION!-!MIN_WIDTH!x!MIN_HEIGHT!.webm"
set "POSTER=%ASSETS_DIR%\!BASENAME!-!ORIENTATION!-poster.jpg"

set "FILTER_MAX=scale=w=!MAX_WIDTH!:h=!MAX_HEIGHT!:force_original_aspect_ratio=decrease:flags=lanczos,pad=!MAX_WIDTH!:!MAX_HEIGHT!:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,format=yuv420p"
set "FILTER_MIN=scale=w=!MIN_WIDTH!:h=!MIN_HEIGHT!:force_original_aspect_ratio=decrease:flags=lanczos,pad=!MIN_WIDTH!:!MIN_HEIGHT!:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,format=yuv420p"
set "FILTER_POSTER=scale=w=!MAX_WIDTH!:h=!MAX_HEIGHT!:force_original_aspect_ratio=decrease:flags=lanczos,pad=!MAX_WIDTH!:!MAX_HEIGHT!:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

echo Step 1/4: Creating poster ^(!MAX_WIDTH!x!MAX_HEIGHT! JPG^)...
ffmpeg -y -ss 00:00:00.250 -i "!INPUT!" -frames:v 1 -vf "!FILTER_POSTER!" -q:v 2 "!POSTER!" -loglevel error
if errorlevel 1 (
    echo   ERROR: Failed to create poster.
    echo.
    set "POSTER_OK=0"
) else (
    echo   SUCCESS: Created !POSTER!
    set "POSTER_OK=1"
    echo   Optimizing poster with TinyPNG...
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0optimize-images.ps1" -NoPause "!POSTER!" 2>nul
    if errorlevel 1 (
        echo   WARNING: Poster optimization failed, using original poster.
    ) else (
        echo   SUCCESS: Poster optimized.
    )
)
echo.

echo Step 2/4: Creating AV1 MP4 ^(!MAX_WIDTH!x!MAX_HEIGHT!, 24fps^)...
if /i "%AV1_ENCODER%"=="libsvtav1" (
    ffmpeg -y -i "!INPUT!" -r 24 -vf "!FILTER_MAX!" -c:v libsvtav1 -crf 34 -preset 7 -pix_fmt yuv420p -movflags +faststart -an "!OUTPUT_AV1!" -loglevel error -stats
) else (
    ffmpeg -y -i "!INPUT!" -r 24 -vf "!FILTER_MAX!" -c:v libaom-av1 -crf 34 -b:v 0 -cpu-used 6 -row-mt 1 -pix_fmt yuv420p -movflags +faststart -an "!OUTPUT_AV1!" -loglevel error -stats
)

if errorlevel 1 (
    echo   ERROR: Failed to create AV1 MP4.
    set "AV1_OK=0"
) else (
    echo   SUCCESS: Created !OUTPUT_AV1!
    set "AV1_OK=1"
)
echo.

echo Step 3/4: Creating VP9 WebM ^(!MIN_WIDTH!x!MIN_HEIGHT!, 24fps^)...
ffmpeg -y -i "!INPUT!" -r 24 -vf "!FILTER_MIN!" -c:v libvpx-vp9 -crf 33 -b:v 0 -deadline good -cpu-used 2 -row-mt 1 -pix_fmt yuv420p -an "!OUTPUT_VP9!" -loglevel error -stats
if errorlevel 1 (
    echo   ERROR: Failed to create VP9 WebM.
    set "VP9_OK=0"
) else (
    echo   SUCCESS: Created !OUTPUT_VP9!
    set "VP9_OK=1"
)
echo.

echo Step 4/4: Output summary
if "!POSTER_OK!"=="1" call :report_file "!POSTER!"
if "!AV1_OK!"=="1" call :report_file "!OUTPUT_AV1!"
if "!VP9_OK!"=="1" call :report_file "!OUTPUT_VP9!"

endlocal & exit /b 0

:detect_asset_type
setlocal EnableDelayedExpansion
set "NAME=%~1"
set "DETECTED="

echo(!NAME!| findstr /i /c:"landing" >nul
if not errorlevel 1 set "DETECTED=landing"

if not defined DETECTED (
    echo(!NAME!| findstr /i /c:"thumb" /c:"thumbnail" /c:"preview" >nul
    if not errorlevel 1 set "DETECTED=thumbnail"
)

if not defined DETECTED (
    echo Could not infer asset type from "!NAME!".
    choice /c LT /n /m "Press L for landing or T for thumbnail: "
    if errorlevel 2 (
        set "DETECTED=thumbnail"
    ) else (
        set "DETECTED=landing"
    )
    echo.
)

endlocal & set "%~2=%DETECTED%"
exit /b 0

:report_file
setlocal
set "FILE=%~1"
if not exist "%FILE%" (
    endlocal & exit /b 0
)

set /a SIZE_BYTES=%~z1
set /a SIZE_KB=(SIZE_BYTES + 1023) / 1024
set /a SIZE_MB=(SIZE_BYTES + 1048575) / 1048576
echo   %~nx1 - %SIZE_KB% KB ^(~%SIZE_MB% MB^)
endlocal & exit /b 0
