import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.repo
from katello.client.core.repo import List


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #list action accepts:
    # org
    # org environment
    # org product
    # org product environment
    # + include_disabled

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list', '--environment=env'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['list', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_and_env_provided(self):
        self.action.process_options(['list', '--org=ACME', '--environment=env'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['list', '--org=ACME', '--product=prod'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_product_and_env_provided(self):
        self.action.process_options(['list', '--org=ACME', '--product=prod', '--environment=env'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_product_and_disabled_provided(self):
        self.action.process_options(['list', '--org=ACME', '--product=prod', '--include_disabled'])
        self.assertEqual(len(self.action.optErrors), 0)


class RepoListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    PROD = test_data.PRODUCTS[0]

    OPTIONS_BY_ORG = {
        'org': ORG['name'],
        'env': ENV['name']
    }

    OPTIONS_BY_PRODUCT = {
        'org': ORG['name'],
        'product': PROD['name']
    }

    OPTIONS_BY_PRODUCT_ENV = {
        'org': ORG['name'],
        'product': PROD['name'],
        'env': ENV['name']
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.repo)

        self.mock_options(self.OPTIONS_BY_ORG)
        self.mock_printer()

        self.mock(self.action.api, 'repos_by_env_product', test_data.REPOS)
        self.mock(self.action.api, 'repos_by_product', test_data.REPOS)
        self.mock(self.action.api, 'repos_by_org_env', test_data.REPOS)

        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_product', self.PROD)

    def test_it_finds_environment(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.action.run()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_finds_product(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.action.run()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_finds_product_and_env(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.action.run()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_gets_repos_by_org(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.action.run()
        self.action.api.repos_by_org_env.assert_called_once_with(self.ORG['name'], self.ENV['id'], False)

    def test_it_gets_repos_by_product(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.action.run()
        self.action.api.repos_by_product.assert_called_once_with(self.ORG['name'], self.PROD['id'], False)

    def test_it_gets_repos_by_product_and_env(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.action.run()
        self.action.api.repos_by_env_product.assert_once_once_with(self.ENV['id'], self.PROD['id'], None, False)

    def test_it_prints_repos(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.action.run()
        self.action.printer.printItems.assert_called_with(test_data.REPOS)
        self.action.printer.printItems.reset_mock()

        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.action.run()
        self.action.printer.printItems.assert_called_with(test_data.REPOS)
        self.action.printer.printItems.reset_mock()

        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.action.run()
        self.action.printer.printItems.assert_called_with(test_data.REPOS)
