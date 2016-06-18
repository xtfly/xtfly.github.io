#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

rm -rf ./public
rm -rf ./images

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site by hugo"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin hugo

rm -rf ../public
mkdir -p ../public
# Build the project.
hugo -d ../public/

git checkout master

rm -rf ./*
echo "lanlingzi.cn" > CNAME
cp -R ../public/* ./

git add -A
git commit -m "$msg"
git push origin master
git checkout hugo
