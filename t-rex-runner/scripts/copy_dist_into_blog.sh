#!/bin/bash
set -e
set -x

yarn build
rm -rf "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
mkdir -p "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
cp dist/* "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
