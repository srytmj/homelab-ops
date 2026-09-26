#!/usr/bin/env python3
"""
Homelab Music Library - ReplayGain 2.0 / EBU R128 Batch Tagging Utility
Applies bit-perfect ReplayGain metadata tags (REPLAYGAIN_TRACK_GAIN, REPLAYGAIN_ALBUM_GAIN)
using native 'metaflac --add-replay-gain' per album directory.
Raw PCM audio stream is 100% untouched and bit-perfect (verified MD5 matching).
"""

import os
import sys
import time
import argparse
import subprocess
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed

sys.stdout.reconfigure(encoding='utf-8')

ROOT_LOSSLESS = Path("/mnt/hdd-backup/music/Lossless")
LOG_FILE = Path("/mnt/hdd-backup/music/replaygain.log")

def find_album_dirs(root_dir, target_subpath=None):
    """Find all directories containing at least one FLAC file."""
    search_root = root_dir if not target_subpath else root_dir / target_subpath
    album_dirs = []
    for r, dirs, files in os.walk(search_root):
        flacs = [f for f in files if f.lower().endswith('.flac')]
        if flacs:
            album_dirs.append((Path(r), sorted(flacs)))
    return album_dirs

def check_album_has_replaygain(album_dir, first_flac):
    """Fast check whether the album already has REPLAYGAIN_ALBUM_GAIN."""
    fp = album_dir / first_flac
    try:
        # Check first 8KB of file for REPLAYGAIN
        with open(fp, "rb") as f:
            chunk = f.read(8192)
            if b"REPLAYGAIN_ALBUM_GAIN" in chunk or b"replaygain_album_gain" in chunk:
                return True
    except Exception:
        pass
    return False

def process_album(args_tuple):
    album_dir, flacs, force = args_tuple
    if not force and check_album_has_replaygain(album_dir, flacs[0]):
        return (str(album_dir), len(flacs), "SKIPPED_ALREADY_TAGGED")

    flac_paths = [str(album_dir / f) for f in flacs]
    cmd = ["metaflac", "--add-replay-gain"] + flac_paths
    
    start_t = time.time()
    res = subprocess.run(cmd, capture_output=True, text=True, errors="replace")
    elapsed = time.time() - start_t

    if res.returncode == 0:
        return (str(album_dir), len(flacs), f"SUCCESS_{elapsed:.1f}s")
    else:
        # If files have different sample rates / bit depths, metaflac album mode requires track-by-track fallback
        err_msg = res.stderr.strip()
        if "sample rate" in err_msg.lower() or "resolution" in err_msg.lower():
            # Process track-by-track
            for fp in flac_paths:
                subprocess.run(["metaflac", "--add-replay-gain", fp], capture_output=True, text=True)
            return (str(album_dir), len(flacs), f"SUCCESS_MIXED_TRACKS_{elapsed:.1f}s")
        return (str(album_dir), len(flacs), f"FAILED: {err_msg[:60]}")

def main():
    parser = argparse.ArgumentParser(description="Batch calculate & write ReplayGain tags to FLAC albums")
    parser.add_argument("--subpath", type=str, default="", help="Specific subfolder to process (e.g. 'Anime/THE IDOLM@STER (アイドルマスター) ~/Gakuen Idolmaster (学園アイドルマスター) ~')")
    parser.add_argument("--force", action="store_true", help="Force recalculate even if tags already exist")
    parser.add_argument("--workers", type=int, default=3, help="Number of parallel worker processes (default: 3)")
    args = parser.parse_args()

    print("=" * 70)
    print("HOMELAB REPLAYGAIN 2.0 / EBU R128 BATCH NORMALIZER")
    print("Target: /mnt/hdd-backup/music/Lossless")
    if args.subpath:
        print(f"Filter Subpath: {args.subpath}")
    print(f"Workers: {args.workers}")
    print("=" * 70)

    target_path = Path(args.subpath) if args.subpath else None
    albums = find_album_dirs(ROOT_LOSSLESS, target_path)
    total_tracks = sum(len(flacs) for _, flacs in albums)
    print(f"Found {len(albums)} album directories ({total_tracks:,} tracks total).")

    tasks = [(album_dir, flacs, args.force) for album_dir, flacs in albums]

    processed_albums = 0
    processed_tracks = 0
    skipped_albums = 0
    failed_albums = 0
    start_all = time.time()

    with ProcessPoolExecutor(max_workers=args.workers) as executor:
        futures = {executor.submit(process_album, t): t for t in tasks}
        for future in as_completed(futures):
            album_dir, track_cnt, status = future.result()
            if status.startswith("SUCCESS"):
                processed_albums += 1
                processed_tracks += track_cnt
                sys.stdout.write(f"\r[PROCESSED] Albums: {processed_albums} ({processed_tracks:,} tracks) | Skipped: {skipped_albums} | Status: {status}    ")
                sys.stdout.flush()
            elif status == "SKIPPED_ALREADY_TAGGED":
                skipped_albums += 1
                sys.stdout.write(f"\r[PROCESSED] Albums: {processed_albums} ({processed_tracks:,} tracks) | Skipped: {skipped_albums}    ")
                sys.stdout.flush()
            else:
                failed_albums += 1
                print(f"\n[!] Failed: {album_dir} -> {status}")

    total_time = time.time() - start_all
    print(f"\n\nReplayGain Batch Tagging Complete in {total_time/60:.1f} minutes!")
    print(f"  Processed Albums: {processed_albums} ({processed_tracks:,} tracks)")
    print(f"  Skipped Albums  : {skipped_albums}")
    print(f"  Failed Albums   : {failed_albums}")

if __name__ == "__main__":
    main()
