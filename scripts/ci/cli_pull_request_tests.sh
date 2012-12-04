#!/bin/bash

echo ""
echo "********* Python CLI Unit Tests ***************"
cd cli/
echo "RUNNING: make test"
make test
if [ $? -ne 0 ]
then
  exit 1
fi

echo ""
echo "********* Running Pylint ************************"
echo "RUNNING: PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello"
PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello
if [ $? -ne 0 ]
then
  exit 1
fi

cd ../
