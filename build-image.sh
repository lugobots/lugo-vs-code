#!/usr/bin/env bash

set -euo pipefail

IMAGE_REPO="lugobots/vs-code-for-lugo"
BASE_IMAGE_REPO="lugobots/vs-code-for-lugo-base"
PLATFORMS="linux/amd64,linux/arm64"

usage() {
  cat <<'EOF'
Usage:
  ./build-image.sh <tag> <push:true|false> <tag_latest:true|false>

Arguments:
  tag          Image tag to build (example: v1.2.0)
  push         If true, push images to registry
  tag_latest   If true, also tag/push image as latest
EOF
}

to_bool() {
  local value="${1:-}"
  shopt -s nocasematch
  case "$value" in
    true|1|yes|y) echo "true" ;;
    false|0|no|n) echo "false" ;;
    *)
      echo "Invalid boolean value: $value" >&2
      return 1
      ;;
  esac
  shopt -u nocasematch
}

if [[ $# -ne 3 ]]; then
  usage
  exit 1
fi

TAG="$1"
PUSH="$(to_bool "$2")"
TAG_LATEST="$(to_bool "$3")"

if [[ -z "$TAG" ]]; then
  echo "Tag cannot be empty." >&2
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required but not available." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BASE_TAG="${BASE_IMAGE_REPO}:${TAG}"
FINAL_TAG="${IMAGE_REPO}:${TAG}"

TAGS_ARGS=(-t "$FINAL_TAG")
if [[ "$TAG_LATEST" == "true" ]]; then
  TAGS_ARGS+=(-t "${IMAGE_REPO}:latest")
fi

echo "Building base image first: ${BASE_TAG}"
if [[ "$PUSH" == "true" ]]; then
  docker buildx build \
    --platform "$PLATFORMS" \
    -f base.Dockerfile \
    -t "$BASE_TAG" \
    --push \
    .

  echo "Building final image: ${FINAL_TAG}"
  docker buildx build \
    --platform "$PLATFORMS" \
    -f Dockerfile \
    --build-context "lugo-vs=docker-image://${BASE_TAG}" \
    "${TAGS_ARGS[@]}" \
    --push \
    .
else
  HOST_PLATFORM="$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}')"
  LOCAL_BASE_TAG="lugo-vs:local-${TAG}"

  echo "Push disabled: building local image for host platform only (${HOST_PLATFORM})."
  echo "Multi-platform export requires push to a registry."

  docker buildx build \
    --platform "$HOST_PLATFORM" \
    -f base.Dockerfile \
    -t "$LOCAL_BASE_TAG" \
    --load \
    .

  docker buildx build \
    --platform "$HOST_PLATFORM" \
    -f Dockerfile \
    --build-context "lugo-vs=docker-image://${LOCAL_BASE_TAG}" \
    "${TAGS_ARGS[@]}" \
    --load \
    .
fi

echo "Done."
