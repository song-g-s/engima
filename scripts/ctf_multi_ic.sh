#!/bin/bash

# 定义路径
CTF_JSON="../data/ctf/ic_ctf.json"
TASK_ASSETS_DIR="../data/ctf/task_assets/"
TEMP_DIR="./temp_challenges"
CONFIG_FILE="config/default_ctf.yaml"

# 定义跳过条件
skip_list=()		# 要跳过的ID
skip_start=3		# 跳过小于的ID
skip_end=99		# 跳过大于的ID
todo_list=()	# 非空时忽略跳过，仅执行其中的id

# 检查文件是否存在
if [ ! -f "$CTF_JSON" ]; then
    echo "Error: CTF JSON file not found at $CTF_JSON"
    exit 1
fi

if [ ! -d "$TASK_ASSETS_DIR" ]; then
    echo "Error: Task assets directory not found at $TASK_ASSETS_DIR"
    exit 1
fi

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 使用Python处理JSON并运行测试
python3 - <<EOF
import json
import os
import shutil
import subprocess
from pathlib import Path

# 从Bash获取跳过参数
skip_list = [${skip_list[@]}]
skip_start = ${skip_start}
skip_end = ${skip_end}
todo_list = [${todo_list[@]}]

shutil.rmtree("$TEMP_DIR", ignore_errors=True)

# 读取CTF JSON文件
with open("$CTF_JSON") as f:
    challenges = json.load(f)

# 处理每个挑战
for challenge in challenges:
    task_id = challenge["task_id"]
    
    # 跳过条件检查
    if todo_list:
        if task_id not in todo_list:
            continue
    elif task_id in skip_list or task_id < skip_start or task_id > skip_end:
        continue
    
    query = challenge["query"]
    gold = challenge["gold"]
    source = challenge["source"]
    tags = challenge["tags"]
    
    with open('result.txt', 'a', encoding='utf-8') as file:
        file.write(f"{task_id}: ")
    
    # 创建临时目录
    temp_dir = os.path.join("$TEMP_DIR", f"task_{task_id}")
    os.makedirs(temp_dir, exist_ok=True)
    
    # 复制任务资源文件
    task_src_dir = os.path.join("$TASK_ASSETS_DIR", str(task_id))
    if os.path.exists(task_src_dir):
        for item in os.listdir(task_src_dir):
            src = os.path.join(task_src_dir, item)
            dst = os.path.join(temp_dir, item)
            if os.path.isdir(src):
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)
    
    # 创建challenge.json
    challenge_json = {
        "name": f"IC_CTF_Task_{task_id}",
        "description": query,
        "flag": gold,
        "points": 100,
        "category": tags[0] if tags else "Miscellaneous",
        "author": "IC_CTF",
        "source": source,
        "files": [f for f in os.listdir(temp_dir) if os.path.isfile(os.path.join(temp_dir, f))]
    }
    
    with open(os.path.join(temp_dir, "challenge.json"), "w") as f:
        json.dump(challenge_json, f, indent=2)
    
    # 运行测试
    print(f"\n=== Running Task {task_id} ===")
    print(f"Category: {tags[0] if tags else 'Miscellaneous'}")
    print(f"Description: {query[:100]}...")  # 只打印前100字符
    
    cmd = [
        "python", "run.py",
        "--model_name", "Pro/deepseek-ai/DeepSeek-V3",
        "--siliconflow_api_key", "",
        "--ctf",
        "--image_name", "sweagent/enigma:latest",
        "--data_path", os.path.join(temp_dir, "challenge.json"),
        "--config_file", "$CONFIG_FILE",
        "--print_config", "False"
    ]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running task {task_id}: {e}")
    
    print("="*50)

# 清理临时目录
# shutil.rmtree("$TEMP_DIR")
EOF

echo "All tasks completed."

