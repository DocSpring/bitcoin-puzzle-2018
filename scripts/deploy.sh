#!/bin/bash
set -e

if ! [ -d deploy ]; then
  echo "deploy directory does not exist."
  set -x
  git clone git@gitlab.com:form_api/btc2018.git deploy
  cd deploy
  set +x
  echo "Cloned the repo. Please try again."
  exit 1
fi

set -x

# (cd cube_solver && ./scripts/generate_puzzle.rb)
# (cd t-rex-runner && yarn build)
# (cd virtual_machine && \
#   ./scripts/compile_instructions.rb && \
#   ./scripts/generate_tests.rb)

DEPLOY_DIR="deploy"

mkdir -p "${DEPLOY_DIR}"

# We upload this to S3 now.
# PP_DIR="${DEPLOY_DIR}/pixel-perfect"
# rm -rf "${PP_DIR}"
# mkdir -p "${PP_DIR}"
# cp -R pixelperfect/build/* "${PP_DIR}/"

# Don't delete cubes dir - we put the rendered blog post HTML in there.
CUBES_DIR="${DEPLOY_DIR}/eab75cf16b878ce659a3c3d7b8a71cad2ea48a508f9333ef37807a3c8ff3f531"
mkdir -p "${CUBES_DIR}"
cp cube_solver/build/blocks.json "${CUBES_DIR}/"
cp -R cube_solver/site/* "${CUBES_DIR}/"

TREX_DIR="${DEPLOY_DIR}/d63c04bfa19fa546a175ca90f5b9a4bc718f6233a574c6058d57e80b5de12cf5"
rm -rf "${TREX_DIR}"
mkdir -p "${TREX_DIR}"
cp t-rex-runner/dist/* "${TREX_DIR}/"

VM_DIR="${DEPLOY_DIR}/a129db6cc02c06b7ab645a941eb9fbaf5f3349786e7b6f929ff4f29b2ea7ea2e"
rm -rf "${VM_DIR}"
mkdir -p "${VM_DIR}"
cp virtual_machine/build/* "${VM_DIR}/"

echo "Nice try! But you do have to solve the cube first." > "${DEPLOY_DIR}/<hex-encoded-private-key>"
echo "Nice try! But you do have to solve the cube first." > "${DEPLOY_DIR}/hex-encoded-private-key"

cd deploy
git add -A
git commit -m "Update"
git push
