import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, \
        CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import AddRule

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = AddRule()

    disallowed_options = [
    ('--org=ACME' ),
    ('--org=ACME', '--definition=content_def1'),
    ('--org=ACME', '--definition=content_def1', '--name=boo'),
    ('--org=ACME', '--definition=content_def1', '--name=boo', '--content=rpm'),
    ]

    allowed_options = [
        ('--org=ACME', '--definition=content_def1', '--name=flt', '--content=rpm', """--rule='{}'"""),
        ('--org=ACME', '--definition=content_def1', '--name=flt', '--content=package_group', '--type=includes', """--rule='{}'"""),
        ('--org=ACME', '--definition=content_def1', '--name=flt', '--content=erratum', '--type=excludes', """--rule='{}'""")
    ]


class FilterAddRuleTest(CLIActionTestCase):
    ORG = 'org'
    FILTER = {'name': 'filter',
              'id': 6
              }
    FILTER_RULE = "boo"
    CONTENT_TYPE = "rpm"
    INCLUSION_TYPE= "includes"
    RULE = {}
    DEF = {"label": "KingKong",
           "name": "KingKong",
           "id": 3
           }
    OPTIONS = {
        'org': ORG,
        'name': FILTER["name"],
        'definition': DEF["name"],
        'content': CONTENT_TYPE,
        'inclusion': INCLUSION_TYPE,
        'rule': RULE
    }

    def setUp(self):
        self.set_action(AddRule())
        self.set_module(katello.client.core.filter)
        self.mock_printer()
        self.mock_options(self.OPTIONS)
        self.mock(self.action.api, 'create_rule', [])
        self.mock(self.module, 'get_cv_definition', self.DEF)
        self.mock(self.module, 'get_filter', self.FILTER)

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_api(self):
        self.run_action()
        self.action.api.create_rule.assert_called_once_with(
            self.FILTER["id"], self.DEF["id"], self.ORG, self.RULE, self.CONTENT_TYPE, True)
