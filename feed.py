import argparse
import os
import subprocess
import sys
import stat
import shutil
from subprocess import call

parser = argparse.ArgumentParser(description="feed code to gpt")
parser.add_argument("repository", help="'username/repo_name (GH)'")
parser.add_argument("-b", "--branch", help="(default: master)", default="master")
args = parser.parse_args()

username, repo_name = args.repository.split("/")

repo_url = f"git@github.com:{username}/{repo_name}.git"

os.chdir(os.path.join(os.getcwd(), "."))

if not os.path.exists('.repo'):
    os.makedirs('.repo')
else:
    if os.path.exists(f".repo/{repo_name}"):
        print((f".repo/{repo_name}"))
        print("Repository already cloned, forfce remove and run again if want to refresh.")



subprocess.run(["git", "clone", "--depth", "1", "-b", args.branch, repo_url, f".repo/{repo_name}"], check=True)

subprocess.run([f"./extractor.sh", f"./.repo/{repo_name}/."], check=True)
subprocess.run([f"./separator.sh", f"{repo_name}", '._dump_extract'], check=True)
