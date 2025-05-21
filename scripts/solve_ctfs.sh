# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "" > output.txt
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "" --model "Qwen/Qwen3-8B" > output2.txt
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "" --model "Qwen/Qwen3-8B" > output3.txt


python solve_all_ctf.py \
  --intercode \
  --api_key "" \
  --database_path ../intercode \
  --model "Qwen/Qwen3-8B" \
# # 只解决加密类挑战
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "your_api_key" --category crypto

# # 只解决2023年的挑战
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "your_api_key" --year 2023

# # 限制解决10个挑战
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "your_api_key" --max_challenges 10

# # 结合多个条件
# python solve_all_ctf.py --database_path ../LLM_CTF_Database --api_key "your_api_key" --category web --year 2022 --max_challenges 5