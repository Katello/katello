#!/bin/bash

pulp-admin auth login --username admin --password admin
pulp-admin repo create --id zoo2
pulp-admin content upload -r zoo2 --nosig -v *rpm
touch empty.iso
pulp-admin content upload -r zoo2 --nosig -v empty.iso
pulp-admin packagegroup create --id=mammal -r zoo2 -n mammal
pulp-admin packagegroup add_package --id=mammal -r zoo2 -n elephant,giraffe,cheetah,lion,monkey,penguin,squirrel,walrus -t mandatory
pulp-admin packagegroup create --id=bird -r zoo2 -n bird
pulp-admin packagegroup add_package --id=bird -r zoo2 -n penguin -t mandatory
pulp-admin packagegroup create_category --categoryid=all -r zoo2 -n all
pulp-admin packagegroup add_group --id=mammal --categoryid=all -r zoo2
pulp-admin packagegroup add_group --id=bird --categoryid=all -r zoo2
pulp-admin errata create --id RHEA-2010:0001 --title "Empty errata" --version 1 --release 1 --type security --issued "2010-01-01 01:01:01" --status stable --fromstr "lzap+pub@redhat.com"
echo "elephant,0.3,0.8,0,noarch,elephant-0.3-0.8.noarch.rpm,b029ffa74171d1f60d58ad25a4822db2,md5,http://www.fedoraproject.org" > /tmp/erratum.csv
pulp-admin errata create --id RHEA-2010:0002 --title "One package errata" --version 1 --release 1 --type security --issued "2010-01-01 01:01:01" --status stable --fromstr "lzap+pub@redhat.com" --effected-packages /tmp/erratum.csv
pulp-admin repo add_errata --id zoo2 -e RHEA-2010:0001 -y
pulp-admin repo add_errata --id zoo2 -e RHEA-2010:0002 -y
pulp-admin repo generate_metadata --id zoo2
