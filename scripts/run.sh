#!/bin/bash
set -euo pipefail

name=$(basename "${BASH_SOURCE[0]}") # name called by: run.sh, or a TOOL symlink

script=$(readlink -f "${BASH_SOURCE[0]}")
IMAGES=${script%/scripts/run.sh}/image # one folder per image, built by `make build`
IMAGE_PREFIX=localhost/devtools- # image name before folder name

# Defaults for image/NAME/config
TOOLS=()
PROJECT_TOOLS=()
PROJECT_BIN=
WRITE_ARGS=()

# Fixed `podman run` flags for every tool
SANDBOX=(
	--rm -i # -i: stdin for LSP stdio and piped input
	--init # forwards signals, so Ctrl+C works
	--userns=keep-id # run as you, so written files are yours
	--cap-drop=all
	--security-opt=no-new-privileges
	--security-opt=label=disable # SELinux: don't relabel arbitrary project dirs
	--read-only # container fs immutable; scratch in /tmp
	--tmpfs /tmp
)

# Print image whose config lists TOOL
find_image() {
	local config

	for config in "$IMAGES"/*/config; do
		if (. "$config"; [[ " ${TOOLS[*]} " == *" $1 "* ]]); then
			basename "$(dirname "$config")"
			return
		fi
	done
}

# List tools of every image
list_tools() {
	local config

	for config in "$IMAGES"/*/config; do
		(. "$config"; echo "${TOOLS[*]}")
	done
}

# Run a tool against the git root (or cwd): no network unless TOOLS_NET=1,
# read-only unless TOOLS_RW=1 or one of the image's WRITE_ARGS.
run_tool() {
	local root mode=ro net=none arg image
	root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

	case "$root" in
		/|"$HOME")
			echo "$name: not in a project, refusing to mount $root" >&2
			exit 1
			;;
	esac

	image=${TOOLS_IMAGE:-$(find_image "$1")}
	if [ -z "$image" ]; then
		echo "$name: no image provides $1" >&2
		exit 1
	fi
	. "$IMAGES/$image/config"

	# Project's own copy, e.g. eslint whose plugins need its version
	case " ${PROJECT_TOOLS[*]} " in
		*" $1 "*)
			[ -x "$PWD/$PROJECT_BIN/$1" ] && set -- "$PWD/$PROJECT_BIN/$1" "${@:2}"
			;;
	esac

	[ "${TOOLS_RW:-0}" = 1 ] && mode=rw
	[ "${TOOLS_NET:-0}" = 1 ] && net=pasta
	for arg in "$@"; do
		case " ${WRITE_ARGS[*]} " in
			*" $arg "*) mode=rw ;;
		esac
	done

	local opts=(
		"${SANDBOX[@]}"
		--network "$net"
		-v "$root:$root:$mode" # same path as host, so editor paths match
		-w "$PWD"
	)
	[ -t 0 ] && [ -t 1 ] && opts+=(-t)

	exec podman run "${opts[@]}" "$IMAGE_PREFIX$image" "$@"
}

# Color only on a terminal, and respect NO_COLOR.
usage() {
	local bold= cyan= yellow= reset=
	if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
		bold=$'\e[1m' cyan=$'\e[36m' yellow=$'\e[33m' reset=$'\e[0m'
	fi
	cat <<-EOF
	${bold}Usage:${reset} $name TOOL [ARG]...
	  or:  TOOL [ARG]...
	Run TOOL in a container, without network and with the project read-only.

	  ${cyan}-l${reset}, ${cyan}--list${reset}              list tools of every image
	  ${cyan}-h${reset}, ${cyan}--help${reset}              display this help and exit

	${bold}Environment:${reset}
	  ${yellow}TOOLS_NET=1${reset}             enable network
	  ${yellow}TOOLS_RW=1${reset}              mount the project writable (implied by the image's
	                          WRITE_ARGS, like --write and --fix)
	  ${yellow}TOOLS_IMAGE=NAME${reset}        run in image/NAME instead of the image providing TOOL
	EOF
}

case "$name" in
	run.sh)
		case "${1:-help}" in
			help|-h|--help) usage ;;
			-l|--list) list_tools ;;
			*) run_tool "$@" ;;
		esac
		;;
	*)
		run_tool "$name" "$@"
		;;
esac
