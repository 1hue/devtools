#!/bin/bash
set -euo pipefail

name=$(basename "${BASH_SOURCE[0]}") # name called by: run.sh, or a TOOL symlink

IMAGE=localhost/devtools # tools image, built by `make build`
# Tools taken from project's node_modules when installed there (still run in container)
PROJECT_TOOLS=(eslint)

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

# Run a tool against the git root (or cwd): no network unless TOOLS_NET=1,
# read-only unless TOOLS_RW=1 or --write/-w/--fix.
run_tool() {
	local root mode=ro net=none arg
	root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

	case "$root" in
		/|"$HOME")
			echo "$name: not in a project, refusing to mount $root" >&2
			exit 1
			;;
	esac

	# Project's own copy, e.g. eslint whose plugins need its version
	case " ${PROJECT_TOOLS[*]} " in
		*" $1 "*)
			[ -x "$PWD/node_modules/.bin/$1" ] && set -- "$PWD/node_modules/.bin/$1" "${@:2}"
			;;
	esac

	[ "${TOOLS_RW:-0}" = 1 ] && mode=rw
	[ "${TOOLS_NET:-0}" = 1 ] && net=pasta
	for arg in "$@"; do
		case "$arg" in
			--write|-w|--fix) mode=rw ;;
		esac
	done

	local opts=(
		"${SANDBOX[@]}"
		--network "$net"
		-v "$root:$root:$mode" # same path as host, so editor paths match
		-w "$PWD"
	)
	[ -t 0 ] && [ -t 1 ] && opts+=(-t)
	[ -f "$root/package.json" ] && [ ! -d "$root/node_modules" ] &&
		echo "$name: no node_modules in $root, install deps in the project's container" >&2

	exec podman run "${opts[@]}" "$IMAGE" "$@"
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

	  ${cyan}-h${reset}, ${cyan}--help${reset}              display this help and exit

	${bold}Environment:${reset}
	  ${yellow}TOOLS_NET=1${reset}             enable network
	  ${yellow}TOOLS_RW=1${reset}              mount the project writable (implied by --write,
	                          -w and --fix)
	EOF
}

case "$name" in
	run.sh)
		case "${1:-help}" in
			help|-h|--help) usage ;;
			*) run_tool "$@" ;;
		esac
		;;
	*)
		run_tool "$name" "$@"
		;;
esac
