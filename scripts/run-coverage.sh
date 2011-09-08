#!/bin/bash
sudo bundle install
RAILS_ENV=test rake db:migrate:reset --trace 
RAILS_ENV=test rake rcov SPEC_OPTS="-p" --trace
