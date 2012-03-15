import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.organization
from katello.client.core.organization import ShowSubscriptions



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(ShowSubscriptions())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['subscriptions'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['subscriptions', '--name=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)



class SubscriptionsListTest(CLIActionTestCase):

    ORGANIZATION = 'org'
    OPTIONS = { 'name': ORGANIZATION }

    def setUp(self):
        self.set_action(ShowSubscriptions())
        self.set_module(katello.client.core.organization)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'organization', test_data.ORGS[0])
        self.mock(self.action.api, 'pools', [test_data.POOL])
        self.mock(self.action.productApi, 'show', test_data.PRODUCTS[0])

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_all_pools_for_organization(self):
        self.action.run()
        self.action.api.pools.assert_called_once_with(test_data.ORGS[0]["cp_key"])

    def test_extract_sla_from_product(self):
        self.assertEqual(test_data.SLA_VALUE, self.action.extract_sla_from_product(test_data.PRODUCTS[0]))

    def test_extract_sla_from_product_with_no_sla(self):
        self.assertEqual("", self.action.extract_sla_from_product(test_data.PRODUCTS[1]))

    def test_displayable_pool(self):
        pool_with_sla = self.action.displayable_pool(test_data.POOL)
        self.assertEqual(test_data.SLA_VALUE, pool_with_sla['sla'])
