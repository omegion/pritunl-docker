ARCH 	= arm64v8
VERSION = 1.29.2664.67

build:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		-t omegion/pritunl:$(VERSION) \
		--push .

start:
	docker-compose up -d