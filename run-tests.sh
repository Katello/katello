#!/bin/bash
cd src
rake db:migrate:reset --trace 
rake yard hudson:spec SPEC_OPTS="-p" --trace
