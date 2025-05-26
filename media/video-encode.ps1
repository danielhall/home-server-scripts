# Configuration
$sourceMoviesFolder = "D:\Upload-Automation\Raw\Movies"
$sourceTVFolder = "D:\Upload-Automation\Raw\TV"
$tempFolder = "D:\Upload-Automation\Encoded"
$nasBase = "\\TRUENAS"
$nasMoviesFolder = Join-Path $nasBase "Movies"
$nasTVFolder = Join-Path $nasBase "TV Shows"
$backupFolder = "D:\Upload-Automation\Backup"

# Ensure required folders exist
foreach ($folder in @($tempFolder, $backupFolder)) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Function: Detect resolution using ffprobe
function Get-VideoHeight {
    param ([string]$filePath)
    $ffprobeOutput = & ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$filePath"
    return [int]$ffprobeOutput
}

# Collect all MKV files in Movies and TV folders
$allFiles = @()
$allFiles += Get-ChildItem -Path $sourceMoviesFolder -Filter *.mkv -Recurse
$allFiles += Get-ChildItem -Path $sourceTVFolder -Filter *.mkv -Recurse

foreach ($file in $allFiles) {
    $inputFile = $file.FullName
    $baseName = $file.BaseName
    $encodedFile = Join-Path $tempFolder "$baseName.mkv"

    # Detect compression preset based on resolution
    $height = Get-VideoHeight -filePath $inputFile
    if ($height -ge 2160) {
        $preset = "H.265 MKV 2160p60"
    } elseif ($height -ge 720) {
        $preset = "H.265 MKV 1080p30"
    } else {
        $preset = "H.265 MKV 576p25"
    }
    Write-Output "`nUsing preset: $preset"

    Write-Output "Encoding '$baseName' with HandBrakeCLI..."
    & handbrakecli -i "$inputFile" -o "$encodedFile" --preset "$preset"

    if (Test-Path $encodedFile) {
        Write-Output "Encoding complete. Renaming with FileBot..."

        # Decide NAS subfolder and FileBot format
        if ($inputFile -like "$sourceTVFolder\\*") {
            $filebotDb = "TheTVDB"
            $filebotFormat = "$nasTVFolder/{n}/Season {s}/{n} - S{season}E{episode}"
        } else {
            $filebotDb = "TheMovieDB"
            $filebotFormat = "$nasMoviesFolder/{n} ({y})/{n} ({y})"
        }

        if (!(Test-Path $nasBase)) {
            Write-Warning "NAS path '$nasBase' not accessible. Skipping FileBot rename."
        } else {
            & filebot -rename "$encodedFile" `
                --db $filebotDb `
                --format $filebotFormat `
                --output $nasBase
        }

        # Move original to backup
        $destinationBackup = Join-Path $backupFolder ($file.Name)
        Move-Item -Path $inputFile -Destination $destinationBackup -Force
        Write-Output "Original moved to backup: $destinationBackup"
    } else {
        Write-Warning "Encoding failed for $baseName"
    }
}

# Clean up empty folders
foreach ($folderPath in @($sourceMoviesFolder, $sourceTVFolder)) {
    Get-ChildItem -Path $folderPath -Recurse -Directory |
    Where-Object { @(Get-ChildItem $_.FullName -Force).Count -eq 0 } |
    ForEach-Object {
        Write-Output "Removing empty folder: $($_.FullName)"
        Remove-Item $_.FullName -Force -Recurse
    }
}
