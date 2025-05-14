#!/usr/bin/env python3

import os
import subprocess
import glob
import json
from pathlib import Path
import time
import argparse
from sweagent.utils.log import add_file_handler, get_logger
import logging

logger = get_logger("swe-agent-run")
logging.getLogger("simple_parsing").setLevel(logging.WARNING)

def find_challenge_files(base_dir):
    """查找所有challenge.json文件"""
    return glob.glob(f"{base_dir}/**/challenge.json", recursive=True)

def run_enigma_on_challenge(challenge_path, model_name, api_key):
    """对单个挑战运行EnIGMA"""
    challenge_dir = os.path.dirname(challenge_path)
    
    # 从challenge.json加载数据，提取分类和名称用于日志
    try:
        with open(challenge_path, 'r') as f:
            challenge_data = json.load(f)
        category = challenge_data.get('category', 'unknown')
        name = challenge_data.get('name', os.path.basename(challenge_dir))
        points = challenge_data.get('points', 0)
    except Exception as e:
        category = "unknown"
        name = os.path.basename(challenge_dir)
        points = 0
    
    logger.info(f"\n{'='*80}")
    logger.info(f"开始解决: {category} - {name} ({points}分)")
    logger.info(f"挑战路径: {challenge_path}")
    logger.info(f"{'='*80}\n")
    
    # 确定使用哪个配置文件
    if category.lower() in ['crypto']:
        config_file = "config/ctf/ctf_crypto.yaml"
    elif category.lower() in ['web']:
        config_file = "config/ctf/ctf_web_no_interactive.yaml"
    elif category.lower() in ['rev', 'reverse']:
        config_file = "config/ctf/ctf_rev_simple_summarizer.yaml"
    elif category.lower() in ['forensics']:
        config_file = "config/ctf/ctf_forensics_no_interactive.yaml"
    elif category.lower() in ['pwn']:
        config_file = "config/ctf/ctf_pwn.yaml"
    else:
        config_file = "config/default_ctf.yaml"
    
    # 构建命令
    cmd = [
        "python", "run.py",
        "--model_name", model_name,

        "--siliconflow_api_key", api_key,
        "--ctf",
        "--image_name", "sweagent/enigma:latest",
        "--data_path", challenge_path,
        "--repo_path", challenge_dir,
        "--config_file", config_file,
        "--per_instance_cost_limit", "5.00"  # 增加限制以确保有足够时间解决
    ]

    logger.info(f"运行命令: {' '.join(cmd)}")
    
    # 运行命令
    try:
        subprocess.run(cmd, check=True)
        return True
    except subprocess.CalledProcessError:
        logger.info(f"❌ 解决 {name} 失败")
        return False
    finally:
        # 每次挑战结束后等待几秒，以防API限制
        time.sleep(5)

def main():
    parser = argparse.ArgumentParser(description="批量解决CTF挑战")
    parser.add_argument("--database_path", type=str, required=True, help="NYU CTF数据库根目录")
    parser.add_argument("--model", type=str, default="Pro/deepseek-ai/DeepSeek-V3", help="要使用的模型")
    parser.add_argument("--api_key", type=str, help="SiliconFlow API密钥")
    parser.add_argument("--category", type=str, help="只解决指定分类的挑战(crypto, web, rev等)")
    parser.add_argument("--year", type=str, help="只解决特定年份的挑战")
    parser.add_argument("--max_challenges", type=int, help="最多解决的挑战数")
    args = parser.parse_args()
    logger.info("" + "="*80)
    logger.info("批量解决CTF挑战")
    # 查找所有挑战
    challenges = find_challenge_files(args.database_path)
    logger.info(f"找到 {len(challenges)} 个挑战")
    
    # 应用过滤器
    if args.category:
        challenges = [c for c in challenges if f"/{args.category}/" in c.lower()]
        logger.info(f"过滤后剩余 {len(challenges)} 个 {args.category} 类型的挑战")
        
    if args.year:
        challenges = [c for c in challenges if f"/{args.year}/" in c]
        logger.info(f"过滤后剩余 {len(challenges)} 个 {args.year} 年的挑战")
    
    if args.max_challenges and args.max_challenges > 0:
        challenges = challenges[:args.max_challenges]
        logger.info(f"限制为最多 {args.max_challenges} 个挑战")
    
    # 解决每个挑战
    success_count = 0
    for i, challenge in enumerate(challenges):
        logger.info(f"\n进度: [{i+1}/{len(challenges)}]")
        if run_enigma_on_challenge(challenge, args.model, args.api_key):
            success_count += 1
    
    logger.info(f"\n{'='*80}")
    logger.info(f"批量解决完成! 成功: {success_count}/{len(challenges)}")
    logger.info(f"{'='*80}")

if __name__ == "__main__":
    main()