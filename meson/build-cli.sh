#!/bin/bash

exec_name=writeas

echo "Building $exec_name CLI..."
cd $1 &&
gb build github.com/writeas/writeas-cli/cmd/writeas &&
mv bin/writeas $3/$2 &&
# Cleanup
rm -rf bin/ &&
rm -rf pkg/ &&
echo "Success."
