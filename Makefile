all: greitspitz

lib:
	shards

spec: lib main.cr src/**/*.cr
	crystal spec

greitspitz: lib main.cr src/**/*.cr
	crystal build --error-trace -o greitspitz main.cr
	@strip greitspitz
	@du -sh greitspitz

release: lib main.cr src/**/*.cr
	crystal build --release -o greitspitz main.cr
	@strip greitspitz
	@du -sh greitspitz

clean:
	rm -rf .crystal greitspitz .deps .shards libs lib *.dwarf build

PREFIX ?= /usr/local

install: release
	install -d $(PREFIX)/bin
	install greitspitz $(PREFIX)/bin
