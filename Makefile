.PHONY: build test lint docker-up docker-down docker-build run

GOARCH ?= $(shell go env GOARCH)

build:
	go build ./...

test:
	go test ./...

lint:
	golangci-lint run

docker-up:
	podman-compose up -d

docker-down:
	podman-compose down

# Build a single-arch image for local use that matches the CI layout. The
# Dockerfile expects a binary at dist/linux-<arch>/arcade; this target produces
# that layout for the host's architecture and tags the image arcade:local.
docker-build:
	mkdir -p dist/linux-$(GOARCH)
	CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) go build -trimpath -ldflags="-s -w" -o dist/linux-$(GOARCH)/arcade ./cmd/arcade
	docker build --platform=linux/$(GOARCH) -t arcade:local .

run:
	go run ./cmd/arcade
