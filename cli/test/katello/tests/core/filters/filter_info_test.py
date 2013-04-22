import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import Info

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Info()

    disallowed_options = [
    ('--org=ACME' ),
    ('--org=ACME', '--definition=content_def1'),
    ('--org=ACME', '--definition=content_def1', '--filter=flt'),
    ]

    allowed_options = [
        ('--org=ACME', '--definition=content_def1', '--name=flt'),
        ('--org=ACME', '--definition=content_def1', '--id=flt')
    ]


class FilterInfoTest(CLIActionTestCase):

    ORG = 'org'
    DEF = {"name": 'content_def',
           "label": 'content_def',
           "id": 1
           }
    FILTER = {'name': 'filter',
              'id': 6
              }

    OPTIONS = {
        'org':ORG,
        'definition_id':DEF["id"],
        'name':FILTER['name']
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.filter)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'get_filter_info', self.FILTER)
        self.mock(self.module, 'get_cv_definition', self.DEF)
        self.mock(self.module, 'get_filter', self.FILTER)

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_content_view_show_api(self):
        self.run_action()
        self.action.api.get_filter_info.assert_called_once_with(self.FILTER["id"],
                self.DEF["id"], self.ORG)
