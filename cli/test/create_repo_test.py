import unittest
from mock import Mock

import katello.client.core.repo
from katello.client.core.repo import Create

class RequiredCLIOptionsTests(unittest.TestCase):
    def setUp(self):
        self.create_action = Create()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--name=repo1', '--url=http://localhost', '--product=product1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--org=ACME', '--name=repo1', '--url=http://localhost'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--org=ACME', '--url=http://localhost', '--product=product1'])

    def test_missing_url_generates_error(self):
        self.assertRaises(Exception, self.create_action.process_options, ['create', '--org=ACME', '--name=repo1', '--product=product1'])

    def test_no_error_if_required_options_provided(self):
        self.create_action.process_options(['create', '--org=ACME', '--name=repo1', '--url=http://localhost', '--product=product1'])
        self.assertEqual(len(self.create_action.optErrors), 0)
        
        
class RepoDiscoveryTest(unittest.TestCase):
    RESULT = {'result':''}
    DISCOVERY_TASK = {}
    URL = 'http://localhost'
    
    def setUp(self):
        self.original_run_spinner_in_bg = katello.client.core.repo.run_spinner_in_bg
        katello.client.core.repo.run_spinner_in_bg = Mock()
        katello.client.core.repo.run_spinner_in_bg.return_value = self.RESULT
        
        self.original_system_exit = katello.client.core.repo.system_exit
        katello.client.core.repo.system_exit = Mock()
        
        self.create_action = Create()
        
        self.create_action.api.repo_discovery = Mock()
        self.create_action.api.repo_discovery.return_value = self.DISCOVERY_TASK                
        
    def tearDown(self):
        katello.client.core.repo.run_spinner_in_bg = self.original_run_spinner_in_bg
        katello.client.core.repo.system_exit = self.original_system_exit
    
    def test_performs_pulp_repo_discovery(self):
        self.create_action.discover_repositories(self.URL)
        self.create_action.api.repo_discovery.assert_called_once_with(self.URL, 'yum')
        
    def test_polls_pulp(self):
        self.create_action.discover_repositories(self.URL)
        katello.client.core.repo.run_spinner_in_bg.assert_called_once_with(self.create_action.wait_for_discovery, [self.DISCOVERY_TASK])
        
    def test_exit_when_no_repos_were_discovered(self):
        katello.client.core.repo.run_spinner_in_bg.return_value = {'result':[]}
        self.create_action.discover_repositories(self.URL)
        katello.client.core.repo.system_exit.assert_called_once
        