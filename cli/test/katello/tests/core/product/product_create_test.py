import unittest
from mock import Mock
from katello.tests.core.action_test_utils import CLIOptionTestCase

import katello.client.core.product
from katello.client.core.product import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
        ('--provider=porkchop', '--name=product1'),
        ('--org=ACME', '--provider=porkchop'),
        ('--org=ACME', '--name=product1')
    ]

    allowed_options = [
        ('--org=ACME', '--provider=porkchop', '--name=product1'),
        ('--org=ACME', '--provider=porkchop', '--name=product1', '--url=http://localhost'),
        ('--org=ACME', '--provider=porkchop', '--name=product1', '--url=https://localhost'),
        ('--org=ACME', '--provider=porkchop', '--name=product1', '--url=ftp://localhost'),
        ('--org=ACME', '--provider=porkchop', '--name=product1', '--url=file://localhost')
    ]


class CreateTest(unittest.TestCase):
    PROVIDER = 'provider'
    PROVIDER_ID = '123'
    ORGANIZATION = 'org'
    PRODUCT = 'product1'
    PRODUCT_ID = '123'
    DESCRIPTION = 'description'
    URL = 'http://localhost'
    DISCOVERED_REPOS = ['url1', 'url2']
    ASSUMEYES = True
    NODISC = False

    def setUp(self):
        self.original_get_provider = katello.client.core.product.get_provider
        katello.client.core.product.get_provider = Mock()
        katello.client.core.product.get_provider.return_value = { 'id':self.PROVIDER_ID }

        self.create_action = Create()

        self.create_action.api.create = Mock()
        self.create_action.api.create.return_value = { 'id': self.PRODUCT_ID, 'name':self.PRODUCT }

        self.create_action.discoverRepos.discover_repositories = Mock()
        self.create_action.discoverRepos.discover_repositories.return_value = self.DISCOVERED_REPOS

        self.create_action.discoverRepos.select_repositories = Mock()
        self.create_action.discoverRepos.select_repositories.return_value = self.DISCOVERED_REPOS

        self.create_action.discoverRepos.create_repositories = Mock()

        self.create_action.printer = Mock()

    def tearDown(self):
        katello.client.core.product.get_provider = self.original_get_provider

    def test_finds_provider(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES, self.NODISC, None)
        katello.client.core.product.get_provider.assert_called_once_with(self.ORGANIZATION, self.PROVIDER)

    def test_creates_product(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES, self.NODISC, None)
        self.create_action.api.create.assert_called_once_with(self.PROVIDER_ID, self.PRODUCT, self.DESCRIPTION, None)

    def test_discovers_repos(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES, self.NODISC, None)
        self.create_action.discoverRepos.discover_repositories.assert_called_once_with(self.ORGANIZATION, self.URL)

    def test_creates_product_without_repositories_if_url_was_not_specified(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, None, self.ASSUMEYES, self.NODISC, None)

        self.assertFalse(self.create_action.discoverRepos.discover_repositories.called)
        self.assertFalse(self.create_action.discoverRepos.select_repositories.called)
        self.assertFalse(self.create_action.discoverRepos.create_repositories.called)

    def test_selects_repos(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES, self.NODISC, None)
        self.create_action.discoverRepos.select_repositories.assert_called_once_with(self.DISCOVERED_REPOS, self.ASSUMEYES)

    def test_create_repos(self):
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES, self.NODISC, None)
        self.create_action.discoverRepos.create_repositories.assert_called_once_with(self.ORGANIZATION, self.PRODUCT_ID, self.PRODUCT, self.DISCOVERED_REPOS)
