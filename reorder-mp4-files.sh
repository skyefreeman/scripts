#!/bin/bash

cd /Users/skye/Video/the_ultimate_garageband_beginners_guide/

# Loop over all mp4 files
for file in *.mp4; do
    # Extract the number associated with pt
    if [[ $file =~ pt_([0-9]+) ]]; then
        pt_number="${BASH_REMATCH[1]}"
        
        # Remove the existing "pt" from the filename for clarity
        new_filename="${file//___pt_$pt_number/}"          # Remove existing '___pt_x'
        new_filename="${new_filename//pt_$pt_number/}"    # Remove any occurrence of 'pt_x' from the filename
        new_filename="${new_filename//_pt_/}"              # Remove remaining '_pt_' occurrences
        new_filename="${new_filename//_/.}"                 # Replace underscores with dots for readability

        # Prepare the final organized filename
        organized_filename="pt_$pt_number$new_filename.mp4"

        # Rename the file
        mv "$file" "$organized_filename"
    fi
done

echo "Files have been organized and renamed."
