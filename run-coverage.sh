#!/bin/bash
cd src
sudo bundle install
rake db:migrate:reset --trace 
rake rcov SPEC_OPTS="-p" --trace
