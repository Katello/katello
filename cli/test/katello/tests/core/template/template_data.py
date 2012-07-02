



TEMPLATES = [
{
  "name": "tpl_a1",
  "repositories": [
    {
      "name": "zoo",
      "created_at": "2012-01-16T21:31:17Z",
      "updated_at": "2012-01-16T21:31:17Z",
      "environment_product_id": 1,
      "major": None,
      "id": 1,
      "enabled": True,
      "pulp_id": "ACME_Corporation-zoo-zoo",
      "gpg_key_id": None,
      "minor": None
    },
    {
      "name": "up_zoo",
      "created_at": "2012-01-16T21:31:26Z",
      "updated_at": "2012-01-16T21:31:26Z",
      "environment_product_id": 1,
      "major": None,
      "id": 2,
      "enabled": True,
      "pulp_id": "ACME_Corporation-zoo-up_zoo",
      "gpg_key_id": None,
      "minor": None
    }
  ],
  "products": [
    {
      "productContent": [

      ],
      "name": "prod_a1",
      "multiplier": 1,
      "created_at": "2011-09-06T11:43:43Z",
      "product_id": 1,
      "provider_id": 3,
      "sync_state": "finished",
      "attributes": [

      ],
      "multiplier": 1,
      "updated_at": "2011-09-06T11:43:43Z",
      "sync_plan_id": 25,
      "last_sync": "2011-09-06T13:44:16+02:00",
      "id": 1,
      "system_template_id": 2,
      "description": None,
      "id": "1315309422793"
    },
    {
      "productContent": [

      ],
      "name": "prod_a2",
      "multiplier": 1,
      "created_at": "2011-09-06T11:43:54Z",
      "product_id": 2,
      "provider_id": 3,
      "sync_state": "finished",
      "attributes": [

      ],
      "multiplier": 1,
      "updated_at": "2011-09-06T11:43:54Z",
      "sync_plan_id": 25,
      "last_sync": "2011-09-06T13:44:33+02:00",
      "id": 2,
      "system_template_id": 2,
      "description": None,
      "id": "1315309434001"
    }
  ],
  "package_groups":
    [{"id":1,
      "system_template_id":1,
      "repo_id":"1316523009485-base-one-ACME_Corporation",
      "package_group_id":"test"}],
   "pg_categories":
    [{"pg_category_id":"test",
      "id":1,
      "system_template_id":1,
      "repo_id":"1316523009485-base-one-ACME_Corporation"}],
  "created_at": "2011-09-06T11:47:44Z",
  "updated_at": "2011-09-06T11:51:07Z",
  "packages": [
    {
      "system_template_id": 2,
      "id": 1,
      "package_name": "walrus",
      "version": "0.1",
      "release": "0.2",
      "epoch": "1",
      "arch": "noarch"
    },
    {
      "system_template_id": 2,
      "id": 2,
      "package_name": "cheetah",
      "version": None,
      "release": None,
      "epoch": None,
      "arch": None
    }
  ],
  "id": 2,
  "revision": 2,
  "parent_id": None,
  "environment_id": 1,
  "description": "template in ACME_Corporation in a library",
  "parameters_json": "{\"param_1\":\"param_value\"}",
  "parameters": {
    "param_1": "param_value"
  },
  "package_groups": [],
  "pg_categories": [],
}
]