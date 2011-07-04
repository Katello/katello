#!/bin/bash
cd src
sudo bundle install
rake db:migrate:reset --trace 
rake yard hudson:spec SPEC_OPTS="-p" --trace
