#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Set default values if environment variables are not provided
: "${WORKDIR:=/app/downloads}"  # Define the working directory
: "${SLEEPTIME:=600}"  # Define the SLEEPTIME in seconds
: "${THREADS:=6}"  # Define the number of THREADS
: "${CRF:=23}"             # Video quality (0-51, lower = better, 23 = default)
: "${PRESET:=slower}"      # Encoding preset (ultrafast, fast, medium, slow, slower, veryslow)
: "${RESOLUTION:=}"        # Target resolution, e.g. 1920x1080 or 1280x720 (empty = keep original)
: "${FPS:=}"               # Target frame rate, e.g. 25 or 30 (empty = keep original)
: "${AUDIO_BITRATE:=}"     # Audio bitrate, e.g. 128k or 192k (empty = encoder default)

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

        # Build optional ffmpeg parameters
        VIDEO_FILTER=""
        if [ -n "${RESOLUTION}" ] && [ -n "${FPS}" ]; then
            VIDEO_FILTER="-vf scale=${RESOLUTION},fps=${FPS}"
        elif [ -n "${RESOLUTION}" ]; then
            VIDEO_FILTER="-vf scale=${RESOLUTION}"
        elif [ -n "${FPS}" ]; then
            VIDEO_FILTER="-vf fps=${FPS}"
        fi
        AUDIO_OPTS=""
        if [ -n "${AUDIO_BITRATE}" ]; then
            AUDIO_OPTS="-b:a ${AUDIO_BITRATE}"
        fi

        # Perform the conversion using ffmpeg
        ffmpeg -i "$in_file" \
            -vcodec libx264 -preset ${PRESET} -crf ${CRF} \
            ${VIDEO_FILTER} \
            -acodec aac ${AUDIO_OPTS} \
            -threads ${THREADS} \
            "$mp4_file" -y < /dev/null


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
