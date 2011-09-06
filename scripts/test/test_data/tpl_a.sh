#!/bin/bash
if [ $1 = "-i" ]; then
    echo "(requires data set \"a\")"
    echo "template test data for ACME_Corporation, 1 template with 2 products"
    return
fi


$CMD template create --name="tpl_a1" --description="template in ACME_Corporation in a locker" --org="ACME_Corporation"
$CMD template update_content --name="tpl_a1" --org="ACME_Corporation" --add_product --product="prod_a1"
$CMD template update_content --name="tpl_a1" --org="ACME_Corporation" --add_product --product="prod_a2"



