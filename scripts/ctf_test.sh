#!/bin/bash

# python run.py \
#   --model_name gpt4 \
#   --ctf \
#   --image_name sweagent/enigma:latest \
#   --data_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/challenge.json \
#   --repo_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/ \
#   --config_file config/default_ctf.yaml

# 使用SiliconFlow API密钥作为参数
python run.py \
  --model_name "Pro/deepseek-ai/DeepSeek-V3" \
  --siliconflow_api_key "" \
  --ctf \
  --image_name sweagent/enigma:latest \
  --data_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/challenge.json \
  --repo_path ../LLM_CTF_Database/test/2018/CSAW-Finals/misc/leaked_flag/ \
  --config_file config/default_ctf.yaml
  
# 或使用环境变量提供API密钥
# export SILICONFLOW_API_KEY="your_api_key_here"
# python run.py --model_name "qwen-coder-7b" --model_provider "siliconflow" ...