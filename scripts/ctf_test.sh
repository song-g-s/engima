#!/bin/bash

python run.py \
  --model_name gpt4 \
  --ctf \
  --image_name sweagent/enigma:latest \
  --data_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/challenge.json \
  --repo_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/ \
  --config_file config/default_ctf.yaml