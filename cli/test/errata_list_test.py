import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.errata
from katello.client.core.errata import List



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--repo=repo-123', '--product=product-123'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--repo=repo-123', '--org=org-123'])

    def test_missing_repo_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--product=product-123', '--org=org-123'])

    def test_no_error_if_all_required_provided(self):
        self.action.process_options(['--repo=repo-123', '--product=product-123', '--org=org-123'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_accept_type_filter(self):
        self.action.process_options(['--type=enhancements','--repo=repo-123', '--product=product-123', '--org=org-123'])
        self.assertEqual(len(self.action.optErrors), 0)

class ErrataListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    PRODUCT = test_data.PRODUCTS[0]
    REPO = test_data.REPOS[0]

    OPTIONS_BY_PRODUCT_AND_REPO = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name']
    }

    OPTIONS_BY_TYPE = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name'],
        'type': 'enhancements'
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.errata)

        self.mock_printer()

        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.action.api, 'errata_by_repo', test_data.ERRATA_BY_REPO)

    def tearDown(self):
        self.restore_mocks()

    def test_it_prints_products(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_AND_REPO)
        self.action.run()
        self.action.printer.printItems.assert_called_once_with(test_data.ERRATA_BY_REPO)

    def test_it_supports_filters(self):
        self.mock_options(self.OPTIONS_BY_TYPE)
        self.action.run()
        self.action.api.errata_by_repo.assert_called_once_with(self.REPO['id'],type=self.OPTIONS_BY_TYPE['type'])
