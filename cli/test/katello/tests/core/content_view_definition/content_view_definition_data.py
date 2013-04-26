
VIEWS = [
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 1,
            "description": "Database content view",
            "label": "Database_Content_View",
            "name": "Database Content View",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 2,
            "description": "RHEL content view",
            "label": "my_rhel_cv",
            "name": "My RHEL Content View",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 3,
            "description": "Fedora 16 content",
            "label": "fedora16",
            "name": "Fedora",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 4,
            "description": "fedora 17 content",
            "label": "my_rhel_cv",
            "name": "My RHEL Content View",
            "organization_id": 1
            },
        ]

DEFS =  [
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 1,
            "description": "Database",
            "label": "Database",
            "name": "Database",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 2,
            "description": "",
            "label": "my_rhel",
            "name": "My RHEL",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 3,
            "description": "",
            "label": "fedora16",
            "name": "Fedora",
            "organization_id": 1
            },
        {
            "created_at": "2012-01-20T12:00:44Z",
            "updated_at": "2012-01-20T12:00:44Z",
            "id": 4,
            "description": "",
            "label": "fedora17",
            "name": "Fedora",
            "organization_id": 1
            },
        ]
FILTERS = [
          {
          'content_view_definition_id': 1,
          'content_view_definition_label': 'Database',
          'created_at': '2013-04-18T23:42:57Z',
          'id': 16,
          'name': 'filter',
          'organization': 'ACME_Corporation',
          'products': ['Product1'],
          'repos': ['Repo4'],
          'rules': [{'content': 'erratum',
                      'created_at': '2013-04-19T16:19:04Z',
                      'filter_id': 16,
                      'id': 16,
                      'inclusion': False,
                      'rule': {'date_range': {'end': '2012-03-09T19:00:00-05:00',
                                                'start': '2011-04-09T20:00:00-04:00'}},
                      'type': 'excludes',
                      'updated_at': '2013-04-19T16:19:04Z'},
                     {'content': 'rpm',
                      'created_at': '2013-04-19T15:48:04Z',
                      'filter_id': 16,
                      'id': 15,
                      'inclusion': False,
                      'rule': {'units': [{'name': 'wal*'}]},
                      'type': 'excludes',
                      'updated_at': '2013-04-19T15:48:04Z'}],
           'updated_at': '2013-04-18T23:42:57Z'
            }
            ]