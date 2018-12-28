#!/bin/bash
set -e
set -x

# (cd cube_solver && ./scripts/generate_puzzle.rb)
# (cd t-rex-runner && yarn build)
# (cd virtual_machine && \
#   ./scripts/compile_instructions.rb && \
#   ./scripts/generate_tests.rb)

POST_DIR="../form_api/blog/static/posts/2018-bitcoin-programming-challenge"

rm -rf "${POST_DIR}"
mkdir -p "${POST_DIR}"

cp cube_solver/build/blocks.json "${POST_DIR}/"

TREX_DIR="${POST_DIR}/d63c04bfa19fa546a175ca90f5b9a4bc718f6233a574c6058d57e80b5de12cf5"
mkdir -p "${TREX_DIR}"
cp t-rex-runner/dist/* "${TREX_DIR}/"

VM_DIR="${POST_DIR}/a129db6cc02c06b7ab645a941eb9fbaf5f3349786e7b6f929ff4f29b2ea7ea2e"
mkdir -p "${VM_DIR}"
cp virtual_machine/build/* "${VM_DIR}/"

echo "Nice try! But you do have to solve the cube first." > "${POST_DIR}/<hex-encoded-private-key>"
echo "Nice try! But you do have to solve the cube first." > "${POST_DIR}/hex-encoded-private-key"
