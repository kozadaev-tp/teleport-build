# --- Configuration Variables ---
# Make sure we're building/using the enterprise versions of the Teleport.
TELEPORT_E_SRC_DIR  ?= $(HOME)/projects/teleport.git/e
TELEPORT_SRC_DIR  ?= $(HOME)/projects/teleport.git
BUILD_DIR         ?= builds

# Binaries built by Teleport's native build system
TELEPORT_BIN       = $(TELEPORT_E_SRC_DIR)/build/teleport
TCTL_BIN           = $(TELEPORT_SRC_DIR)/build/tctl
TSH_BIN            = $(TELEPORT_SRC_DIR)/build/tsh

.PHONY: all build init config bootstrap run stop clean restart

all: build

.PHONY: targets
targets:
	@awk -F: '/^[^ \.]*:/ { print $$1 }' Makefile

dirs:
	mkdir -p ${BUILD_DIR}

build-binaries: dirs
	@echo "=== Compiling Teleport Binaries ==="
	cd $(TELEPORT_SRC_DIR) && \
	$(MAKE) build/teleport build/tctl build/tsh

build-linux-binaries:
	# build teleport, tctl and teleport-update
	cd $(TELEPORT_E_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -tags "webassets_embed webassets" -o build/teleport -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/teleport
	cd $(TELEPORT_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -tags "webassets_embed webassets" -o build/tctl -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/tctl && \
		go build -buildvcs=false -tags "webassets_embed webassets" -o build/tsh -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/tsh

copy-binaries:
	cp ${TELEPORT_BIN} ./builds
	cp ${TSH_BIN} ./builds
	cp ${TCTL_BIN} ./builds

build: build-binaries copy-binaries

build-linux: build-linux-binaries copy-binaries

serve:
	python3 -m http.server 8080
