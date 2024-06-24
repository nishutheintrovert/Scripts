#!/bin/bash
cd /storage/emulated/0
find . -name '.thumbnails' -exec rm -rf {} +
find . -name 'debug_log' -exec rm -rf {} +
find . -name '.nomedia' -exec rm -rf {} +
find . -name '.tubemate' -exec rm -rf {} +
find . -name '.temp' -exec rm -rf {} +
find . -type f -empty -print -delete
find . -type d -empty -print -delete
cd /storage/D798-66F7/
find . -name '.thumbnails' -exec rm -rf {} +
find . -name 'debug_log' -exec rm -rf {} +
find . -name '.nomedia' -exec rm -rf {} +
find . -name '.tubemate' -exec rm -rf {} +
find . -name '.temp' -exec rm -rf {} +
find . -type f -empty -print -delete
find . -type d -empty -print -delete
cd /storage/emulated/0
