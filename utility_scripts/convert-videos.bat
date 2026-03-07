@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0.."
set "ASSETS_DIR=%ROOT_DIR%\assets"

echo ========================================
echo Video Converter for Portfolio Website
echo ========================================
echo.

REM Check if ffmpeg is available
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: ffmpeg is not installed or not in PATH
    echo.
    echo Please install ffmpeg:
    echo 1. Download from https://ffmpeg.org/download.html
    echo 2. Extract and add to your system PATH
    echo.
    pause
    exit /b 1
)

REM Check if any files were dropped
if "%~1"=="" (
    echo ERROR: No files provided!
    echo.
    echo Usage: Drag and drop video files onto this batch file
    echo.
    pause
    exit /b 1
)

REM Create assets folder if it doesn't exist
if not exist "%ASSETS_DIR%" mkdir "%ASSETS_DIR%"

echo Processing videos...
echo.

REM Process each dropped file
:loop
if "%~1"=="" goto :done

set "input=%~1"
set "filename=%~n1"
set "extension=%~x1"

echo Processing: %filename%%extension%
echo.

REM Determine if this is a desktop (landscape) or mobile (portrait) video
REM We'll check aspect ratio using ffprobe
for /f "tokens=*" %%a in ('ffprobe -v error -select_streams v:0 -show_entries stream^=width^,height -of csv^=s^=x:p^=0 "%input%"') do set "resolution=%%a"

REM Parse width and height
for /f "tokens=1,2 delims=x" %%a in ("%resolution%") do (
    set /a width=%%a
    set /a height=%%b
)

REM Calculate aspect ratio (width * 100 / height to avoid floating point)
set /a aspect_ratio=!width! * 100 / !height!

echo Detected resolution: !width!x!height!
echo Aspect ratio: !aspect_ratio! (100 = 1:1, 177 = 16:9, 56 = 9:16)
echo.

REM Determine orientation based on aspect ratio
if !aspect_ratio! GTR 100 (
    set "orientation=desktop"
    echo Orientation: LANDSCAPE ^(Desktop^)
) else (
    set "orientation=mobile"
    echo Orientation: PORTRAIT ^(Mobile^)
)
echo.

REM Generate output filenames based on orientation, preserving original filename
if "!orientation!"=="desktop" (
    set "output_1080p=%ASSETS_DIR%\%filename%-desktop-1080p.mp4"
    set "output_720p=%ASSETS_DIR%\%filename%-desktop-720p.webm"
    set "poster=%ASSETS_DIR%\%filename%-desktop-poster.jpg"
    set "scale_1080p=1920:1080"
    set "scale_720p=1280:720"
) else (
    set "output_720p_mp4=%ASSETS_DIR%\%filename%-mobile-720p.mp4"
    set "output_480p=%ASSETS_DIR%\%filename%-mobile-480p.webm"
    set "poster=%ASSETS_DIR%\%filename%-mobile-poster.jpg"
    set "scale_720p_mp4=720:1280"
    set "scale_480p=480:854"
)

echo Step 1/4: Extracting thumbnail from first frame...
ffmpeg -y -i "%input%" -vframes 1 -q:v 2 "!poster!" -loglevel error
if %errorlevel% equ 0 (
    echo   SUCCESS: Created !poster!
    echo.
    echo   Optimizing poster with TinyPNG...
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0optimize-images.ps1" "!poster!" 2>nul
    if %errorlevel% equ 0 (
        echo   SUCCESS: Poster optimized
    ) else (
        echo   WARNING: Poster optimization failed, using original
    )
) else (
    echo   ERROR: Failed to create thumbnail
)
echo.

if "!orientation!"=="desktop" (
    echo Step 2/4: Creating desktop 1080p MP4 ^(H.264, 24fps^)...
    ffmpeg -y -i "%input%" -r 24 -vf scale=!scale_1080p!:force_original_aspect_ratio=decrease,pad=!scale_1080p!:^(ow-iw^)/2:^(oh-ih^)/2 -c:v libx264 -crf 23 -preset slow -movflags +faststart -an "!output_1080p!" -loglevel error -stats
    if %errorlevel% equ 0 (
        echo   SUCCESS: Created !output_1080p!
    ) else (
        echo   ERROR: Failed to create 1080p MP4
    )
    echo.

    echo Step 3/4: Creating desktop 720p WebM ^(VP9, 24fps^)...
    ffmpeg -y -i "%input%" -r 24 -vf scale=!scale_720p!:force_original_aspect_ratio=decrease,pad=!scale_720p!:^(ow-iw^)/2:^(oh-ih^)/2 -c:v libvpx-vp9 -b:v 1M -deadline good -an "!output_720p!" -loglevel error -stats
    if %errorlevel% equ 0 (
        echo   SUCCESS: Created !output_720p!
    ) else (
        echo   ERROR: Failed to create 720p WebM
    )
) else (
    echo Step 2/4: Creating mobile 720p MP4 ^(H.264, 24fps^)...
    ffmpeg -y -i "%input%" -r 24 -vf scale=!scale_720p_mp4!:force_original_aspect_ratio=decrease,pad=!scale_720p_mp4!:^(ow-iw^)/2:^(oh-ih^)/2 -c:v libx264 -crf 23 -preset slow -movflags +faststart -an "!output_720p_mp4!" -loglevel error -stats
    if %errorlevel% equ 0 (
        echo   SUCCESS: Created !output_720p_mp4!
    ) else (
        echo   ERROR: Failed to create 720p MP4
    )
    echo.

    echo Step 3/4: Creating mobile 480p WebM ^(VP9, 24fps^)...
    ffmpeg -y -i "%input%" -r 24 -vf scale=!scale_480p!:force_original_aspect_ratio=decrease,pad=!scale_480p!:^(ow-iw^)/2:^(oh-ih^)/2 -c:v libvpx-vp9 -b:v 800K -deadline good -an "!output_480p!" -loglevel error -stats
    if %errorlevel% equ 0 (
        echo   SUCCESS: Created !output_480p!
    ) else (
        echo   ERROR: Failed to create 480p WebM
    )
)

echo.
echo Step 4/4: Calculating file sizes...
echo.
echo ----------------------------------------
echo.

shift
goto :loop

:done
echo ========================================
echo All videos processed!
echo ========================================
echo.
echo Output files are in the 'assets' folder
echo.
pause
