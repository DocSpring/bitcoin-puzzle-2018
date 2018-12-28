#!/bin/bash
set -e
set -x

./scripts/generate_puzzle.rb

rm -rf "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge/blocks.json"
mkdir -p "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
cp build/* "../../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
