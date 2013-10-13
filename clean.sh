#!/bin/bash
set -e
git checkout master
git pull
git branch -d lgw
git push origin :lgw

# push new branch
# git push -u git@github.com:weinhouse/Rx.git lgw
