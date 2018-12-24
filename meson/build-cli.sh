#!/bin/bash

exec_name=writeas

echo "Building $exec_name CLI..."
gb build github.com/writeas/writeas-cli/cmd/writeas
echo "Success."
