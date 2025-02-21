#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Set default values if environment variables are not provided
: "${WORKDIR:=/app/downloads}"  # Define the working directory
: "${SLEEPTIME:=600}"  # Define the SLEEPTIME in seconds

convert_in_to_mp4() {
    echo "Starting conversion of .mp4 files to .mp4 in ${WORKDIR}..."

    ls -l ${WORKDIR}

    # Find all .mp4 files in the WORKDIR
    find "${WORKDIR}" -type f -name "*.mp4" | while read -r in_file; do
        # Define the output .mp4 file path
        mp4_file="output/${in_file%.mp4}.mp4"

        echo "Converting '${in_file}' to '${mp4_file}'..."

	mkdir "${WORKDIR}/output"

        # Perform the conversion using ffmpeg
        ffmpeg -i "${in_file}" -vcodec libx264 -acodec aac  "${mp4_file}" -y

        if [ $? -eq 0 ]; then
            echo "Successfully converted '${in_file}' to '${mp4_file}'."
            rm "${in_file}"
        else
            echo "Failed to convert '${in_file}'."
        fi
    done

    echo "Conversion process completed."
}

# Convert .ts files to .mp4 after downloading
convert_in_to_mp4

echo "All tasks completed successfully. Sleeping for $SLEEPTIME seconds..."
sleep $SLEEPTIME