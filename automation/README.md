# download-worker

A simple, safe, and idempotent shell script to download and virus-scan files from a remote source using `rclone` and `clamscan`. Designed for headless or automated home server environments (e.g. NAS setups).

## What It Does

- Prevents multiple simultaneous runs using a lock file
- Reads a master list of files to download (`all_file_paths.txt`)
- Skips files that have already been processed (`downloaded.log`)
- Downloads the next unprocessed file via `rclone` from a remote (e.g. `hep:`)
- Scans the downloaded file using ClamAV (`clamscan`)
- Deletes infected files immediately
- Logs all activity to a daily log file (e.g. `daily_download_YYYY-MM-DD.log`)

## File Structure

| File                     | Purpose                                               |
|--------------------------|-------------------------------------------------------|
| `all_file_paths.txt`     | Master list of all files to download (one per line)  |
| `downloaded.log`         | Tracks successfully downloaded and scanned files      |
| `file_download.lock`     | Lock file to prevent concurrent executions            |
| `daily_download_*.log`   | Timestamped logs for each run                         |

All of the above are stored in the `/downloads/` directory (changeable by editing the script).

## Requirements

- `rclone` (configured with a remote named `hep`)
- `clamscan` (part of ClamAV antivirus)
- `bash` (POSIX-compatible shell)

## How to Run

```bash
bash download-worker.sh
