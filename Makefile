prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/x86_64-apple-macosx/release/hoard" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/hoard"

clean:
	rm -rf .build