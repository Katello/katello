
SYSTEM_GROUPS = [
    {
        "description" : "This is my first system group.",
        "updated_at" : "2012-04-26T19:59:46Z",
        "pulp_id" : "ACME_Corporation-Test System Group 1-0cdaf879",
        "locked" : False,
        "created_at" : "2012-04-26T19:59:23Z",
        "name" : "Test System Group 1",
        "id" : 1,
        "organization_id" : 1
    },
    {
        "description" : "This is another system group.",
        "updated_at" : "2012-04-26T19:59:46Z",
        "pulp_id" : "ACME_Corporation-Test System Group 3-0adcf897",
        "locked" : False,
        "created_at" : "2012-04-27T19:59:23Z",
        "name" : "Test System Group 2",
        "id" : 2,
        "organization_id" : 1
    }
]

SYSTEM_GROUP_HISTORY = [
  {
    "task_type": "package_install",
    "created_at": "2012-05-22T20:04:15Z",
    "parameters": {
      "packages": [
        "foo"
      ]
    },
    "tasks": [
      {
        "result": {
          "errors": [
            "('c8574ddd-b2f8-41f9-b47a-cedeb3c670ad', 0)",
            "RequestTimeout('c8574ddd-b2f8-41f9-b47a-cedeb3c670ad', 0)"
          ]
        },
        "uuid": "4e2f2dde-a449-11e1-9dbe-0019b90d1d4e",
        "progress": None,
        "id": 4,
        "finish_time": "2012-05-22T20:04:25Z",
        "state": "error",
        "start_time": "2012-05-22T20:04:14Z"
      }
    ],
    "id": 1
  }
]

SYSTEMS = [
  {
    "guests": [

    ],
    "created_at": "2012-04-26T20:00:38Z",
    "serviceLevel": "",
    "name": "FakeSystem345",
    "description": "Initial Registration Params",
    "location": "None",
    "updated_at": "2012-04-26T20:00:38Z",
    "id": 1,
    "environment": {
      "created_at": "2012-04-20T14:01:22Z",
      "name": "Dev",
      "description": "",
      "updated_at": "2012-04-20T14:01:22Z",
      "prior_id": 1,
      "organization": "ACME_Corporation",
      "id": 5,
      "library": False,
      "organization_id": 1,
      "prior": "Library"
    },
    "uuid": "d49f6d91-0bb3-43f0-9881-dc051fa818c7",
    "activation_key": [

    ],
    "environment_id": 5,
    "system_template_id": None
  },
  {
    "guests": [
    ],
    "created_at": "2012-04-30T19:05:14Z",
    "serviceLevel": "",
    "name": "Winterfell",
    "description": "Initial Registration Params",
    "location": "None",
    "updated_at": "2012-04-30T19:05:14Z",
    "id": 2,
    "environment": {
      "created_at": "2012-04-20T14:01:22Z",
      "name": "Dev",
      "description": "",
      "updated_at": "2012-04-20T14:01:22Z",
      "prior_id": 1,
      "organization": "ACME_Corporation",
      "id": 5,
      "library": False,
      "organization_id": 1,
      "prior": "Library"
    },
    "uuid": "92eb02a6-0d33-4f89-885c-55aebedaf0e1",
    "activation_key": [

    ],
    "environment_id": 5,
    "system_template_id": None
  }
]