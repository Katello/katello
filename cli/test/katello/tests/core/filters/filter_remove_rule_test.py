import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, \
        CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import RemoveRule

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = RemoveRule()

    disallowed_options = [
    ('--org=ACME' ),
    ('--org=ACME', '--definition=content_def1'),
    ('--org=ACME', '--definition=content_def1', '--name=boo')
    ]

    allowed_options = [
        ('--org=ACME', '--definition=content_def1', '--name=flt', '--rule_id=100')
    ]


class FilterRemoveRuleTest(CLIActionTestCase):
    ORG = 'org'
    FILTER = {'name': 'filter',
              'id': 6
              }
    FILTER_RULE = "boo"
    ID = 100
    DEF = {"label": "KingKong",
           "name": "KingKong",
           "id": 3
           }
    OPTIONS = {
        'org': ORG,
        'name': FILTER["name"],
        'definition': DEF["name"],
        'rule': ID
    }

    def setUp(self):
        self.set_action(RemoveRule())
        self.set_module(katello.client.core.filter)
        self.mock_printer()
        self.mock_options(self.OPTIONS)
        self.mock(self.action.api, 'remove_rule', [])
        self.mock(self.module, 'get_cv_definition', self.DEF)
        self.mock(self.module, 'get_filter', self.FILTER)


    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_api(self):
        self.run_action()
        self.action.api.remove_rule.assert_called_once_with(
            self.FILTER["id"], self.DEF["id"], self.ORG, self.ID)
