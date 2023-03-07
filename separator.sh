#!/bin/bash

eval $(python3 -c 'import yaml; print("MAX_CHUNK_SIZE=" + str(yaml.safe_load(open("config.yaml"))["config"]["MAX_CHUNK_SIZE"]))')
eval $(python3 -c 'import yaml; print("MAX_TOKENS=" + str(yaml.safe_load(open("config.yaml"))["config"]["MAX_TOKENS"]))')

echo "MAX_CHUNK_SIZE: $MAX_CHUNK_SIZE"
echo "MAX_TOKENS: $MAX_TOKENS"

INPUT_FILE="$2"

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
CHUNK_DIR="./.repo/$1/chunks/$TIMESTAMP"

mkdir -p "$CHUNK_DIR"

# Get total size of input file
TOTAL_SIZE=$(wc -c < "$INPUT_FILE")
echo "TOTAL_SIZE: $TOTAL_SIZE"

# Calculate total number of chunks needed
TOTAL_CHUNKS=$((($TOTAL_SIZE + $MAX_CHUNK_SIZE - 1) / $MAX_CHUNK_SIZE))
echo "TOTAL_CHUNKS: $TOTAL_CHUNKS"


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
      echo "$SUB_CHUNK" > "$CHUNK_DIR/${1}_${i}"
    done
  else
    # Save chunk to file
    echo "$CHUNK" > "$CHUNK_DIR/${1}_${i}"
  fi
done
