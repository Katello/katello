import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.product import product_data

import katello.client.core.organization
from katello.client.core.organization import ShowSubscriptions



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = ShowSubscriptions()

    disallowed_options = [
        ()
    ]

    allowed_options = [
        ('--name=ACME', )
    ]



class SubscriptionsListTest(CLIActionTestCase):

    ORGANIZATION = 'org'
    OPTIONS = { 'name': ORGANIZATION }

    def setUp(self):
        self.set_action(ShowSubscriptions())
        self.set_module(katello.client.core.organization)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'organization', organization_data.ORGS[0])
        self.mock(self.action.api, 'pools', [organization_data.POOL])
        self.mock(self.action.productApi, 'show', product_data.PRODUCTS[0])

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_all_pools_for_organization(self):
        self.run_action()
        self.action.api.pools.assert_called_once_with(organization_data.ORGS[0]["cp_key"])

    def test_extract_sla_from_product(self):
        self.assertEqual(product_data.SLA_VALUE, self.action.extract_sla_from_product(product_data.PRODUCTS[0]))

    def test_extract_sla_from_product_with_no_sla(self):
        self.assertEqual("", self.action.extract_sla_from_product(product_data.PRODUCTS[1]))

    def test_displayable_pool(self):
        pool_with_sla = self.action.displayable_pool(organization_data.POOL)
        self.assertEqual(product_data.SLA_VALUE, pool_with_sla['sla'])
