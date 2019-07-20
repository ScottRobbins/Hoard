#!/bin/bash

swift build -c release
cd .build/x86_64-apple-macosx/release
cp -f hoard /usr/local/bin/hoard
