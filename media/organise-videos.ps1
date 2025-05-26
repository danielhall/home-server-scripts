$sourcePath = "A:\Unsorted_Movies\To Move"
$destinationRoot = "E:\"

# Ensure the source directory exists
if (-Not (Test-Path $sourcePath)) {
    Write-Error "Source directory does not exist: $sourcePath"
    exit
}

# Create destination root if it doesn't exist
if (-Not (Test-Path $destinationRoot)) {
    New-Item -Path $destinationRoot -ItemType Directory | Out-Null
}

Get-ChildItem -Path $sourcePath -File | ForEach-Object {
    $file = $_
    $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $destinationFolder = Join-Path $destinationRoot $fileNameWithoutExt
    $destinationPath = Join-Path $destinationFolder $file.Name

    # Create the destination folder if it doesn't exist
    if (-Not (Test-Path $destinationFolder)) {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
    }

    # Move the file
    Move-Item -Path $file.FullName -Destination $destinationPath
    Write-Output "Moved '$($file.Name)' to '$destinationFolder'"
}
