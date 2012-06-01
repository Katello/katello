import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import Delete

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Delete()

    disallowed_options = [
        ('--name=filter1', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--name=filter1')
    ]


class FilterDeleteTest(CLIActionTestCase):

    ORG = 'org'
    FILTER = 'filter'

    OPTIONS = {
        'org':ORG,
        'name':FILTER
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'delete')

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_filter_delete_api(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.ORG, self.FILTER)
