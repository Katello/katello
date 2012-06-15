


REPOS = [
    {
    "package_count": 0,
    "name": "prod_a2_fakerepos_zoo",
    "clone_ids": [

    ],
    "keys": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/keys/",
    "uri_ref": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/",
    "use_symlinks": False,
    "content_types": "yum",
    "packagegroupcategories": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/packagegroupcategories/",
    "consumer_cert": None,
    "errata": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/errata/",
    "files": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/files/",
    "notes": None,
    "relative_path": "fakerepos/zoo",
    "arch": "noarch",
    "checksum_type": "sha256",
    "_id": "1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation",
    "packages": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/packages/",
    "next_scheduled_time": None,
    "sync_state": "not_synced",
    "id": "1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation",
    "publish": True,
    "last_sync": None,
    "comps": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/comps/",
    "filters": [

    ],
    "sync_schedule": None,
    "files_count": 82,
    "groupid": [
        "product:1314606161997",
        "env:1",
        "org:1"
    ],
    "packagegroups": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/packagegroups/",
    "distribution": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_zoo-ACME_Corporation/distribution/",
    "distributionid": [

    ],
    "consumer_ca": None,
    "source": {
        "url": "http://lzap.fedorapeople.org/fakerepos/zoo",
        "type": "remote"
    },
    "feed_cert": None,
    "feed_ca": None
    },
    {
    "package_count": 0,
    "name": "prod_a2_fakerepos_fewupdates",
    "clone_ids": [

    ],
    "keys": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/keys/",
    "uri_ref": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/",
    "use_symlinks": False,
    "content_types": "yum",
    "packagegroupcategories": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/packagegroupcategories/",
    "consumer_cert": None,
    "errata": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/errata/",
    "files": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/files/",
    "notes": None,
    "relative_path": "fakerepos/fewupdates",
    "arch": "noarch",
    "checksum_type": "sha256",
    "_id": "1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation",
    "packages": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/packages/",
    "next_scheduled_time": None,
    "sync_state": "not_synced",
    "id": "1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation",
    "publish": True,
    "last_sync": None,
    "comps": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/comps/",
    "filters": [

    ],
    "sync_schedule": None,
    "files_count": 89,
    "groupid": [
        "product:1314606161997",
        "env:1",
        "org:1"
    ],
    "packagegroups": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/packagegroups/",
    "distribution": "/pulp/api/repositories/1314606161997-prod_a2_fakerepos_fewupdates-ACME_Corporation/distribution/",
    "distributionid": [

    ],
    "consumer_ca": None,
    "source": {
        "url": "http://lzap.fedorapeople.org/fakerepos/fewupdates",
        "type": "remote"
    },
    "feed_cert": None,
    "feed_ca": None
    }
]



SYNC_RESULT_WITHOUT_ERROR = [
  {
    "result": {"errors":[None,None]},
    "created_at": None,
    "uuid": "6d3d8711-cf28-11e0-b10e-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 0,
      "total_size": 17872,
      "total_count": 8,
      "items_left": 0
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "finished",
    "start_time": "2011-08-25T14:42:16Z"
  },
  {
    "result": "{\"errors\":[null,null]}",
    "created_at": None,
    "uuid": "6d523975-cf28-11e0-b196-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 0,
      "total_size": 3170837,
      "total_count": 7,
      "items_left": 0
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "finished",
    "start_time": "2011-08-25T14:42:16Z"
  }
]

SYNC_RESULT_WITH_ERROR = [
  {
    "result": {"errors": ["some error 1","some error 2"]},
    "created_at": None,
    "uuid": "6d3d8711-cf28-11e0-b10e-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 17872,
      "total_size": 17872,
      "total_count": 8,
      "items_left": 8
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "error",
    "start_time": "2011-08-25T14:42:16Z"
  },
  {
    "result": {"errors":[None,None]},
    "created_at": None,
    "uuid": "6d523975-cf28-11e0-b196-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 3170837,
      "total_size": 3170837,
      "total_count": 7,
      "items_left": 7
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "canceled",
    "start_time": "2011-08-25T14:42:16Z"
  }
]

SYNC_RESULT_CANCELLED = [
  {
    "result": {"errors":[None,None]},
    "created_at": None,
    "uuid": "6d3d8711-cf28-11e0-b10e-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 17872,
      "total_size": 17872,
      "total_count": 8,
      "items_left": 8
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "canceled",
    "start_time": "2011-08-25T14:42:16Z"
  },
  {
    "result": {"errors":[None,None]},
    "created_at": None,
    "uuid": "6d523975-cf28-11e0-b196-f0def13c24e5",
    "updated_at": None,
    "progress": {
      "error_details": [

      ],
      "size_left": 3170837,
      "total_size": 3170837,
      "total_count": 7,
      "items_left": 7
    },
    "finish_time": "2011-08-25T14:42:21Z",
    "organization_id": None,
    "state": "canceled",
    "start_time": "2011-08-25T14:42:16Z"
  }
]


SYNC_RUNNING_RESULT = [
  {
    "result": {"errors":[None,None]},
    "created_at": "2011-08-25T14:44:17Z",
    "uuid": "b57a9d75-cf28-11e0-8a7a-f0def13c24e5",
    "updated_at": "2011-08-25T14:44:17Z",
    "progress": {
      "error_details": [

      ],
      "size_left": 9883,
      "total_size": 17872,
      "total_count": 8,
      "items_left": 5
    },
    "id": 3,
    "finish_time": None,
    "organization_id": 1,
    "state": "running",
    "start_time": None
  },
  {
    "result": {"errors":[None,None]},
    "created_at": "2011-08-25T14:44:17Z",
    "uuid": "b58a9635-cf28-11e0-8ae3-f0def13c24e5",
    "updated_at": "2011-08-25T14:44:17Z",
    "progress": {
      "error_details": [

      ],
      "size_left": 0,
      "total_size": 0,
      "total_count": 0,
      "items_left": 0
    },
    "id": 4,
    "finish_time": None,
    "organization_id": 1,
    "state": "waiting",
    "start_time": None
  }
]