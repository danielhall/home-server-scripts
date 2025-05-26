# Media Encoding & Organisation Scripts (PowerShell)

These PowerShell scripts provide a simple pipeline for **video processing and organisation**. They’re designed to help automate:

- Encoding video files using [HandBrakeCLI](https://handbrake.fr/)
- Renaming and moving videos into a structured media directory
- Preparing media for tools like Jellyfin, Plex, or Kodi

## Requirements

- Windows (PowerShell 5+)
- [HandBrakeCLI](https://handbrake.fr/downloads2.php) installed and added to your `PATH`
- Video files in a common format (`.mkv`, `.mp4`, `.avi`, etc.)

## Scripts Overview

### 1. `video-encode.ps1`

Encodes a video file using `HandBrakeCLI` with recommended presets (e.g. H.264, stereo audio).

**Usage:**

```powershell
.\video-encode.ps1 -InputFile "D:\Videos\Unsorted\Example.mkv"
```

**Parameters:**

| Parameter   | Description                           |
|-------------|---------------------------------------|
| `-InputFile` | Path to the video file to encode      |
| `-OutputDir` | (Optional) Output folder for encoding |
| `-Preset`    | (Optional) HandBrake preset (default: `Fast 1080p30`) |

**Example output:**

```
Encoded → D:\Videos\Encoded\Example (2023).mp4
```

### 2. `organise-videos.ps1`

Renames and moves video files into a tidy folder structure:

```
/Media/
  ├── Movies/
  │   └── Title (Year)/Title (Year).mp4
  └── TV_Shows/
      └── Show Name/
          └── Season 01/
              └── S01E01 - Episode Name.mp4
```

**Usage:**

```powershell
.\organise-videos.ps1 -SourceDir "D:\Videos\Encoded" -TargetRoot "E:\Media"
```

**Parameters:**

| Parameter     | Description                                      |
|----------------|--------------------------------------------------|
| `-SourceDir`   | Folder containing newly encoded video files      |
| `-TargetRoot`  | Root folder where media will be sorted into      |
| `-DryRun`      | (Optional) Preview changes without moving files  |

The script attempts to infer titles, years, and episode info based on filename patterns. Manual correction may be needed for ambiguous names.

## Recommended Workflow

1. Drop raw files into a staging folder (e.g. `D:\Videos\Unsorted`)
2. Encode using:

   ```powershell
   .\video-encode.ps1 -InputFile "D:\Videos\Unsorted\Some.Movie.2023.mkv"
   ```

3. Once encoded, sort into the media library:

   ```powershell
   .\organise-videos.ps1 -SourceDir "D:\Videos\Encoded" -TargetRoot "E:\Media"
   ```

4. Refresh your Jellyfin/Plex library

## Notes

- `HandBrakeCLI` must be installed and discoverable in your `PATH`
- Assumes UTF-8 filenames
- Intended for personal media archiving and home server use
- Script behaviour can be modified to support subtitle copying, different presets, etc.

## Future Improvements (Optional)

- Integrate subtitle handling or language tags
- Add TVDB/IMDb scraping for auto-corrected titles
- Handle batch input or watch folders