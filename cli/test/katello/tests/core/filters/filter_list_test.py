import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.filter
from katello.client.core.filter import List

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = List()

    disallowed_options = [
        ('--name=product_1', )
    ]

    allowed_options = [
        ('--org=ACME','--definition=foo' )
    ]

class FilterListTest(CLIActionTestCase):

    ORG = 'some_org'
    DEFINITION = "def"
    OPTIONS = {'org':ORG, 'definition':DEFINITION}

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.filter)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.def_api, 'filters_by_cvd_and_org', [])

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_lists_api(self):
        self.run_action()
        self.action.def_api.filters_by_cvd_and_org.\
                assert_called_once_with(self.DEFINITION, self.ORG)
