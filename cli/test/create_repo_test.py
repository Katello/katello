import unittest
from mock import Mock
import urlparse

import katello.client.core.repo
from katello.client.core.repo import Discovery

class RequiredCLIOptionsTests(unittest.TestCase):
    def setUp(self):
        self.create_action = Discovery()

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

        self.create_action = Discovery()

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


class RepositorySelectionTest(unittest.TestCase):
    DISCOVERED_URLS = ['http://localhost/a/b/', 'http://localhost/a/c/']
    
    def setUp(self):
        self.create_action = Discovery()                
        self.original_system_exit = katello.client.core.repo.system_exit        
        katello.client.core.repo.system_exit = Mock()


    def tearDown(self):
        katello.client.core.repo.system_exit = self.original_system_exit
        
    def test_q_forces_exit(self):
        raw_input_stub = RawInputStub(['q'])                
        self.create_action.select_repositories(self.DISCOVERED_URLS, False, raw_input_stub.raw_input)
        
        katello.client.core.repo.system_exit.assert_called_once
        
    def test_a_y_adds_all_discovered_repos(self):
        raw_input_stub = RawInputStub(['a', 'y'])
        selected_repos = self.create_action.select_repositories(self.DISCOVERED_URLS, False, raw_input_stub.raw_input)
        
        self.assertEqual(selected_repos, self.DISCOVERED_URLS)
        
    def test_1_y_adds_first_discovered_repo(self):
        raw_input_stub = RawInputStub(['1', 'y'])
        selected_repos = self.create_action.select_repositories(self.DISCOVERED_URLS, False, raw_input_stub.raw_input)
        
        self.assertEqual(selected_repos, [self.DISCOVERED_URLS[0]])
        
    def test_assumeyes_adds_all_discovered_repos(self):
        selected_repos = self.create_action.select_repositories(self.DISCOVERED_URLS, True)
        self.assertEqual(selected_repos, self.DISCOVERED_URLS)        


class RepositoryNameTest(unittest.TestCase):
    NAME = 'REPO'
    URL = 'http://localhost/a/b/'

    def setUp(self):
        self.create_action = Discovery()
        self.parsedUrl = urlparse.urlparse(self.URL)

    def test_replaces_slashes_with_underscores(self):
        self.assertEqual(self.create_action.repository_name(self.NAME, self.parsedUrl.path), "REPO_a_b_")


class CreateRepositoryTest(unittest.TestCase):
    PRODUCT_ID = '123'
    NAME = 'REPO'
    URL = 'http://localhost/a/b/'
    URL2 = 'http://localhost/a/c/'

    def setUp(self):
        self.create_action = Discovery()
        self.create_action.api.create = Mock()

    def test_create_repo_in_pulp(self):
        self.create_action.create_repositories(self.PRODUCT_ID, self.NAME, [self.URL])
        parsedUrl = urlparse.urlparse(self.URL)
        self.create_action.api.create.assert_called_once_with(self.PRODUCT_ID, self.create_action.repository_name(self.NAME, parsedUrl.path), self.URL)

    def test_creates_repos_in_pulp_for_all_urls(self):
        self.create_action.create_repositories(self.PRODUCT_ID, self.NAME, [self.URL, self.URL2])
        self.create_action.api.create.assert_called_twice


class RawInputStub:
    
    def __init__(self, input):
        self.invocation = 0
        self.input = input
        
    def raw_input(self, prompt):
        to_return = self.input[self.invocation]
        self.invocation = self.invocation + 1
        
        return to_return




