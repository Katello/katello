#!/bin/sh
TEST=$PWD
pushd .
cd ../../src
bundle exec rails runner $TEST/fake-systems.rb
popd
