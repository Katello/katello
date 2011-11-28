import unittest
from mock import Mock
import os
from cli_test_utils import CLIOptionTestCase
import test_data

import katello.client.core.provider
from katello.client.core.provider import SingleProviderAction

try:
    import json
except ImportError:
    import simplejson as json


class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(SingleProviderAction())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['some_action', '--name=provider'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['some_action', '--org=ACME'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['some_action', '--org=ACME', '--name=provider'])
        self.assertEqual(len(self.action.optErrors), 0)


