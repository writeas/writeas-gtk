#!/bin/bash

exec_name=writeas
BIN_DIR="$MESON_BUILD_ROOT"/bin

echo "Building $exec_name CLI..."
# go get to fetch dependencies
go get github.com/writeas/writeas-cli/cmd/writeas &&
cd "$MESON_SOURCE_ROOT"/src/github.com/writeas/writeas-cli/cmd/writeas &&
mkdir -p "$BIN_DIR" &&
go build -o "$BIN_DIR"/writeas &&
echo "Success."
