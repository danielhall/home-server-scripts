# Media Server Setup

## Overview
This directory manages encoding, sorting, and serving personal media via Jellyfin.

## Folders
- `/mnt/media/Unsorted/` — where rips or downloads go initially
- `/mnt/media/Converted/` — encoded MP4s ready to organise
- `/mnt/media/Movies/` — final destination in proper folder format

## Workflow
1. Drop `.mkv` or `.mp4` files into `Unsorted`
2. Run `video-encode.ps1 -Mode handbrake` or `-Mode ffmpeg`
3. Run `organise-videos.ps1` to structure by `Title (Year)`

## Notes
- Jellyfin runs via Docker Compose with host networking
- Hardware acceleration enabled for `/dev/dri`