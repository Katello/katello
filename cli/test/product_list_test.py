import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import List



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = List()

    disallowed_options = [
        ('--environment=env', ),
    ]

    allowed_options = [
        ('--org=ACME', ),
        ('--org=ACME', '--environment=env'),
        ('--org=ACME', '--provider=prov')
    ]


class ProductListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    PROV = test_data.PROVIDERS[2]

    OPTIONS_BY_ENV = {
        'org': ORG['name'],
        'env': ENV['name']
    }

    OPTIONS_BY_PROVIDER = {
        'org': ORG['name'],
        'prov': PROV['name']
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS_BY_ENV)
        self.mock_printer()

        self.mock(self.action.api, 'products_by_env', test_data.PRODUCTS)
        self.mock(self.action.api, 'products_by_provider', test_data.PRODUCTS)

        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_provider', self.PROV)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_environment(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_finds_products_by_environment(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.run_action()
        self.action.api.products_by_env.assert_called_once_with(self.ENV['id'])

    def test_it_finds_provider(self):
        self.mock_options(self.OPTIONS_BY_PROVIDER)
        self.run_action()
        self.module.get_provider.assert_called_once_with(self.ORG['name'], self.PROV['name'])

    def test_it_finds_products_by_provider(self):
        self.mock_options(self.OPTIONS_BY_PROVIDER)
        self.run_action()
        self.action.api.products_by_provider.assert_called_once_with(self.PROV['id'])

    def test_it_prints_products(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(test_data.PRODUCTS)
