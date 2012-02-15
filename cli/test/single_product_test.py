import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import SingleProductAction



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(SingleProductAction())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['some_action', '--name=product_1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['some_action', '--org=ACME'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['some_action', '--org=ACME', '--name=product_1'])
        self.assertEqual(len(self.action.optErrors), 0)
