

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
    "name": "Library",
    "prior": None,
    "created_at": "2011-08-23T08:10:53Z",
    "library": True,
    "updated_at": "2011-08-23T08:10:53Z",
    "id": 1,
    "organization": "ACME_Corporation",
    "description": None,
    "organization_id": 1
  },
  {
    "name": "Dev",
    "prior": "Library",
    "created_at": "2011-08-24T08:25:52Z",
    "library": False,
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
    "library": False,
    "updated_at": "2011-08-24T08:26:01Z",
    "id": 3,
    "organization": "ACME_Corporation",
    "description": None,
    "organization_id": 1
  }
]

LIBRARY = ENVS[0]



POOL = {
  "href": "/pools/40288ae9333fe87201334033dd21001b",
  "sourceEntitlement": None,
  "productId": "1319632099512",
  "accountNumber": "",
  "quantity": -1,
  "restrictedToUsername": None,
  "attributes": [

  ],
  "subscriptionId": "40288ae9333fe87201334033da7e001a",
  "startDate": "2011-10-26T00:00:00.000+0000",
  "id": "40288ae9333fe87201334033dd21001b",
  "productAttributes": [

  ],
  "productName": "first",
  "activeSubscription": True,
  "updated": "2011-10-26T12:28:20.641+0000",
  "contractNumber": "",
  "endDate": "2041-10-18T00:00:00.000+0000",
  "providedProducts": [

  ],
  "created": "2011-10-26T12:28:20.641+0000",
  "consumed": 0,
  "owner": {
    "href": "/owners/ACME_Corporation",
    "displayName": "ACME_Corporation",
    "id": "40288ae9333fe87201333fe956790018",
    "key": "ACME_Corporation"
  }
}
