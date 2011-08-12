import unittest
from mock import Mock

from katello.client.core.product import Create

class RequiredCLIOptionsTests(unittest.TestCase):
    def setUp(self):
        self.create_action = Create()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--provider=porkchop', '--name=product1'])

    def test_missing_prov_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--org=ACME', '--provider=porkchop'])

    def test_missing_prov_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--org=ACME', '--name=product1'])

    def test_no_error_if_required_options_provided(self):
        self.create_action.process_options(['create', '--org=ACME', '--provider=porkchop', '--name=product1'])
        self.assertEqual(len(self.create_action.optErrors), 0)
        

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
    
    def setUp(self):
        self.create_action = Create()
        
        self.create_action.find_provider = Mock()
        self.create_action.find_provider.return_value = { 'id':self.PROVIDER_ID }
        
        self.create_action.create_product = Mock()
        self.create_action.create_product.return_value = { 'cp_id': self.PRODUCT_ID, 'name':self.PRODUCT }
        
        self.create_action.discover_repos = Mock()
        self.create_action.discover_repos.return_value = self.DISCOVERED_REPOS
        
        self.create_action.select_repos = Mock()
        self.create_action.select_repos.return_value = self.DISCOVERED_REPOS
        
        self.create_action.create_repos = Mock()
        
        self.create_action.printer = Mock()
        self.create_action.create_product_with_repos(self.PROVIDER, self.ORGANIZATION, self.PRODUCT, self.DESCRIPTION, self.URL, self.ASSUMEYES)
        
    def test_finds_provider(self):
        self.create_action.find_provider.assert_called_once_with(self.ORGANIZATION, self.PROVIDER)
        
    def test_creates_product(self):
        self.create_action.create_product.assert_called_once_with(self.PROVIDER_ID, self.PRODUCT, self.DESCRIPTION)
        
    def test_discovers_repos(self):
        self.create_action.discover_repos.assert_called_once_with(self.URL)
        
    def test_selects_repos(self):
        self.create_action.select_repos.assert_called_once_with(self.DISCOVERED_REPOS, self.ASSUMEYES)
        
    def test_create_repos(self, ):
        self.create_action.create_repos.assert_called_once_with(self.PRODUCT_ID, self.PRODUCT, self.DISCOVERED_REPOS)
        
        
        
         
