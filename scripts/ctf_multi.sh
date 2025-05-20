#!/bin/bash

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_json_file>"
    exit 1
fi

FILE="$1"

# Check if the file exists and is readable
if [ ! -f "$FILE" ] || [ ! -r "$FILE" ]; then
    echo "Error: File '$FILE' does not exist or is not readable."
    exit 2
fi

# Get the base directory of the JSON file
BASE_DIR=$(dirname "$(realpath "$FILE")")

# Use Python to properly parse the JSON file
python3 - <<EOF
import json
import os
import subprocess
import sys

def run_challenge(base_dir, challenge_data):
    try:
        year = challenge_data['year']
        event = challenge_data['event']
        category = challenge_data['category']
        challenge_name = challenge_data['challenge']
        rel_path = challenge_data['path']
        
        full_path = os.path.join(base_dir, rel_path)
        data_path = os.path.join(full_path, 'challenge.json')
        repo_path = full_path
        
        if not os.path.exists(data_path):
            print(f"Warning: challenge.json not found at {data_path}, skipping...")
            return False
        
        print(f"\n=== Running challenge: {year} {event} {category} {challenge_name} ===")
        
        cmd = [
            "python", "run.py",
            "--model_name", "Pro/deepseek-ai/DeepSeek-V3",
            "--siliconflow_api_key", "",
            "--ctf",
            "--image_name", "sweagent/enigma:latest",
            "--data_path", data_path,
            "--repo_path", repo_path,
            "--config_file", "config/default_ctf.yaml"
        ]
        
        subprocess.run(cmd, check=True)
        return True
    except Exception as e:
        print(f"Error processing challenge: {e}")
        return False

try:
    with open("$FILE") as f:
        data = json.load(f)
    
    for challenge_id, challenge_data in data.items():
        run_challenge("$BASE_DIR", challenge_data)

except Exception as e:
    print(f"Error loading JSON file: {e}")
    sys.exit(1)
EOF

