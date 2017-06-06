import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.environment.environment_base_test import EnvironmentBaseTest
from katello.client.core.environment import Create
import katello.client.core.environment


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required:
    action = Create()

    allowed_options = [
        ('--org=', '--name=','--prior=' ),
        ('--org=', '--name=','--prior=', '--label=' ),
    ]


class EnvironmentCreateTest(EnvironmentBaseTest):

    OPTIONS = {
        'name': EnvironmentBaseTest.ENV_NAME,
        'prior': 'Library',
        'label' : "DEV",
        'org' : "ACME_Corporation", 
        'description' : 'internet'

    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.environment)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action, 'get_prior_id', self.LIBRARY['id'])
        self.mock(self.action.api, 'library_by_org', self.LIBRARY) 
        self.mock(self.action.api, 'create', self.DEV)

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(self.OPTIONS['org'], self.OPTIONS['name'], 
            self.OPTIONS['label'],self.OPTIONS['description'], self.LIBRARY['id'])

    def test_it_didnt_pass_validation(self):
        self.mock(self.action.api, 'create', None)
        self.run_action(os.EX_DATAERR)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)

