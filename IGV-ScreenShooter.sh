#!/bin/bash

# Terminal must have been loaded with the -X option (Ex: ssh -S user@my_name)

####### input position file exemple: ############
#Chr13	13034938
#Chr04	33570628
#Chr04	52202511
#Chr04	29223503
#Chr15	27523610


module load IGV

# Check if required arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <positions> <bam_list.txt> <genome_path> <output_dir>"
    echo "Example: $0 positions.txt bams.txt hg38.fa ./IGVsnapshots"
    exit 1
fi

# Assign input arguments to variables
POSITIONS_FILE=$1
BAM_LIST=$2
GENOME=$3
OUTPUT_DIR=$4

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Create a temporary IGV batch script file
BATCH_SCRIPT="${OUTPUT_DIR}/igv_batch.txt"

# Process each BAM file
while IFS= read -r bam_file; do
    # Extract the base name of the BAM file (without path and extension)
    bam_name=$(basename "$bam_file" .bam)
    
    # Write IGV batch commands for each BAM file
    cat << EOF > "$BATCH_SCRIPT"
new
genome $GENOME
snapshotDirectory $OUTPUT_DIR
load $bam_file
EOF

    # Process each position in the positions file
    while IFS=$'\t' read -r chr pos; do
        # Calculate region (500bp window around position)
        start=$((pos - 150))
        end=$((pos + 150))

        # Add commands for the expanded view snapshot
        cat << EOF >> "$BATCH_SCRIPT"
goto ${chr}:${start}-${end}
sort position
expand
snapshot ${bam_name}_${chr}_${pos}_Expanded.png
EOF

        # Add commands for the squished view snapshot
        cat << EOF >> "$BATCH_SCRIPT"
goto ${chr}:${start}-${end}
sort position
squish
snapshot ${bam_name}_${chr}_${pos}_Squished.png
EOF
    done < "$POSITIONS_FILE"
    
    # Add exit command to batch script
    echo "exit" >> "$BATCH_SCRIPT"

    # Run IGV in batch mode for the current BAM file
    igv.sh -b "$BATCH_SCRIPT"

done < "$BAM_LIST"

echo "IGV snapshots have been generated in $OUTPUT_DIR"

# Step 2: Add vertical lines to each snapshot
python3 << EOF
from PIL import Image, ImageDraw
import os

output_dir = "$OUTPUT_DIR"

# Loop over all images in the output directory
for image_file in os.listdir(output_dir):
    if image_file.endswith(".png"):
        image_path = os.path.join(output_dir, image_file)
        
        # Open the image
        img = Image.open(image_path)
        draw = ImageDraw.Draw(img)
        
        # Get image dimensions
        width, height = img.size
        # Position the line slightly left of center (e.g., 25 pixels to the left of center)
        line_x = width // 2 + 74
        line_color = (255, 0, 0)  # Red line for visibility
        
        # Draw the vertical line
        draw.line((line_x, 0, line_x, height), fill=line_color, width=1)
        
        # Save the modified image with a suffix
        #output_path = os.path.join(output_dir, f"with_line_{image_file}")
        #img.save(output_path)
        img.save(image_path)

EOF

echo "Vertical lines have been added to all snapshots in $OUTPUT_DIR"