#!/bin/sh
TEST=$PWD
pushd .
cd ../../src
rails runner $TEST/fake-systems.rb
popd
