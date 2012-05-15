import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.permission
from katello.client.core.permission import Create
from katello.client.api.utils import ApiDataError

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name, user_role, scope
    #optional: description, org, tags, verbs

    action = Create()

    disallowed_options = [
        ('--user_role=role1', '--scope=environments'),
        ('--name=perm1', '--scope=environments'),
        ('--name=perm1', '--user_role=role1')
    ]

    allowed_options = [
        ('--name=perm1', '--user_role=role1', '--scope=environments')
    ]


class PermissionCreateTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    PERMISSION = test_data.PERMISSIONS[0]

    SIMPLE_OPTIONS = {
        'name': PERMISSION['name'],
        'user_role': ROLE['name'],
        'scope': PERMISSION['resource_type']['name'],
        'verbs': '',
        'tags': ''
    }

    FULL_OPTIONS = {
        'name': PERMISSION['name'],
        'user_role': ROLE['name'],
        'scope': PERMISSION['resource_type']['name'],
        'verbs': 'v1,v2',
        'tags': 't1,t2'
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.permission)
        self.mock_printer()

        self.mock_options(self.SIMPLE_OPTIONS)

        self.mock(self.action.api, 'create', self.PERMISSION)
        self.mock(self.module, 'get_role', self.ROLE)

    def test_it_splits_comma_separated_options(self):
        self.assertEqual(self.action.split_options(''), [])
        self.assertEqual(self.action.split_options('A,B,C'), ['A', 'B', 'C'])

    def test_it_converts_tags_to_ids(self):
        self.mock(self.action, 'tag_name_to_id_map', {'t1': '1', 't2': '2'})
        self.assertEqual(self.action.tags_to_ids(['t1', 't2'], 'org', 'envs'), ['1', '2'])

    def test_it_raises_exception_when_tag_not_found(self):
        self.mock(self.action, 'tag_name_to_id_map', {})
        self.assertRaises(Exception, self.action.tags_to_ids, ['t1', 't2'], 'org', 'envs')

    def test_it_buildes_tag_map(self):
        perms = test_data.AVAILABLE_PERMISSIONS
        perms['environments']['tags'] = [
            {'display_name': 'env1', 'name': '1'},
            {'display_name': 'env2', 'name': '2'}
        ]
        self.mock(self.action, 'getAvailablePermissions', perms)
        self.assertEqual(self.action.tag_name_to_id_map('org', 'environments'), {'env1': '1', 'env2': '2'})

    def test_it_finds_role(self):
        self.mock(self.action, 'split_options', [])
        self.mock(self.action, 'tags_to_ids', [])
        self.run_action()
        self.module.get_role.assert_called_once_with(self.ROLE['name'])

    def test_it_returns_error_when_role_not_found(self):
        self.mock(self.action, 'split_options', [])
        self.mock(self.action, 'tags_to_ids', [])
        self.mock(self.module, 'get_role').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_creates_permission(self):
        self.mock_options(self.FULL_OPTIONS)
        self.mock(self.action, 'tags_to_ids', ['1', '2'])
        self.run_action()
        self.action.api.create.assert_called_once_with(self.ROLE['id'], self.PERMISSION['name'], self.PERMISSION['description'], self.PERMISSION['resource_type']['name'], ['v1', 'v2'], ['1', '2'], None)

    def test_returns_error_when_permission_not_created(self):
        self.mock(self.action, 'split_options', [])
        self.mock(self.action, 'tags_to_ids', [])
        self.mock(self.action.api, 'create', {})
        self.run_action(os.EX_DATAERR)

    def test_returns_ok(self):
        self.mock(self.action, 'split_options', [])
        self.mock(self.action, 'tags_to_ids', [])
        self.run_action(os.EX_OK)
