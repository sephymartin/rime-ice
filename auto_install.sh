#!/bin/bash

# Define source and target directories
RIME_DIR="$HOME/Library/Rime"
CURRENT_DIR=$(dirname "$0")

# Create Rime directory if it doesn't exist
mkdir -p "$RIME_DIR"

# Function to compare files using MD5 and copy if different
copy_if_different() {
    local src="$1"
    local dest="$2"
    
    if [ ! -f "$dest" ]; then
        echo "New file: $(basename "$src")"
        cp "$src" "$dest"
    else
        src_md5=$(md5 -q "$src")
        dest_md5=$(md5 -q "$dest")
        
        if [ "$src_md5" != "$dest_md5" ]; then
            echo "Updating: $(basename "$src")"
            cp "$src" "$dest"
        fi
    fi
}

# Copy yaml files if different
echo "Checking configuration files..."
for file in "$CURRENT_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        dest_file="$RIME_DIR/$(basename "$file")"
        copy_if_different "$file" "$dest_file"
    fi
done

# Copy dictionary files from various directories
echo "Checking dictionary files..."
# Dictionary directories to process
dict_dirs=("cn_dicts" "en_dicts" "opencc" "lua")

for dir in "${dict_dirs[@]}"; do
    if [ -d "$CURRENT_DIR/$dir" ]; then
        echo "Checking $dir directory..."
        # Create target directory if it doesn't exist
        mkdir -p "$RIME_DIR/$dir"
        
        # Copy all files from the directory
        for file in "$CURRENT_DIR/$dir"/*.*; do
            if [ -f "$file" ]; then
                dest_file="$RIME_DIR/$dir/$(basename "$file")"
                copy_if_different "$file" "$dest_file"
            fi
        done
    fi
done

# Special handling for lua/cold_word_drop if it exists
if [ -d "$CURRENT_DIR/lua/cold_word_drop" ]; then
    echo "Checking lua/cold_word_drop directory..."
    mkdir -p "$RIME_DIR/lua/cold_word_drop"
    for file in "$CURRENT_DIR/lua/cold_word_drop"/*.*; do
        if [ -f "$file" ]; then
            dest_file="$RIME_DIR/lua/cold_word_drop/$(basename "$file")"
            copy_if_different "$file" "$dest_file"
        fi
    done
fi

echo "Update complete!"
echo "Please restart Rime if any files were updated"