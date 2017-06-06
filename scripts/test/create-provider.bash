#!/bin/bash

curl -s -u admin:admin -d "`cat provider.json`" -H "Content-type: application/json" -X POST http://localhost:3000/api/organizations/admin/providers/ > /dev/null
echo ""
curl -s -u admin:admin http://localhost:3000/api/organizations/admin/providers/ |prettify_json.rb |grep \"id\" 
echo ""
echo "Copy-paste the id from the above to ./import-products.bash <id>" 
