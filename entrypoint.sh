#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Set default values if environment variables are not provided
: "${WORKDIR:=/app/downloads}"  # Define the working directory
: "${SLEEPTIME:=600}"  # Define the SLEEPTIME in seconds
: "${THREADS:=6}"  # Define the number of THREADS


convert_in_to_mp4() {
    echo "Starting conversion of .mp4 files to .mp4 in ${WORKDIR}..."

    ls -l ${WORKDIR}

    # Find all *.ts .mp4 *.mov *.mpeg files in the WORKDIR
    find "${WORKDIR}" -maxdepth 1 -type f -name "*.mp4" -o -name "*.ts" -o -name "*.mov" -o -name "*.mpeg" | while read -r in_file; do
        # Define the output .mp4 file path
        filename=`basename "$in_file"`
	outdir="$WORKDIR/output"
	mp4_file="$outdir/${filename%.*}.mp4"

        echo "Converting '$in_file' to '$mp4_file'..."

	
	if [ ! -e $outdir ]; then
	    mkdir $outdir
	elif [ ! -d $outdir ]; then
	    echo "$outdir already exists but is not a directory" 1>&2
	fi

        # Perform the conversion using ffmpeg
        ffmpeg -i "$in_file" -vcodec libx264 -acodec aac -preset fast -crf 32 "$mp4_file" -y -threads ${THREADS} < /dev/null

        if [ $? -eq 0 ]; then
            echo "Successfully converted '$in_file' to '$mp4_file'."
            detox -s iso8859_1 "$mp4_file"
	    rm "${in_file}"
        else
            echo "Failed to convert '$in_file'."
        fi
    done


    echo "Conversion process completed."
}

# Convert .ts files to .mp4 after downloading
convert_in_to_mp4

echo "All tasks completed successfully. Sleeping for $SLEEPTIME seconds..."
sleep $SLEEPTIME