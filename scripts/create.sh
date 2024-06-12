#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${PROG_DIR}/.." && pwd)"
readonly BIN_DIR="${ROOT_DIR}/.bin"
readonly IMAGES_JSON="${ROOT_DIR}/images.json"
readonly BUILD_DIR="${ROOT_DIR}/build"
REGISTRY=""
TOML="stack.toml"

# shellcheck source=SCRIPTDIR/.util/tools.sh
source "${PROG_DIR}/.util/tools.sh"

# shellcheck source=SCRIPTDIR/.util/print.sh
source "${PROG_DIR}/.util/print.sh"

if [[ $BASH_VERSINFO -lt 4 ]]; then
  util::print::error "Before running this script please update Bash to v4 or higher (e.g. on OSX: \$ brew install bash)"
fi

function main() {
  local flags
  local stack_dir_name build_dir_name
  stack_dir_name=""
  build_dir_name=""

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
      --help|-h)
        shift 1
        usage
        exit 0
        ;;

      --secret)
        flags+=("--secret" "${2}")
        shift 2
        ;;

      --label)
        flags+=("--label" "${2}")
        shift 2
        ;;

      --stack-dir)
        stack_dir_name="${2}"
        shift 2
        ;;

      --build-dir)
        build_dir_name="${2}"
        shift 2
        ;;

      --registry)
        REGISTRY="${2}"
        TOML="stack-arm-amd.toml"
        shift 2
        ;;

      "")
        # skip if the argument is empty
        shift 1
        ;;

      *)
        util::print::error "unknown argument \"${1}\""
    esac
  done

  tools::install

  # if stack or build argument is provided but not both, then throw an error
  if [[ -n "${stack_dir_name}" && ! -n "${build_dir_name}" ]] || [[ ! -n "${stack_dir_name}" && -n "${build_dir_name}" ]]; then
    util::print::error "Both stack-dir and build-dir must be provided"
  elif [[ -n "${stack_dir_name}" && -n "${build_dir_name}" ]]; then
    stack::create "${ROOT_DIR}/${stack_dir_name}" "${ROOT_DIR}/${build_dir_name}" "${flags[@]}"
  elif [ -f "${IMAGES_JSON}" ]; then
    jq -c '.images[]' "${IMAGES_JSON}" | while read -r image; do
      config_dir=$(echo "${image}" | jq -r '.config_dir')
      output_dir=$(echo "${image}" | jq -r '.output_dir')
      stack::create "${ROOT_DIR}/${config_dir}" "${ROOT_DIR}/${output_dir}" "${flags[@]}"
    done
  else
    stack::create "${ROOT_DIR}/stack" "${ROOT_DIR}/build" "${flags[@]}"
  fi
}

function usage() {
  cat <<-USAGE
create.sh [OPTIONS]

Creates the stack using the descriptor, build and run Dockerfiles in
the repository.

OPTIONS
  --help       -h   prints the command usage
  --secret          provide a secret in the form key=value. Use flag multiple times to provide multiple secrets
  --stack-dir       Provide the stack directory relative to the root directory. The default value is 'stack'.
  --build-dir       Provide the build directory relative to the root directory. The default value is 'build'.
  --registry        registry (ex: harbor.h2o-4-11809.h2o.vmware.com/tanzubuild) use this to build multiplatform "linux/amd64" and "linux/arm64" 
USAGE
}


function tools::install() {
  util::tools::jam::install \
    --directory "${BIN_DIR}"
}

function stack::create() {
  local flags
  local stack_dirpath build_dirpath

  stack_dirpath="${1}"
  shift
  build_dirpath="${1}"
  shift

  mkdir -p "${build_dirpath}"

  flags=("${@}")

  args=(
      --config "${stack_dirpath}/${TOML}"
      --build-output "${build_dirpath}/build.oci"
      --run-output "${build_dirpath}/run.oci"
  )
  if [[ -n "${REGISTRY}" ]]; then
    args+=(
      --publish
      --build-ref "${REGISTRY}/paketo/build-jammy-base:jammy"
      --run-ref "${REGISTRY}/paketo/run-jammy-base:jammy"
    )
  fi

  args+=("${flags[@]}")
  echo "Executing: jam create-stack ${args[@]}"
  
  jam create-stack "${args[@]}"
}

main "${@:-}"
