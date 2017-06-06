#!/bin/bash

curl -u admin:admin -d "`cat fproducts.json`" -H "Accept: application/json" -H "content-type: application/json"  -X POST http://localhost:3000/api/providers/$1/import_products/
