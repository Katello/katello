import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.product import product_data
from katello.tests.core.provider import provider_data
from katello.tests.core.repo import repo_data

import katello.client.core.product
from katello.client.core.product import EnableRepositorySet



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = EnableRepositorySet()

    disallowed_options = [
        ('--environment=env', ),
    ]

    allowed_options = [
        ('--org=ACME', '--name=product_1', '--set_name=10')
    ]


class RepositorySetListTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    PROD = product_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name'],
        'set_name': '10'
    }

    def setUp(self):
        self.set_action(EnableRepositorySet())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'enable_repository_set', product_data.PRODUCTS)
        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.module, 'run_spinner_in_bg', repo_data.SYNC_RESULT_WITHOUT_ERROR[0])


    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_repo_sets(self):
        self.run_action()
        self.action.api.enable_repository_set.assert_called_once_with(self.ORG['name'], self.PROD['id'], '10')

