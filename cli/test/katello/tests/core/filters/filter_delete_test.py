import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import Delete

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Delete()

    disallowed_options = [
    ('--org=ACME' ),
    ('--org=ACME', '--definition=content_def1'),
    ]

    allowed_options = [
        ('--org=ACME', '--definition=content_def1', '--filter=flt')
    ]



class FilterDeleteTest(CLIActionTestCase):
    ORG = 'org'
    DEF = { "label": 'content_def',
             "id": 1
            }
    FILTER = 'filter'        

    OPTIONS = {
        'org':ORG,
        'definition':DEF["label"],
        'filter_name':FILTER
    }
    
    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.filter)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.def_api, 'delete')

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_content_view_delete_api(self):
        self.run_action()
        self.action.def_api.delete.assert_called_once_with(self.FILTER,
                self.DEF["label"], self.ORG)
