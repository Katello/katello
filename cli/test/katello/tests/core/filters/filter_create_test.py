import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, \
        CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
    ('--org=ACME' ),
    ('--org=ACME', '--definition=content_def1'),
    ]

    allowed_options = [
        ('--org=ACME', '--definition=content_def1', '--name=flt')
    ]


class FilterCreateTest(CLIActionTestCase):
    ORG = 'org'
    FILTER = 'MyRHEL'
    DEF = {"label": "KingKong",
           "name": "KingKong",
           "id": 3
           }
    OPTIONS = {
        'org': ORG,
        'name': FILTER,
        'definition': DEF["name"]
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.filter)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', [])
        self.mock(self.module, 'get_cv_definition', self.DEF)

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(
            self.FILTER, self.DEF["id"], self.ORG)
