#!/bin/bash

echo ""
echo "********* JavaScript Jasmine Tests against PhantomJS and Firefox  ****************"
cd engines/bastion

sudo apt-get install python-software-properties python g++ make
sudo yes | sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs

export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

npm install -g bower grunt-cli
npm install
bower install --dev
grunt ci
