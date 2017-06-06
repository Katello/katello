#!/bin/bash
sudo apt-get install libssl-dev python m2crypto --quiet
sudo pip install -r cli/requirements-dev.pip
cd cli/

echo ""
echo "********* Python CLI Unit Tests ***************"
echo "RUNNING: make test"
make test || exit 1

echo ""
echo "********* Running Pylint ************************"
echo "RUNNING: PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello"
PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello || exit 1

