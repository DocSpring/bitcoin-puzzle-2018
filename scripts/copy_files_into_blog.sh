#!/bin/bash
set -e
set -x

# (cd t-rex-runner && yarn build)
# (cd cube_solver && ./scripts/generate_puzzle.rb)

rm -rf "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
mkdir -p "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"

cp t-rex-runner/dist/* "../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
cp cube_solver/build/blocks.json "../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
