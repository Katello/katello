import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.architecture.architecture_base_test import ArchitectureBaseTest
from katello.client.core.architecture import Update
from katello.client.server import ServerRequestError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name, new_name
    action = Update()

    allowed_options = [
        ('--name=some_name', '--new_name=another_name')
    ]

    disallowed_options = [
        ('--name=some_name', ),
        ('--new_name=another_name', )
    ]


class ArchitectureUpdateTest(ArchitectureBaseTest):

    NEW_ARCH = ArchitectureBaseTest.ARCHS[1]
    NEW_ARCH_NAME = NEW_ARCH["architecture"]["name"]

    OPTIONS = {
        'old_name': ArchitectureBaseTest.ARCH_NAME, 
        'name': NEW_ARCH_NAME
    }

    def setUp(self):
        self.set_action(Update())
        self.mock(self.action.api, 'update', self.NEW_ARCH)
        super(ArchitectureUpdateTest, self).setUp()

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.update.assert_called_once_with(self.ARCH_NAME, {'name': self.NEW_ARCH_NAME})

    def test_it_fails_when_server_side_update_failed(self):
        self.mock(self.action.api, 'update').side_effect = ServerRequestError(os.EX_DATAERR)
        self.run_action(os.EX_DATAERR)


    def test_returns_ok(self):
        self.run_action(os.EX_OK)
