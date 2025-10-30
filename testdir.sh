mkdir repo_small repo_medium repo_large

# small: 100 files
for i in {1..100}; do echo "small $i" >repo_small/file_$i.txt; done
magick -size 2556x1440 xc:cyan repo_small/1_cyan.png

# medium: 1000 files
for i in {1..1000}; do echo "medium $i" >repo_medium/file_$i.sh; done
magick -size 2556x1440 xc:black repo_medium/1_black.png

# large: 5000 files
for i in {1..5000}; do echo "large $i" >repo_large/file_$i.c; done
magick -size 2556x1440 xc:white repo_large/1_white.png
