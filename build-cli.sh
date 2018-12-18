#!/bin/bash

exec_name=writeas

gb build github.com/writeas/writeas-cli/cmd/writeas
mv bin/$exec_name data/$exec_name
