import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
        ('--name=filter1', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--name=filter1')
    ]


class FilterAddTest(CLIActionTestCase):
    ORG = 'org'
    NAME = 'filter'
    DESCRIPTION = 'description'
    FILTER1 = "filter1"
    FILTER2 = "filter2"
    FILTER3 = "filter3"

    OPTIONS = {
        'org':ORG,
        'name':NAME,
        'description':DESCRIPTION,
        'packages': FILTER1 + "," + FILTER2 + "," + FILTER3
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', [])

    def tearDown(self):
        self.restore_mocks()

    def test_parse_packges_returns_list_of_pacakge_ids(self):
        self.assertEqual(['f1', 'f2', 'f3'], self.action.parse_packages("f1,f2,f3"))

    def test_parse_packages_strips_spaces(self):
        self.assertEqual(['f1', 'f2', 'f3'], self.action.parse_packages(" f1, f2 ,f3 "))

    def test_it_uses_filter_create_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(self.ORG, self.NAME, self.DESCRIPTION, [self.FILTER1, self.FILTER2, self.FILTER3])
