# Master Zero-Defect Music Audit & Library Health

> **Source of Truth** untuk status integritas, kebersihan, dan standar format perpustakaan musik (`Lossless/`, `Lossy/`, `catalog.sqlite`).
> Dokumen ini diperbarui secara otomatis secara berkala (*real-time update*) via server cron/systemd dan setiap kali katalog di-refresh.

---

### 🏆 Live Master Audit Scorecard

```
======================================================================
MASTER ZERO-DEFECT AUDIT (LIVE SYSTEM SCORECARD)
Target Host : docker-host (192.168.18.225)
Storage Root: /mnt/hdd-backup/music/
Timestamp   : 2026-09-26 18:32:40
======================================================================
Disk Usage  : 139G free (93% used)

--- 1. LOSSLESS LIBRARY AUDIT (/mnt/hdd-backup/music/Lossless) ---
Total Directories         : 6,837
Total Files               : 29,784
Bit-Perfect FLAC Tracks   : 23,166  (100% FLAC)
Non-FLAC Audio Files      : 0       (0 WAV, 0 AIFF, 0 WV, 0 MP3, 0 M4A, 0 AAC)
CUE Sheets (.cue)         : 0       (100% Standalone split tracks)
Clutter Files (.log/.url) : 0       (100% Bersih dari log/iklan)
In-album M3U Playlists    : 0       (100% Master Lossless.m3u8 terpusat)
Duplicate Cover Art       : 0       (100% Single official Cover.jpg per album)
Case Collisions (SMB/NTFS): 0       (100% Aman untuk Windows client)
Artists Missing Tilde (~) : 0       (100% dari 1,208 artis berakhiran ~)
Loose Audio in Roots      : 0       (100% Berada di dalam folder album resmi)
Empty Directories         : 0       (100% Bersih dari folder hantu)
Album Format Noise Tags   : 0       (0 [FLAC], 0 [WEB-FLAC], 0 [Hi-Res])
Album Raw Date Prefixes   : 0       (0 YYYY.MM.DD date prefixes)

--- 2. LOSSY COMPANION LIBRARY AUDIT (/mnt/hdd-backup/music/Lossy) ---
Lossy Audio Tracks        : 2,357   (MP3, M4A, AAC)
FLAC Files in Lossy       : 0       (100% Bersih, seluruh FLAC telah di-rescue ke Lossless)
Clutter Files in Lossy    : 0       (0 .cue, 0 .log, 0 .htm)
Empty Dirs in Lossy       : 0       (0 Folder kosong)
Case Collisions in Lossy  : 0       (100% Aman Windows)

--- 3. MASTER CATALOG & PLAYLISTS ---
catalog.sqlite Tracks     : 25,530  (Lossless: 23,166 | Lossy: 2,364)
Lossless.m3u8 Tracks      : 23,166  (100% FLAC Bit-Perfect)
Lossy.m3u8 Tracks         : 2,364
Samba Daemon Status       : Active & Serving LAN
Permissions Standard      : 775 (Directories) / 664 (Files) root:root
Total Defects Detected    : 0 (ZERO-DEFECT STATUS: VERIFIED PASS)
======================================================================
```

---

## 1. Definisi & Batasan 15 Parameter Zero-Defect

Semua parameter di bawah ini memiliki nilai toleransi cacat **wajib 0 (Zero Tolerance)**:

| No | Parameter Audit | Target | Deskripsi & Validasi |
| :---: | :--- | :---: | :--- |
| **1** | **Bit-Perfect FLAC** | 100% | Seluruh audio di `Lossless/` wajib berekstensi `.flac` murni bit-perfect. |
| **2** | **Non-FLAC Audio in Lossless** | **0** | Tidak boleh ada file WAV, AIFF, WV, MP3, M4A, AAC, APE, atau Tak di `Lossless/`. Format mentah/lossy wajib dikonversi atau dipindahkan ke `Lossy/`. |
| **3** | **CUE Sheets** | **0** | Seluruh file `.cue` wajib di-split menjadi trek standalone dan file CUE dihapus agar tidak duplikat di pemutar musik. |
| **4** | **Clutter Files** | **0** | Dilarang ada file sampah (.log, .accurip, .html, .url, .ini, Read.txt iklan piracy, dsb.). |
| **5** | **In-album M3U Playlists** | **0** | Tidak boleh ada file playlist `.m3u`/`.m3u8` lokal ripper di dalam album (hanya master playlist `Lossless.m3u8` di root yang diizinkan). |
| **6** | **Duplicate Cover Art** | **0** | Setiap album hanya boleh memiliki 1 file artwork resmi kanonikal: `Cover.jpg`. Dilarang ada `cover.png` berukuran besar atau variasi nama lain. |
| **7** | **Case Collisions (SMB/NTFS)** | **0** | Dilarang ada dua file atau folder yang namanya hanya berbeda huruf besar/kecil (misal `Cover.jpg` vs `cover.jpg`) untuk mencegah error Samba Windows. |
| **8** | **Artists Missing Tilde (~)** | **0** | Setiap folder artis/franchise di root kategori wajib berakhiran spasi tilde (` ~`), misal: `BanG Dream! (バンドリ！) ~`. |
| **9** | **Loose Audio in Roots** | **0** | Tidak boleh ada file audio tergeletak di kategori root atau franchise root tanpa masuk ke folder album resmi. |
| **10** | **Empty Directories** | **0** | Bersih total dari folder kosong ("folder hantu"). |
| **11** | **Album Format Noise Tags** | **0** | Nama folder album harus murni judul album; dilarang mencantumkan format `[FLAC]`, `[WEB-FLAC]`, `(Hi-Res)`, `24bit/96kHz`, dll. |
| **12** | **Album Raw Date Prefixes** | **0** | Nama folder album tidak boleh menggunakan prefix tanggal mentah `YYYY.MM.DD` di depannya. |
| **13** | **FLAC in Lossy** | **0** | Tidak boleh ada file FLAC tersesat di direktori `Lossy/`. Seluruh FLAC wajib di-rescue ke `Lossless/`. |
| **14** | **Lossy Clutter Files** | **0** | Direktori `Lossy/` harus bersih dari sampah (.cue, .log, .htm, file duplicate). |
| **15** | **Samba & Permissions** | 775/664 | Seluruh direktori bertipe 775, file bertipe 664, ownership `root:root` (Samba mapping ke user SMB). |

---

## 2. Mekanisme Real-Time Update

1. **Trigger Otomatis Setiap Ingest / Update Katalog**:
   - Skrip `/mnt/hdd-backup/music/scripts/update_catalog.py` secara otomatis memanggil generator ini setiap kali katalog SQLite di-refresh.
2. **Systemd Automation (Periodic Background Check)**:
   - Dijalankan via `homelab-music-audit.timer` setiap 6 jam pada host `docker-host`.
   - File status Markdown di storage `/mnt/hdd-backup/music/AUDIT_SCORECARD.md` dapat diakses langsung secara real-time via:
     - **Windows SMB**: `\\docker-host\hdd-backup\music\AUDIT_SCORECARD.md`
     - **FileBrowser Web UI**: `http://192.168.18.225:8085` (di bawah folder `HDD-Backup/music/AUDIT_SCORECARD.md`).
3. **Manual Trigger**:
   ```bash
   python3 /mnt/hdd-backup/music/scripts/generate_music_scorecard.py --all
   ```

*Last Updated: 2026-09-26 18:32:40*
