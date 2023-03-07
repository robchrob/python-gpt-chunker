#!/bin/bash

# Set max chunk size (in bytes)
MAX_CHUNK_SIZE=3600

# Set max tokens per chunk (1 token ~ 3/4 of a word)
MAX_TOKENS=1200

# Get input file
INPUT_FILE="$1"

# Create directory to store chunks
DIR=$(date +"%Y-%m-%d-%H-%M-%S")
mkdir -p "./chunks/$DIR"

# Get total size of input file
TOTAL_SIZE=$(wc -c < "$INPUT_FILE")

# Calculate total number of chunks needed
TOTAL_CHUNKS=$((($TOTAL_SIZE + $MAX_CHUNK_SIZE - 1) / $MAX_CHUNK_SIZE))

# Split input file into chunks
for ((i=0; i<$TOTAL_CHUNKS; i++)); do
  # Calculate offset for current chunk
  OFFSET=$(($i * $MAX_CHUNK_SIZE))

  # Calculate number of bytes to read for current chunk
  BYTES_TO_READ=$MAX_CHUNK_SIZE
  if (($OFFSET + $BYTES_TO_READ > $TOTAL_SIZE)); then
    BYTES_TO_READ=$(($TOTAL_SIZE - $OFFSET))
  fi

  # Read chunk from input file
  CHUNK=$(dd if="$INPUT_FILE" bs=$BYTES_TO_READ count=1 skip=$i 2>/dev/null)

  # Count number of tokens in chunk
  TOKEN_COUNT=$(echo "$CHUNK" | wc -w)

  # If chunk contains more tokens than max tokens per chunk, split it into smaller chunks
  if (($TOKEN_COUNT > $MAX_TOKENS)); then
    # Calculate number of smaller chunks needed
    NUM_SUB_CHUNKS=$((($TOKEN_COUNT + $MAX_TOKENS - 1) / $MAX_TOKENS))

    # Split chunk into smaller chunks
    for ((j=0; j<$NUM_SUB_CHUNKS; j++)); do
      # Calculate offset for current sub-chunk
      SUB_OFFSET=$(($j * $MAX_TOKENS))

      # Calculate number of tokens to keep for current sub-chunk
      TOKENS_TO_KEEP=$MAX_TOKENS
      if (($SUB_OFFSET + $TOKENS_TO_KEEP > $TOKEN_COUNT)); then
        TOKENS_TO_KEEP=$(($TOKEN_COUNT - $SUB_OFFSET))
      fi

      # Extract current sub-chunk from chunk
      SUB_CHUNK=$(echo "$CHUNK" | awk -v start=$(($SUB_OFFSET + 1)) -v end=$(($SUB_OFFSET + $TOKENS_TO_KEEP)) '{ for (i=start; i<=end; i++) printf("%s ", $i); }')

      # Save sub-chunk to file
      echo "$SUB_CHUNK" > "./chunks/$DIR/chunk_${i}_$j"
    done
  else
    # Save chunk to file
    echo "$CHUNK" > "./chunks/$DIR/chunk_$i"
  fi
done
