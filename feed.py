import argparse
import os
import subprocess
import sys

parser = argparse.ArgumentParser(description="feed code to gpt")
parser.add_argument("repository", help="'username/repo_name (GH)'")
parser.add_argument("-b", "--branch", help="(default: master)", default="master")
parser.add_argument("-d", "--directory", help="the local directory to clone")
args = parser.parse_args()

username, repo_name = args.repository.split("/")

if os.path.isdir(repo_dir):
    print(f"The directory {repo_dir} already exists.")
    sys.exit(1)


repo_url = f"git@github.com:{username}/{args.directory or repo_name}.git"
repo_dir = os.path.join(os.getcwd(), args.directory or repo_name)


os.chdir(os.path.join(os.getcwd(), "."))
subprocess.run(["git", "clone", "-b", args.branch, repo_url, repo_dir], check=True)
subprocess.run(["./extractor.sh", "."], check=True)
subprocess.run(["./separator.sh", "./._dump_extract"], check=True)
