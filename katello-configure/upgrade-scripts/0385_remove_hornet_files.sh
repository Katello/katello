#!/bin/bash

#name: Remove hornetq files
#apply: katello headpin
#run: always
#description:
#Certain Candlepin versions can contain several directories with journal
#data of hornetq daemon which needs to be removed.

rm -rf /var/lib/candlepin/hornetq/bindings
rm -rf /var/lib/candlepin/hornetq/journal
rm -rf /var/lib/candlepin/hornetq/largemsgs
