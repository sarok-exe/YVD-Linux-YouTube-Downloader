Markdown

# YVD - Simple YouTube Video Downloader Script for Linux

## Project Overview

**YVD** (YouTube Video Downloader) is a straightforward Bash script designed for Linux to facilitate downloading YouTube videos using the powerful `yt-dlp` tool. It allows you to download videos in batches by providing a list of URLs in a simple text file, and supports parallel downloads to save time.

This project is free and open-source software, developed by سارﯣۥڪ あ. Feel free to use, modify, and distribute it according to your needs.

## Features

* Download videos from a list of URLs (`videos.txt`).
* Supports parallel downloads to speed up the process.
* Utilizes the highly capable `yt-dlp` backend for reliable downloads.
* Configurable video quality preference.
* Automatic merging of best video/audio streams (requires FFmpeg).
* Basic progress display and logging.
* Clean and simple Bash script for easy understanding and modification.

## Requirements

* A Linux operating system.
* Bash shell.
* The following command-line tools: `yt-dlp`, `xargs`, `grep`, `stdbuf`, `tr`, `sed`, `md5sum`.
* **Optional:** `ffmpeg` is required if you choose a quality format that merges separate video and audio streams (e.g., `bestvideo+bestaudio`). Most high-quality formats on YouTube are provided separately.
* **Optional:** `timeout` is used by the script to prevent hanging when fetching video titles. While the script has a fallback, installing `timeout` is recommended (`sudo apt install coreutils` on Debian/Ubuntu often provides it, or `sudo apt install timeout`).

### Installation of Requirements (for Ubuntu/Debian based systems)

```bash
# Update package list
sudo apt update

# Install python3-pip if not already installed
sudo apt install python3-pip

# Install yt-dlp using pip (recommended for the latest version)
pip install --upgrade yt-dlp

# Or install yt-dlp via apt (might be an older version)
# sudo apt install yt-dlp

# Install ffmpeg (recommended for merging audio and video)
sudo apt install ffmpeg

# Install other basic dependencies (usually pre-installed on most systems, but good to check)
# Installs coreutils (includes timeout), grep, sed, tr
sudo apt install coreutils grep sed findutils
Follow for More : https://t.me/Sarok_exe

Potential Issues and Troubleshooting
Here are some common technical problems you might encounter when using this script, along with explanations and solutions. Always remember to check the $LOG_FILE (default: download.log) for detailed error messages from yt-dlp when a download fails.

1. Missing Dependencies:

Problem: The script fails to start with an error message indicating a command like yt-dlp, ffmpeg, xargs, etc., is not found.
Explanation: The script relies on several external command-line tools. If one of these tools is not installed on your system or cannot be found in your system's command search path (PATH), the script cannot run. The script checks for the main dependencies at the beginning.
Solution: Install the missing dependency using your system's package manager. Refer to the "Installation of Requirements" section above for common commands. Make sure you've installed all listed requirements.
2. yt-dlp is Outdated (Very Common Historical Issue):

Problem: Downloads fail repeatedly for many URLs, even if the URLs are valid and the videos are available when you check them manually. The log file might show errors related to extracting video information, parsing data, or finding formats.
Explanation: Websites like YouTube frequently change their internal structure, video formats, or how they serve content. yt-dlp uses specific "extractors" for each site to understand how to find and download videos. When a website changes, the old extractors in your yt-dlp version might break. This is historically the most frequent reason for yt-dlp failures.
Solution: Update yt-dlp to the latest version. The developers constantly release updates to fix compatibility issues caused by website changes. If you installed via pip (the recommended method), run:
Bash

pip install --upgrade yt-dlp
# You can also often update using yt-dlp's own command:
# yt-dlp -U
If you installed yt-dlp using your system's package manager (like apt), update your system packages (sudo apt update && sudo apt upgrade), but be aware that the version available via package managers might not always be the absolute latest. Using pip usually gets you updates faster.
3. Video Unavailable, Private, or Restricted:

Problem: A specific video download fails with messages in the log like "Private video", "This video is unavailable", "Age restricted", or "Geo-restricted".
Explanation: The video you are trying to download might have been deleted, set to private, is an unlisted video that requires logging in, or is blocked in your geographical region or requires age verification that yt-dlp (and this script) doesn't automatically handle.
Solution: Check the video URL directly in a web browser to confirm its status and any restrictions. If the video is genuinely unavailable or restricted in a way you cannot bypass (like requiring login), you will not be able to download it. Remove the problematic URL from your videos.txt file.
4. ffmpeg Missing or Merging Fails:

Problem: The download process appears to finish quickly but results in a file that is video-only or audio-only, or the script reports a failure specifically during a "Merging" step.
Explanation: If your QUALITY_FORMAT preference specifies downloading video and audio streams separately (e.g., bestvideo+bestaudio which is common for high quality), yt-dlp needs ffmpeg to combine these two streams into a single video file (like MP4 or MKV). If ffmpeg is not installed or not working correctly, this merging step cannot happen. The script includes a warning at the start if ffmpeg isn't found.
Solution: Install ffmpeg on your system. Refer to the "Installation of Requirements" section for installation commands.
5. Downloads are Slow or Failing Frequently (Potential Rate Limits or Network Issues):

Problem: Downloads take an unusually long time, show many "Retrying" messages, or fail intermittently with network-related errors.
Explanation: Your internet connection might be unstable, or you could be hitting rate limits imposed by the video hosting site. Downloading many videos in parallel from the same IP address can sometimes be interpreted as suspicious activity, leading the site to slow down or temporarily block your connection. The script includes --retries and --sleep-interval for yt-dlp to help with this, but it's not a guaranteed fix for aggressive rate limiting.
Solution:
Check the stability and speed of your internet connection.
Reduce the number of parallel downloads by editing the PARALLEL_JOBS variable at the top of the script to a lower number (e.g., 1, 2, or 3). This reduces simultaneous connections and might help avoid rate limits.
6. "File name too long" or Issues with Filename Characters:

Problem: A download fails with an error message indicating the generated filename or path is too long, or contains characters not allowed by your file system.
Explanation: Operating systems and file systems have limits on how long filenames and the full path to a file can be. While the script uses yt-dlp's --restrict-filenames and limits the length of the video title included in the filename (FILENAME_TITLE_LENGTH), a combination of a long output directory path and a long title (even if limited) can sometimes exceed limits.
Solution: The script already attempts to mitigate this. If you still encounter this error, try shortening the FILENAME_TITLE_LENGTH value in the script, or choose a less deeply nested directory for OUTPUT_DIR. The --restrict-filenames option handles most problematic characters automatically.
7. Disk Space Full:

Problem: Downloads fail mid-process with an error message like "No space left on device" or similar.
Explanation: The storage drive where your OUTPUT_DIR is located has run out of free space to save the downloaded video file.
Solution: Free up disk space on the relevant drive by deleting unnecessary files. The script does not check for sufficient disk space before starting downloads.