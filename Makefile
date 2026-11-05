# Tools image and host links
.PHONY: build link unlink sh

IMAGE = localhost/devtools
# Base of tools image
NODE_IMAGE = docker.io/library/node:alpine
# Minimum package age (days)
MIN_RELEASE_AGE = 7

# Default tools for link
LINKS = node prettier eslint tsc
BIN = $(HOME)/.local/bin
RUNNER = $(CURDIR)/scripts/run.sh

# Build image with newest tools
# Unchanged package.json reuses old install without --no-cache
build:
	podman build --pull=newer --no-cache -t $(IMAGE) --build-arg NODE_IMAGE=$(NODE_IMAGE) --build-arg MIN_RELEASE_AGE=$(MIN_RELEASE_AGE) image

# Symlink LINKS into BIN, replacing other links to run.sh
link: unlink
	for tool in $(LINKS); do ln -sf $(RUNNER) $(BIN)/$$tool && echo "linked $$tool"; done

# Remove links to run.sh from BIN
unlink:
	mkdir -p $(BIN)
	find $(BIN) -maxdepth 1 -lname $(RUNNER) -printf 'unlinked %f\n' -delete

# Shell into tools container
sh:
	scripts/run.sh sh
