#!/bin/bash
cd src
rake db:migrate:reset --trace 
# Temp comment out while I figure out why we cant generate proper output
# rake yard hudson:spec SPEC_OPTS="-p" --trace
rake yard spec
