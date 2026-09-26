#!/bin/bash
# Daily read-stress test for hdd-backup (WD Green), monitoring whether UDMA_CRC_Error_Count
# stays flat after the 2026-09-22 power cable swap (splitter -> dedicated single-lane cable).
# Self-removes from cron after 7 runs. See docs/decisions.md for context.
#
# NOTE: cron runs with a minimal PATH (often just /usr/bin:/bin), which doesn't include
# /usr/sbin where smartctl lives — this silently broke UDMA_CRC logging on the first run
# (2026-09-22, empty before/after values) even though the actual stress test ran fine.
# Explicit PATH below fixes it for good.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -uo pipefail

MOUNT=/mnt/hdd-backup
LOGFILE=/var/log/hdd-backup-daily-test.log
COUNTFILE=/var/lib/hdd-backup-daily-test.count
CRONFILE=/etc/cron.d/hdd-backup-daily-test

DEV=$(findmnt -n -o SOURCE "$MOUNT" | sed -E 's/[0-9]+$//')
if [ -z "$DEV" ]; then
  echo "$(date): ERROR - $MOUNT not mounted, skipping run" >> "$LOGFILE"
  exit 1
fi

RUN=$(( $(cat "$COUNTFILE" 2>/dev/null || echo 0) + 1 ))

{
  echo "===== $(date) - Run $RUN/7 START ====="
  echo "Device: $DEV"
  BEFORE=$(smartctl -A "$DEV" 2>/dev/null | grep -i UDMA_CRC | awk '{print $NF}')
  echo "UDMA_CRC_Error_Count before: $BEFORE"

  # Phase 1: ~12 minutes random scan + concurrent streaming
  END=$(( $(date +%s) + 720 ))
  while [ "$(date +%s)" -lt "$END" ]; do
    find "$MOUNT/music" -iname "*.flac" -size +50M 2>/dev/null | shuf -n 2 | xargs -I{} dd if={} of=/dev/null bs=1M 2>/dev/null
    find "$MOUNT/music" -type f 2>/dev/null | shuf -n 300 | xargs -I{} md5sum {} > /dev/null 2>&1
  done
  echo "Phase 1 (scan+stream) finished: $(date)"

  # Phase 2: ~1 hour realistic music playback simulation — read one file at a time throttled
  # (pv -L) around hi-res FLAC bitrate (~800KB/s), so read duration matches actual song duration
  # rather than a burst-read-then-idle pattern.
  END2=$(( $(date +%s) + 3600 ))
  while [ "$(date +%s)" -lt "$END2" ]; do
    FILE=$(find "$MOUNT/music" -iname "*.flac" 2>/dev/null | shuf -n 1)
    if [ -n "$FILE" ]; then
      echo "  now playing: $FILE"
      pv -q -L 800k "$FILE" > /dev/null 2>/dev/null
    fi
  done
  echo "Phase 2 (throttled playback simulation) finished: $(date)"

  AFTER=$(smartctl -A "$DEV" 2>/dev/null | grep -i UDMA_CRC | awk '{print $NF}')
  echo "UDMA_CRC_Error_Count after: $AFTER"
  if [ "$BEFORE" != "$AFTER" ]; then
    echo "!!! WARNING: UDMA_CRC_Error_Count INCREASED from $BEFORE to $AFTER !!!"
  fi
  echo "===== $(date) - Run $RUN/7 DONE ====="

  # Counter write moved inside the logged block so any failure here is visible in the log
  # instead of silently leaving the count file stale (bit us on the very first run).
  if echo "$RUN" > "$COUNTFILE"; then
    echo "Counter updated: $RUN"
  else
    echo "!!! FAILED writing counter to $COUNTFILE !!!"
  fi

  if [ "$RUN" -ge 7 ]; then
    echo "7 runs complete, self-removing cron job"
    rm -f "$CRONFILE"
  fi
  echo
} >> "$LOGFILE" 2>&1
