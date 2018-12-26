#!/bin/bash
set -e

(cd t-rex-runner/ && yarn build)
rm -rf "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
mkdir -p "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
cp t-rex-runner/dist/* "../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
