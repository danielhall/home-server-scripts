# Backup Strategy (TrueNAS SCALE)

## Goal
Protect important media and configuration data by automatically backing up to the cloud via TrueNAS’s built-in Cloud Sync Tasks.

## What Gets Backed Up
- `/mnt/media/` including:
  - Movies
  - TV Shows
  - Jellyfin configuration and metadata

## How It's Done
Backups are managed using the Cloud Sync feature within the TrueNAS SCALE web UI:

1. Go to **Tasks** > **Cloud Sync Tasks**.
2. Click **Add** to create a new task.
3. Fill in the following:
    - **Direction:** PUSH
    - **Cloud Provider:** Storj (via S3-compatible access)
    - **Credential:** Add or select your Storj credentials (Access Key/Secret and Endpoint)
    - **Remote Path:** e.g. `media-backup/`
    - **Directory/Files:** `/mnt/media`
    - **Schedule:** e.g. Daily at 2AM (adjust as needed)

4. Save the task.

### Notes
- Cloud Sync uses `rclone` under the hood but requires no scripting.
- You can monitor progress via the task logs in the TrueNAS UI.
- Ensure your dataset has regular snapshots if versioning is important.

## Restore Process
To restore from backup:

1. Create a new **Cloud Sync Task** with direction **PULL**.
2. Set the same remote path and credentials.
3. Choose a safe restore location (e.g. `/mnt/restore_test/` initially).

You can then move data back manually.

## Future Improvements
- Enable snapshot-based cloud backups (coming in newer TrueNAS updates)
- Add notification hooks (e.g. Slack or email alerts on success/failure)