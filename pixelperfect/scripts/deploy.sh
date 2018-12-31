#!/bin/bash
set -e

if ! [ -d deploy ]; then
  echo "deploy directory does not exist."
  set -x
  git clone git@gitlab.com:form_api/pixel_perfect.git deploy
  cd deploy
  git checkout build
  set +x
  echo "Cloned the repo. Please try again."
  exit 1
fi

set -x

yarn build
rm -rf deploy/static/ deploy/*
cp -R build/* deploy/
cd deploy
git add -A
git commit -m "Update"
git push
