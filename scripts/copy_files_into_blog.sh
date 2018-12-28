#!/bin/bash
set -e
set -x

# (cd cube_solver && ./scripts/generate_puzzle.rb)
# (cd t-rex-runner && yarn build)
# (cd virtual_machine && \
#   ./scripts/compile_instructions.rb && \
#   ./scripts/generate_tests.rb)


rm -rf "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"
mkdir -p "../form_api/blog/static/posts/2018-bitcoin-programming-challenge"

cp t-rex-runner/dist/* "../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"
cp cube_solver/build/blocks.json "../form_api/blog/static/posts/2018-bitcoin-programming-challenge/"

VM_DIR="../form_api/blog/static/posts/2018-bitcoin-programming-challenge/a129db6cc02c06b7ab645a941eb9fbaf5f3349786e7b6f929ff4f29b2ea7ea2e"
mkdir -p $VM_DIR
cp virtual_machine/build/* "$VM_DIR/"
