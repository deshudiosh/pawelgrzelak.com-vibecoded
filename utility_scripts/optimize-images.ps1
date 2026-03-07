# Image Optimization Script using TinyPNG API
# Drag and drop images onto this script to optimize them

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Image Optimizer for Portfolio Website" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# TinyPNG API Key
$apiKey = "KM08d19zsGznnFJ319dSrxtD8X8hzKmT"

# Check if files were provided
if ($Files.Count -eq 0) {
    Write-Host "ERROR: No files provided!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage: Drag and drop image files (PNG/JPG) onto optimize-images.bat" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Function to compress image using TinyPNG API directly
function Compress-Image {
    param(
        [string]$InputPath,
        [string]$ApiKey
    )
    
    $fileBytes = [System.IO.File]::ReadAllBytes($InputPath)
    
    # Create basic auth header
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("api:$ApiKey"))
    
    try {
        # Upload to TinyPNG API
        $uploadHeaders = @{
            "Authorization" = "Basic $base64Auth"
        }
        
        $uploadResponse = Invoke-WebRequest -Uri "https://api.tinify.com/shrink" `
            -Method Post `
            -Headers $uploadHeaders `
            -Body $fileBytes `
            -ContentType "image/png" `
            -UseBasicParsing
        
        # Parse JSON response
        $responseData = $uploadResponse.Content | ConvertFrom-Json
        
        # Download optimized image from the URL provided
        $downloadUrl = $responseData.output.url
        $optimizedResponse = Invoke-WebRequest -Uri $downloadUrl -Method Get -UseBasicParsing
        
        return $optimizedResponse.Content
    }
    catch {
        $errorMessage = $_.Exception.Message
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            $errorMessage = "$errorMessage - $errorBody"
        }
        throw "API Error: $errorMessage"
    }
}

# Process each file
$totalOriginalSize = 0
$totalOptimizedSize = 0
$processedCount = 0

foreach ($file in $Files) {
    if (-not (Test-Path $file)) {
        Write-Host "WARNING: File not found: $file" -ForegroundColor Yellow
        continue
    }

    $fileInfo = Get-Item $file
    $fileName = $fileInfo.Name
    $extension = $fileInfo.Extension.ToLower()

    # Check if file is an image
    if ($extension -ne ".png" -and $extension -ne ".jpg" -and $extension -ne ".jpeg") {
        Write-Host "SKIPPED: $fileName (not a PNG/JPG file)" -ForegroundColor Yellow
        continue
    }

    Write-Host "Optimizing: $fileName" -ForegroundColor Cyan
    
    $originalSize = $fileInfo.Length
    $originalSizeKB = [math]::Round($originalSize / 1KB, 2)

    try {
        # Compress the image
        $optimizedBytes = Compress-Image -InputPath $file -ApiKey $apiKey
        
        # Create temporary file
        $tempFile = "$file.tmp"
        [System.IO.File]::WriteAllBytes($tempFile, $optimizedBytes)
        
        $optimizedSize = (Get-Item $tempFile).Length
        $optimizedSizeKB = [math]::Round($optimizedSize / 1KB, 2)
        $savedBytes = $originalSize - $optimizedSize
        $savedPercent = [math]::Round(($savedBytes / $originalSize) * 100, 1)
        
        # Replace original with optimized
        Move-Item -Path $tempFile -Destination $file -Force
        
        Write-Host "  $originalSizeKB KB -> $optimizedSizeKB KB" -ForegroundColor White
        Write-Host "  Reduced by $savedPercent% (saved $([math]::Round($savedBytes / 1KB, 2)) KB)" -ForegroundColor Green
        
        $totalOriginalSize += $originalSize
        $totalOptimizedSize += $optimizedSize
        $processedCount++
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        # Clean up temp file if it exists
        if (Test-Path "$file.tmp") {
            Remove-Item "$file.tmp" -Force
        }
    }
    
    Write-Host ""
}

# Summary
if ($processedCount -gt 0) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Files optimized: $processedCount" -ForegroundColor White
    Write-Host "Total before: $([math]::Round($totalOriginalSize / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "Total after: $([math]::Round($totalOptimizedSize / 1KB, 2)) KB" -ForegroundColor Green
    
    $totalSaved = $totalOriginalSize - $totalOptimizedSize
    $totalSavedPercent = [math]::Round(($totalSaved / $totalOriginalSize) * 100, 1)
    Write-Host "Total saved: $totalSavedPercent% ($([math]::Round($totalSaved / 1KB, 2)) KB)" -ForegroundColor Green
}
else {
    Write-Host "No images were processed." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
