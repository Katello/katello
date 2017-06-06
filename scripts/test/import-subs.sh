#!/bin/sh
echo "Importing subscripts...please wait"
TEST=$(pwd)
pushd . 
cd ../../src/
rails runner $TEST/import-subs.rb
popd 
