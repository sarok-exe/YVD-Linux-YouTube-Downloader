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
* The following command-line tools: `yt-dlp`, `xargs`, `grep`, `stdbuf`, `tr`, `sed`.
* **Optional:** `ffmpeg` is required if you choose a quality format that merges separate video and audio streams (e.g., `bestvideo+bestaudio`). Most high-quality formats on YouTube are provided separately.

### Installation of Requirements (for Ubuntu/Debian based systems)

```bash
# Install yt-dlp (recommended method using pip)
sudo apt update
sudo apt install python3-pip
pip install yt-dlp

# Or install yt-dlp via apt (might be older version)
# sudo apt update
# sudo apt install yt-dlp

# Install ffmpeg (recommended for merging)
sudo apt update
sudo apt install ffmpeg

# Install other basic dependencies (usually pre-installed on most systems)
sudo apt update
sudo apt install coreutils grep sed findutils
# Follow for More : https://t.me/Sarok_exe
