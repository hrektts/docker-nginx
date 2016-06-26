all: build

build:
	@docker build -t hrektts/nginx:latest .

release: build
	@docker build -t hrektts/nginx:$(shell cat VERSION) .

.PHONY: test
test:
	@docker build -t hrektts/nginx:bats .
	bats test
