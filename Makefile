VERSIONS := $(shell find . -name Dockerfile -exec dirname {} \;)
.PHONY: all update test

all: update test

update:
	./update.rb

# ensures that all generated files are up to date in CI
validate: update
	git status
	test -z "$$(git status --porcelain)"

test:
	./test.rb
