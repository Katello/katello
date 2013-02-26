import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.product import product_data
from katello.tests.core.provider import provider_data

import katello.client.core.product
from katello.client.core.product import ListRepositorySets



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = ListRepositorySets()

    disallowed_options = [
        ('--environment=env', ),
    ]

    allowed_options = [
        ('--org=ACME', '--name=product_1')
    ]


class RepositorySetListTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    PROD = product_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name']
    }

    def setUp(self):
        self.set_action(ListRepositorySets())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'repository_sets', product_data.PRODUCTS)
        self.mock(self.module, 'get_product', self.PROD)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_repo_sets(self):
        self.run_action()
        self.action.api.repository_sets.assert_called_once_with(self.ORG['name'], self.PROD['id'])

    def test_it_prints_products(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(product_data.PRODUCTS)
