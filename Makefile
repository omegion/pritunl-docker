ARCH 	= arm64v8
VERSION = 1.29.2664.67

.PHONY: build
build:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		-t omegion/pritunl:$(VERSION) \
		--push .

.PHONY: start
start:
	docker pull ghcr.io/omegion/pritunl:latest
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose down

.PHONY: cut-tag
cut-tag:
	@echo "Cutting $(version)"
	git tag $(version)
	git push origin $(version)
