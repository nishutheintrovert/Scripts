#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 19/05/2026
#    Purpose    : Extract wallpaper packs id's from config.json folder array

echo "Processing config.json..."
echo ""

jq -r '
  def traverse(path):

    # Build the directory path
    (if path == "" then .title else (path + "/" + .title) end) as $curr_path |

    # Print the directory header
    "Directory: \($curr_path)",

    # Extract items, filtering exclusively for numerical Workshop IDs (ignores local paths)
    (.items | keys[]? | select(test("^[0-9]+$"))),

    # Print the total count
    "Total entries: \(.items | length)",
    "",

    # Recursively process any subfolders
    (.subfolders[]? | traverse($curr_path));

  # Start the traversal
  .nishi.general.browser.folders[]? | traverse("")
' "C:\Program Files (x86)\Steam\steamapps\common\wallpaper_engine\config.json" | awk '
  {
    # Print every line to the terminal so you can see the directory tree
    print $0

    # If the line is NOT a header, NOT a total count, and NOT empty (NF > 0),
    # it is an ID. Write it directly to extract-ids-from-config.folders-array.txt.
    if ($0 !~ /^Directory:/ && $0 !~ /^Total entries:/ && NF > 0) {
      print $0 > "extract-ids-from-config-folders-array.txt"
    }
  }
'

echo "Done! saved to extract-ids-from-config-folders-array.txt"
