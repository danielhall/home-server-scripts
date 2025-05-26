#!/bin/bash
# clean-temp-folders.sh
# Deletes files older than 7 days in common temp directories

# Make sure you execute `chmod +x clean-temp-folders.sh`

TEMP_DIRS=(
  "/tmp"
  "/var/tmp"
  "/mnt/data/Unsorted_Movies/tmp"
)

for DIR in "${TEMP_DIRS[@]}"; do
  echo "Cleaning $DIR..."
  find "$DIR" -type f -mtime +7 -exec rm -v {} \;
done
