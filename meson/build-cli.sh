#!/bin/bash

exec_name=writeas

echo "Building $exec_name CLI..."
cd $1/src/github.com/writeas/writeas-cli/ && echo "$PWD"&&
go build --mod=vendor -o bin/writeas ./cmd/writeas &&
mv bin/writeas $3/$2 &&
# Cleanup
rm -rf bin/ &&
rm -rf pkg/ &&
echo "Success."
