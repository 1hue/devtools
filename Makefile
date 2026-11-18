# Tool images and host links
.PHONY: build link unlink sh

# Image folders, each built as PREFIX + folder name
IMAGES = $(notdir $(wildcard image/*))
PREFIX = localhost/devtools-

# Default tools for link
LINKS = $(shell $(RUNNER) --list)
BIN = $(HOME)/.local/bin
RUNNER = $(CURDIR)/scripts/run.sh

# Build every image with newest tools
build: $(addprefix build-,$(IMAGES))

# Build one image, like make build-node
# Unchanged package.json reuses old install without --no-cache
build-%:
	podman build --pull=newer --no-cache -t $(PREFIX)$* image/$*

# Symlink LINKS into BIN, replacing other links to run.sh
link: unlink
	for tool in $(LINKS); do ln -sf $(RUNNER) $(BIN)/$$tool && echo "linked $$tool"; done

# Remove links to run.sh from BIN
unlink:
	mkdir -p $(BIN)
	find $(BIN) -maxdepth 1 -lname $(RUNNER) -printf 'unlinked %f\n' -delete

# Shell into IMAGE container, like make sh IMAGE=node
sh:
	$(if $(IMAGE),,$(error Set IMAGE to one of: $(IMAGES)))
	TOOLS_IMAGE=$(IMAGE) scripts/run.sh sh
