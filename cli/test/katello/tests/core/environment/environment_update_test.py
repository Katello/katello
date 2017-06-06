import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.environment.environment_base_test import EnvironmentBaseTest
from katello.client.core.environment import Update
from katello.client.server import ServerRequestError
import katello.client.core.environment


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name, new_name
    action = Update()
    
    allowed_options = [
        ('--org=', '--name=','--prior=' ),
        ('--org=', '--name=','--prior=', '--description=' ),
        ('--org=', '--name=','--prior=', '--new-name=' ),
        ('--org=', '--name=','--prior=', '--new-name=', '--description=' ),
    ]


class EnvironmentUpdateTest(EnvironmentBaseTest):

    NEW_ENV = EnvironmentBaseTest.DEV
    NEW_ENV_NAME = 'CHEZ'

    OPTIONS = {
        'old_name': NEW_ENV['name'], 
        'name': NEW_ENV_NAME,
        'org': "ACME_Corporation",
        'prior': 'Library'
    }

    def setUp(self):
        self.set_action(Update())
        self.set_module(katello.client.core.environment)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_environment', self.DEV)
        self.mock(self.action, 'get_prior_id', self.LIBRARY['id'])
        self.mock(self.action.api, 'update', self.NEW_ENV)

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.update.assert_called_once_with(self.OPTIONS['org'], self.NEW_ENV['id'], 
            self.NEW_ENV_NAME, None, self.LIBRARY['id'])

    def test_it_fails_when_server_side_update_failed(self):
        self.mock(self.action.api, 'update').side_effect = ServerRequestError(os.EX_DATAERR)
        self.run_action(os.EX_DATAERR)


    def test_returns_ok(self):
        self.run_action(os.EX_OK)

