VERSIONS := $(shell find . -name Dockerfile -exec dirname {} \;)
.PHONY: all update test

all: update test

update:
	./update.rb

test:
	./test.rb
