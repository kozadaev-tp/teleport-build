# --- Configuration Variables ---
# Make sure we're building/using the enterprise versions of the Teleport.
TELEPORT_E_SRC_DIR  ?= $(HOME)/projects/core.git/e
TELEPORT_SRC_DIR    ?= $(HOME)/projects/core.git
BUILD_DIR           ?= builds

# Binaries built by Teleport's native build system
TELEPORT_BIN       = $(TELEPORT_E_SRC_DIR)/build/teleport
TCTL_BIN           = $(TELEPORT_E_SRC_DIR)/build/tctl
TSH_BIN            = $(TELEPORT_E_SRC_DIR)/build/tsh
TBOT_BIN           = $(TELEPORT_SRC_DIR)/build/bot


.PHONY: all
all: build

.PHONY: targets
targets:
	@awk -F: '/^[^ \.]*:/ { print $$1 }' Makefile


.PHONY: build
build: build/osx/binaries

.PHONY: build/linux
build/linux: PLATFORM=linux
build/linux: build/linux/binaries

.PHONY: build/osx
build/osx: PLATFORM=osx
build/osx: build/osx/binaries

.PHONY: build/osx/binaries
build/osx/binaries: build/osx/teleport build/osx/tctl build/osx/tsh

.PHONY: build/linux/binaries
build/linux/binaries: build/linux/teleport build/linux/tctl build/linux/tsh

.PHONY: dirs
dirs:
	mkdir -p ${BUILD_DIR}/${PLATFORM}

.PHONY: build/osx/teleport
build/osx/teleport: dirs
	@echo "=== Compiling Teleport binaries ==="
	mkdir -p ${BUILD_DIR}/osx/ && \
	cd $(TELEPORT_E_SRC_DIR) && \
	$(MAKE) build/teleport build/tsh build/tctl && \
	cd - && cp -f ${TELEPORT_BIN} ./${BUILD_DIR}/osx

.PHONY: build/osx/tctl
build/osx/tctl: dirs
	@echo "=== Compiling tctl binaries ==="
	mkdir -p ${BUILD_DIR}/osx/ && \
	cd $(TELEPORT_E_SRC_DIR) && \
	$(MAKE) build/teleport build/tsh build/tctl && \
	cd - && cp -f ${TCTL_BIN} ./${BUILD_DIR}/osx

.PHONY: build/osx/tsh
build/osx/tsh: dirs
	@echo "=== Compiling tsh binaries ==="
	mkdir -p ${BUILD_DIR}/osx/ && \
	cd $(TELEPORT_E_SRC_DIR) && \
	$(MAKE) build/teleport build/tsh build/tctl && \
	cd - && cp -f ${TSH_BIN} ./${BUILD_DIR}/osx

.PHONY: build/osx/tbot
build/osx/tbot: build/osx/teleport build/osx/tctl build/osx/tsh
	@echo "=== Compiling Teleport tbot binary ==="
	mkdir -p ${BUILD_DIR}/osx/ && \
	cd $(TELEPORT_SRC_DIR) && \
	$(MAKE) build/tbot
	cd - && cp -f ${TBOT_BIN} ./${BUILD_DIR}/osx

.PHONY: build/linux/tbot
build/linux/teleport:
	@echo "=== Compiling Teleport Binary for Linux ==="
	mkdir -p ${BUILD_DIR}/linux && \
	cd $(TELEPORT_E_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -tags "grpcnotrace webassets_embed webassets_ent" -o build/teleport -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/teleport && \
	cd - && cp -f ${TELEPORT_BIN} ./${BUILD_DIR}/linux

.PHONY: build/linux/tctl
build/linux/tctl:
	@echo "=== Compiling tctl binary for Linux ==="
	mkdir -p ${BUILD_DIR}/linux && \
	cd $(TELEPORT_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -tags "webassets_embed webassets_ent" -o build/tctl -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/tctl && \
	cd - && cp -f ${TCTL_BIN} ./${BUILD_DIR}/linux

.PHONY: build/linux/tsh
build/linux/tsh:
	@echo "=== Compiling tsh binary for Linux ==="
	mkdir -p ${BUILD_DIR}/linux && \
	cd $(TELEPORT_E_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -tags "webassets_embed webassets_ent" -o build/tsh -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/tsh && \
	cd - && cp -f ${TSH_BIN} ./${BUILD_DIR}/linux

.PHONY: build/linux/tbot
build/linux/tbot: dirs
	@echo "=== Compiling tbot binary for Linux ==="
	mkdir -p ${BUILD_DIR}/linux && \
	cd $(TELEPORT_SRC_DIR) && \
	CC=/opt/homebrew/bin/x86_64-unknown-linux-gnu-gcc GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
		go build -buildvcs=false -o build/bot -ldflags '-w -s  -X k8s.io/component-base/version.gitVersion=v1.34.0' -trimpath -buildmode=pie ./tool/tbot && \
	cd - && cp -f ${TBOT_BIN} ./${BUILD_DIR}/linux/

.PHONY: serve
serve:
	python3 -m http.server 8080
