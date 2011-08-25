try:
    import json
except ImportError:
    import simplejson as json 


ORGS = [
  {
    "name": "ACME_Corporation",
    "created_at": "2011-08-23T08:10:52Z",
    "updated_at": "2011-08-23T08:10:52Z",
    "id": 1,
    "cp_key": "ACME_Corporation",
    "description": "ACME Corporation Organization"
  }
]

ENVS = [
  {
    "name": "Locker",
    "prior": None,
    "created_at": "2011-08-23T08:10:53Z",
    "locker": True,
    "updated_at": "2011-08-23T08:10:53Z",
    "id": 1,
    "organization": "ACME_Corporation",
    "description": None,
    "organization_id": 1
  },
  {
    "name": "Dev",
    "prior": "Locker",
    "created_at": "2011-08-24T08:25:52Z",
    "locker": False,
    "updated_at": "2011-08-24T08:25:52Z",
    "id": 2,
    "organization": "ACME_Corporation",
    "description": None,
    "organization_id": 1
  },
  {
    "name": "Prod",
    "prior": "Dev",
    "created_at": "2011-08-24T08:26:01Z",
    "locker": False,
    "updated_at": "2011-08-24T08:26:01Z",
    "id": 3,
    "organization": "ACME_Corporation",
    "description": None,
    "organization_id": 1
  }
]

PROVIDERS = [
  {
    "name": "porkchop",
    "created_at": "2011-08-23T08:10:53Z",
    "updated_at": "2011-08-23T08:10:53Z",
    "id": 1,
    "repository_url": "http://download.fedoraproject.org/pub/fedora/linux/releases/",
    "description": None,
    "organization_id": 1,
    "provider_type": "Custom"
  },
  {
    "name": "redhat",
    "created_at": "2011-08-23T08:10:53Z",
    "updated_at": "2011-08-23T08:10:53Z",
    "id": 2,
    "repository_url": "https://somehost.example.com/content/",
    "description": None,
    "organization_id": 1,
    "provider_type": "Red Hat"
  },
  {
    "name": "prov_a1",
    "created_at": "2011-08-25T11:50:55Z",
    "updated_at": "2011-08-25T11:50:55Z",
    "id": 3,
    "repository_url": None,
    "description": None,
    "organization_id": 1,
    "provider_type": "Custom"
  },
  {
    "name": "prov_a2",
    "created_at": "2011-08-25T11:50:56Z",
    "updated_at": "2011-08-25T11:50:56Z",
    "id": 4,
    "repository_url": None,
    "description": None,
    "organization_id": 1,
    "provider_type": "Custom"
  }
]


PRODUCTS = [
  {
    "last_sync": None,
    "name": "prod_a1",
    "created_at": "2011-08-25T11:50:59Z",
    "productContent": [
      {
        "enabled": False,
        "content": {
          "label": "1314273058712_prod_a1_dummy_repos_zoo",
          "name": "prod_a1_dummy_repos_zoo",
          "contentUrl": "http://tstrachota.fedorapeople.org/dummy_repos/zoo",
          "id": "1314273063319",
          "type": "yum",
          "gpgUrl": "",
          "vendor": "Custom",
          "modifiedProductIds": [

          ],
          "updated": "2011-08-25T11:51:03.319+0000",
          "created": "2011-08-25T11:51:03.319+0000"
        }
      }
    ],
    "provider_id": 3,
    "multiplier": 1,
    "attributes": [

    ],
    "multiplier": 1,
    "updated_at": "2011-08-25T11:50:59Z",
    "sync_plan_id": 25,
    "id": 1,
    "provider_name": "prov_a1",
    "description": None,
    "sync_state": "not_synced",
    "id": "1314273058712"
  },
  {
    "last_sync": None,
    "name": "prod_a2",
    "created_at": "2011-08-25T11:51:06Z",
    "productContent": [
      {
        "enabled": False,
        "content": {
          "label": "1314273066523_prod_a2_fakerepos_fewupdates",
          "name": "prod_a2_fakerepos_fewupdates",
          "contentUrl": "http://lzap.fedorapeople.org/fakerepos/fewupdates",
          "id": "1314273077303",
          "type": "yum",
          "gpgUrl": "",
          "vendor": "Custom",
          "modifiedProductIds": [

          ],
          "updated": "2011-08-25T11:51:17.304+0000",
          "created": "2011-08-25T11:51:17.304+0000"
        }
      },
      {
        "enabled": False,
        "content": {
          "label": "1314273066523_prod_a2_fakerepos_zoo",
          "name": "prod_a2_fakerepos_zoo",
          "contentUrl": "http://lzap.fedorapeople.org/fakerepos/zoo",
          "id": "1314273074824",
          "type": "yum",
          "gpgUrl": "",
          "vendor": "Custom",
          "modifiedProductIds": [

          ],
          "updated": "2011-08-25T11:51:14.824+0000",
          "created": "2011-08-25T11:51:14.824+0000"
        }
      }
    ],
    "provider_id": 3,
    "multiplier": 1,
    "attributes": [

    ],
    "multiplier": 1,
    "updated_at": "2011-08-25T11:51:06Z",
    "sync_plan_id": 25,
    "id": 2,
    "provider_name": "prov_a1",
    "description": None,
    "sync_state": "not_synced",
    "id": "1314273066523"
  }
]


SYNC_RESULT_WITHOUT_ERROR = [
    {
        'state': 'finished'
    }
]

SYNC_RESULT_WITH_ERROR = [
    {
        'state': 'error', 
        'result': json.dumps({'errors':["some error"]})
    }
]




