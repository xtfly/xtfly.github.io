#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

rm -rf ./public
rm -rf ./images
python3 ./gen_readme.py

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site by hugo"
if [[ $# -eq 1 ]];then 
  msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin hugo
if [[ $? -ne 0 ]];then
  echo "push hugo branch to remote failed"
  exit 1
fi

rm -rf ../public
mkdir -p ../public
# Build the project.
hugo -d ../public/
rm -rf .hugo_build.lock

# Checkout to master
git checkout master
if [[ $? -ne 0 ]];then
  echo "checkout master failed"
  exit 1
fi

rm -rf ./*
echo "lanlingzi.cn" > CNAME
cp -R ../public/* ./

git add -A
git commit -m "$msg"
git push origin master
if [[ $? -ne 0 ]];then
  echo "push master branch to remote failed"
  exit 1
fi

# Back to master
git checkout hugo
