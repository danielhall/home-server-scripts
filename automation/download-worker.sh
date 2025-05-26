#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LOCKFILE="/downloads/file_download.lock"
ALL_LIST="/downloads/all_file_paths.txt"
DONE_LIST="/downloads/downloaded.log"
LOGFILE="/downloads/daily_download_$(date +%Y-%m-%d).log"

# Prevent concurrent runs
if [ -e "$LOCKFILE" ]; then
  echo "Another download is already in progress. Exiting." | tee -a "$LOGFILE"
  exit 1
fi
touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

cd /downloads || exit 1

echo "=== Starting single file download at $(date) ===" | tee -a "$LOGFILE"

# Ensure tracking files exist
touch "$ALL_LIST" "$DONE_LIST"

# Find the next unprocessed file
NEXT=$(grep -Fxv -f "$DONE_LIST" "$ALL_LIST" | head -n 1)

if [ -z "$NEXT" ]; then
  echo "✅ All files have been downloaded." | tee -a "$LOGFILE"
  exit 0
fi

# Download the file using rclone
FILENAME=$(basename "$NEXT")
echo "🎬 Downloading: $FILENAME" | tee -a "$LOGFILE"

rclone copyto "hep:$NEXT" "$FILENAME"

# Scan it
echo "🔍 Scanning: $FILENAME" | tee -a "$LOGFILE"
SCAN_RESULT=$(clamscan "$FILENAME")
echo "$SCAN_RESULT" >> "$LOGFILE"

if echo "$SCAN_RESULT" | grep -q "Infected files: 1"; then
  echo "⚠️ Virus detected in $FILENAME – deleting!" | tee -a "$LOGFILE"
  rm -f "$FILENAME"
else
  echo "✅ $FILENAME is clean." | tee -a "$LOGFILE"
fi

# Mark as done
echo "$NEXT" >> "$DONE_LIST"

echo "=== Finished at $(date) ===" | tee -a "$LOGFILE"
