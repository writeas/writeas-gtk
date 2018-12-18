#!/bin/bash

exec_name=writeas

echo "Building $exec_name CLI..."
gb build github.com/writeas/writeas-cli/cmd/writeas
echo "mv bin/$exec_name data/$exec_name"
mv bin/$exec_name data/$exec_name
