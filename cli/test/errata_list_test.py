import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

from katello.client.api import utils
import katello.client.core.errata
from katello.client.core.errata import List



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_repo_with_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--repo=repo-123', '--product=product-123'])

    def test_repo_with_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--repo=repo-123', '--org=org-123'])

    def test_product_with_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['--product=product-123'])

    def test_repo_id_neither_org_provided_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, [])

    def test_no_error_if_all_required_provided(self):
        self.action.process_options(['--repo=repo-123', '--product=product-123', '--org=org-123'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_repo_id(self):
        self.action.process_options(['--repo_id=repo-123'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_provided(self):
        self.action.process_options(['--org=org-123'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_environment_and_product(self):
        self.action.process_options(['--org=org-123', '--environment=env-123', '--product=product-123'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_accept_type_filter(self):
        self.action.process_options(['--type=enhancements', '--org=org-123'])
        self.assertEqual(len(self.action.optErrors), 0)
        self.action.process_options(['--severity=critical', '--org=org-123'])
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

    OPTIONS_BY_ORG = { 'org': ORG['name'] }

    OPTIONS_BY_ORG_AND_PRODUCT = { 'org': ORG['name'], 'product': PRODUCT['name'] }

    OPTIONS_BY_ENV = { 'org': ORG['name'], 'env': ENV['name'] }

    OPTIONS_BY_SEVERITY = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name'],
        'severity': 'critical',
    }


    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.errata)

        self.mock_printer()

        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.action.api, 'errata_filter', test_data.ERRATA_BY_REPO)
        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_product', self.PRODUCT)

    def tearDown(self):
        self.restore_mocks()

    def test_it_prints_products(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_AND_REPO)
        self.action.run()
        self.action.printer.printItems.assert_called_once_with(test_data.ERRATA_BY_REPO)

    def test_it_uses_library_when_no_env_is_specified(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.action.run()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ORG['org'], None)

    def test_it_searches_for_env_id_when_env_is_specified(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.action.run()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ENV['org'], self.OPTIONS_BY_ENV['env'])

    def test_it_searches_for_product_id_when_product_specified(self):
        self.mock_options(self.OPTIONS_BY_ORG_AND_PRODUCT)
        self.action.run()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ORG_AND_PRODUCT['org'], None)
        self.module.get_product.assert_called_once_with(self.OPTIONS_BY_ORG_AND_PRODUCT['org'], self.OPTIONS_BY_ORG_AND_PRODUCT['product'])
        self.action.api.errata_filter.assert_called_once_with(repo_id=None, type=None, environment_id=self.ENV['id'], prod_id=self.PRODUCT['id'], severity=None)

    def test_it_supports_filtering_by_type(self):
        self.mock_options(self.OPTIONS_BY_TYPE)
        self.action.run()
        self.action.api.errata_filter.assert_called_once_with(repo_id=self.REPO['id'], type=self.OPTIONS_BY_TYPE['type'], environment_id=None, prod_id=None, severity=None)

    def test_it_supports_filtering_by_severity(self):
        self.mock_options(self.OPTIONS_BY_SEVERITY)
        self.action.run()
        self.action.api.errata_filter.assert_called_once_with(repo_id=self.REPO['id'], type=None, environment_id=None, prod_id=None, severity=self.OPTIONS_BY_SEVERITY['severity'])
