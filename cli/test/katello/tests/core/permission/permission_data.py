


AVAILABLE_PERMISSIONS = {
  "environments": {
    "name": "Environments",
    "verbs": [
      {
        "name": "read_changesets",
        "display_name": "Access Changesets in Environment"
      },
      {
        "name": "read_contents",
        "display_name": "Access Environment Contents"
      },
      {
        "name": "read_systems",
        "display_name": "Access Systems in Environment"
      }
    ],
    "tags": [

    ],
    "global": False
  },
  "organizations": {
    "name": "Organizations",
    "verbs": [
      {
        "name": "read",
        "display_name": "Access Organization"
      },
      {
        "name": "read_systems",
        "display_name": "Access Systems"
      },
      {
        "name": "delete_systems",
        "display_name": "Delete Systems"
      }
    ],
    "tags": [

    ],
    "global": False
  },
  "all": {
    "name": "All",
    "verbs": [

    ],
    "tags": [

    ],
    "global": False
  }
}


PERMISSIONS = [
  {
    "name": "test_environment_permission",
    "resource_type": {
      "name": "environments",
      "created_at": "2011-12-21T10:39:58Z",
      "updated_at": "2011-12-21T10:39:58Z",
      "id": 4
    },
    "tags": [
      {
        "created_at": "2011-12-22T09:58:54Z",
        "tag_id": 1,
        "permission_id": 15,
        "updated_at": "2011-12-22T09:58:54Z",
        "id": 12,
        "formatted": {
          "name": 1,
          "display_name": "Library"
        }
      },
      {
        "created_at": "2011-12-22T09:58:54Z",
        "tag_id": 1,
        "permission_id": 15,
        "updated_at": "2011-12-22T09:58:54Z",
        "id": 13,
        "formatted": {
          "name": 1,
          "display_name": "Library"
        }
      }
    ],
    "created_at": "2011-12-22T09:58:54Z",
    "all_verbs": False,
    "updated_at": "2011-12-22T09:58:54Z",
    "role_id": 1,
    "all_tags": False,
    "id": 15,
    "verbs": [
      {
        "verb": "register_systems",
        "created_at": "2011-12-22T09:57:50Z",
        "permission_id": "15",
        "updated_at": "2011-12-22T09:57:50Z",
        "id": 5,
        "verb_id": "5"
      }
    ],
    "description": None,
    "resource_type_id": 4,
    "organization_id": 1
  }
]
