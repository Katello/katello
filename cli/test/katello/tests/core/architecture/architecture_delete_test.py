import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.architecture.architecture_base_test import ArchitectureBaseTest
from katello.client.core.architecture import Delete
from katello.client.server import ServerRequestError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name
    action = Delete()

    allowed_options = [
        ('--name=', )
    ]


class ArchitectureDeleteTest(ArchitectureBaseTest):

    OPTIONS = {
        'name': ArchitectureBaseTest.ARCH_NAME
    }

    def setUp(self):
        self.set_action(Delete())
        self.mock(self.action.api, 'destroy')
        super(ArchitectureDeleteTest, self).setUp()

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.destroy.assert_called_once_with(self.ARCH_NAME)

    def test_it_fails_when_record_not_found(self):
        self.mock(self.action.api, 'destroy').side_effect = ServerRequestError(os.EX_DATAERR)
        self.run_action(os.EX_DATAERR)
        
    def test_returns_ok(self):
        self.run_action(os.EX_OK)
