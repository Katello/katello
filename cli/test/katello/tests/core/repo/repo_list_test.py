import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.repo import repo_data
from katello.tests.core.product import product_data

import katello.client.core.repo
from katello.client.core.repo import List


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #list action accepts:
    # org
    # org environment
    # org product
    # org product environment
    # + include_disabled

    action = List()

    disallowed_options = [
        ('--environment=env', )
    ]

    allowed_options = [
        ('--org=ACME', ),
        ('--org=ACME', '--environment=env'),
        ('--org=ACME', '--product=prod'),
        ('--org=ACME', '--product=prod', '--environment=env'),
        ('--org=ACME', '--product=prod', '--include_disabled'),
    ]

class RepoListTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    ENV = organization_data.ENVS[0]
    PROD = product_data.PRODUCTS[0]

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

        self.mock(self.action.api, 'repos_by_env_product', repo_data.REPOS)
        self.mock(self.action.api, 'repos_by_product', repo_data.REPOS)
        self.mock(self.action.api, 'repos_by_org_env', repo_data.REPOS)

        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_product', self.PROD)

    def test_it_finds_environment(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_finds_product(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.run_action()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_finds_product_and_env(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.run_action()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_gets_repos_by_org(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.run_action()
        self.action.api.repos_by_org_env.assert_called_once_with(self.ORG['name'], self.ENV['id'], False)

    def test_it_gets_repos_by_product(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.run_action()
        self.action.api.repos_by_product.assert_called_once_with(self.ORG['name'], self.PROD['id'], False)

    def test_it_gets_repos_by_product_and_env(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.run_action()
        self.action.api.repos_by_env_product.assert_once_once_with(self.ENV['id'], self.PROD['id'], None, False)

    def test_it_prints_repos(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.run_action()
        self.action.printer.print_items.assert_called_with(repo_data.REPOS)
        self.action.printer.print_items.reset_mock()

        self.mock_options(self.OPTIONS_BY_PRODUCT)
        self.run_action()
        self.action.printer.print_items.assert_called_with(repo_data.REPOS)
        self.action.printer.print_items.reset_mock()

        self.mock_options(self.OPTIONS_BY_PRODUCT_ENV)
        self.run_action()
        self.action.printer.print_items.assert_called_with(repo_data.REPOS)
