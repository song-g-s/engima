#!/usr/bin/env python3

import os
import json
import glob
from collections import defaultdict

def analyze_trajectories(directory="trajectories"):
    # 找到所有.traj文件
    traj_files = glob.glob(f"{directory}/**/*.traj", recursive=True)
    
    results = {
        "total": len(traj_files),
        "success": 0,
        "failed": 0,
        "by_category": defaultdict(lambda: {"total": 0, "success": 0}),
    }
    
    for traj_file in traj_files:
        try:
            with open(traj_file, 'r') as f:
                data = json.load(f)
            
            # 查找提交状态
            success = False
            category = "unknown"
            
            # 从trajectory提取分类信息
            if "context" in data and "description" in data["context"]:
                if "category_friendly" in data["context"]:
                    category = data["context"]["category_friendly"]
                    
            # 检查是否成功找到flag
            if "submission" in data and data["submission"]:
                success = True
            
            # 更新统计信息
            results["by_category"][category]["total"] += 1
            if success:
                results["success"] += 1
                results["by_category"][category]["success"] += 1
            else:
                results["failed"] += 1
                
        except Exception as e:
            print(f"分析轨迹文件出错 {traj_file}: {e}")
    
    # 计算成功率
    success_rate = (results["success"] / results["total"] * 100) if results["total"] > 0 else 0
    
    # 打印结果
    print(f"\n{'='*50}")
    print(f"CTF挑战解决统计")
    print(f"{'='*50}")
    print(f"总计挑战: {results['total']}")
    print(f"成功解决: {results['success']} ({success_rate:.1f}%)")
    print(f"未能解决: {results['failed']}")
    print(f"\n按类别统计:")
    
    for category, stats in results["by_category"].items():
        cat_success_rate = (stats["success"] / stats["total"] * 100) if stats["total"] > 0 else 0
        print(f"  {category}: {stats['success']}/{stats['total']} ({cat_success_rate:.1f}%)")
    
    return results

if __name__ == "__main__":
    analyze_trajectories()